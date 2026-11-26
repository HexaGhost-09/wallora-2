#!/usr/bin/env python3
"""Upload files to Drime Cloud using its current REST and multipart API."""
from __future__ import annotations

import json
import mimetypes
import os
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import requests

API_BASE = "https://app.drime.cloud/api/v1"
TOKEN = os.environ.get("DRIME_TOKEN", "").strip()
CHUNK_SIZE = 5 * 1024 * 1024
WORKERS = 4
WORKSPACE_ID = 0  # Drime personal workspace

if not TOKEN:
    raise SystemExit("DRIME_TOKEN is not set.")

api_session = requests.Session()
api_session.headers.update({
    "Authorization": f"Bearer {TOKEN}",
    "Accept": "application/json",
})


def api(method: str, endpoint: str, **kwargs):
    response = api_session.request(
        method, f"{API_BASE}/{endpoint.lstrip('/')}", timeout=120, **kwargs
    )
    if not response.ok:
        detail = response.text[:1500]
        raise RuntimeError(
            f"Drime API {method} {endpoint} failed: "
            f"HTTP {response.status_code}: {detail}"
        )
    if not response.content:
        return {}
    try:
        return response.json()
    except ValueError as exc:
        raise RuntimeError(
            f"Drime API {endpoint} returned non-JSON data: "
            f"{response.text[:500]}"
        ) from exc


def upload_small(path: Path) -> dict:
    """Drime's documented simple upload route for files below 5 MiB."""
    with path.open("rb") as stream:
        response = api_session.post(
            f"{API_BASE}/uploads",
            files={"file": (path.name, stream, "application/octet-stream")},
            data={"workspaceId": str(WORKSPACE_ID)},
            timeout=300,
        )
    if not response.ok:
        raise RuntimeError(
            f"Drime simple upload failed: HTTP {response.status_code}: "
            f"{response.text[:1500]}"
        )
    result = response.json()
    if str(result.get("status", "")).lower() != "success":
        raise RuntimeError(f"Drime simple upload was not successful: {result}")
    return result


def upload_part(url: str, part_number: int, chunk: bytes) -> dict:
    # Presigned S3 URLs contain their own authorization. Do not send the Drime
    # bearer token or add Content-Type headers to this PUT request.
    last_error = None
    for attempt in range(1, 4):
        try:
            response = requests.put(url, data=chunk, timeout=(30, 300))
            if not response.ok:
                raise RuntimeError(
                    f"HTTP {response.status_code}: {response.text[:500]}"
                )
            etag = response.headers.get("ETag")
            if not etag:
                raise RuntimeError("S3 response did not include an ETag header")
            # Keep ETag exactly as returned (including quotes); Drime expects it.
            return {"PartNumber": part_number, "ETag": etag}
        except Exception as exc:
            last_error = exc
            if attempt < 3:
                print(
                    f"Part {part_number} attempt {attempt} failed: {exc}; retrying",
                    flush=True,
                )
    raise RuntimeError(
        f"Part {part_number} failed after 3 attempts: {last_error}"
    )


def upload_large(path: Path) -> dict:
    size = path.stat().st_size
    extension = path.suffix.lstrip(".").lower() or "bin"
    mime = mimetypes.guess_type(path.name)[0] or "application/octet-stream"

    # 1. Create the multipart upload.
    created = api("POST", "s3/multipart/create", json={
        "filename": path.name,
        "mime": mime,
        "size": size,
        "extension": extension,
        "workspaceId": WORKSPACE_ID,
        "parentId": None,
    })
    if str(created.get("status", "")).lower() != "success":
        raise RuntimeError(f"Drime multipart create failed: {created}")

    key = created.get("key")
    upload_id = created.get("uploadId")
    if not key or not upload_id:
        raise RuntimeError(f"Drime multipart create returned no key/uploadId: {created}")

    try:
        # 2. Current Drime API endpoint is batch-sign-part-urls (not
        # sign-part-urls). The response contains {partNumber, url} objects.
        part_count = (size + CHUNK_SIZE - 1) // CHUNK_SIZE
        signed = api("POST", "s3/multipart/batch-sign-part-urls", json={
            "key": key,
            "uploadId": upload_id,
            "partNumbers": list(range(1, part_count + 1)),
        })
        url_items = signed.get("urls") or []
        urls = {
            int(item["partNumber"]): item["url"]
            for item in url_items
            if item.get("partNumber") is not None and item.get("url")
        }
        if len(urls) != part_count:
            raise RuntimeError(
                f"Drime returned {len(urls)} signed part URLs; expected {part_count}. "
                f"Response: {json.dumps(signed)[:1000]}"
            )

        # 3. Upload chunks with bounded memory and four concurrent workers.
        uploaded_parts = []
        with ThreadPoolExecutor(max_workers=WORKERS) as pool, path.open("rb") as stream:
            pending = []
            for part_number in range(1, part_count + 1):
                chunk = stream.read(CHUNK_SIZE)
                if not chunk:
                    break
                pending.append(
                    pool.submit(upload_part, urls[part_number], part_number, chunk)
                )
                if len(pending) >= WORKERS:
                    uploaded_parts.append(pending.pop(0).result())
                    print(
                        f"Uploaded parts: {len(uploaded_parts)}/{part_count}",
                        flush=True,
                    )

            for future in pending:
                uploaded_parts.append(future.result())
                print(
                    f"Uploaded parts: {len(uploaded_parts)}/{part_count}",
                    flush=True,
                )

        if len(uploaded_parts) != part_count:
            raise RuntimeError(
                f"Uploaded {len(uploaded_parts)} parts; expected {part_count}"
            )
        uploaded_parts.sort(key=lambda item: item["PartNumber"])

        # 4. Complete the multipart upload.
        api("POST", "s3/multipart/complete", json={
            "key": key,
            "uploadId": upload_id,
            "parts": uploaded_parts,
        })

        # 5. Register the completed S3 object in Drime Drive.
        object_name = key.split("/")[-1]
        registered = api("POST", "s3/entries", json={
            "filename": object_name,
            "size": size,
            "clientName": path.name,
            "clientMime": mime,
            "clientExtension": extension,
            "workspaceId": WORKSPACE_ID,
            "parentId": None,
        })
        if (
            str(registered.get("status", "")).lower() != "success"
            or not registered.get("fileEntry")
        ):
            raise RuntimeError(f"Drime file registration failed: {registered}")
        return registered

    except Exception:
        # Clean up incomplete multipart uploads when possible.
        try:
            api("POST", "s3/multipart/abort", json={
                "key": key,
                "uploadId": upload_id,
            })
        except Exception as abort_error:
            print(f"Warning: could not abort multipart upload: {abort_error}", flush=True)
        raise


def upload(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(path)
    size = path.stat().st_size
    if size == 0:
        raise RuntimeError("Refusing to upload an empty file.")
    if size < CHUNK_SIZE:
        return upload_small(path)
    return upload_large(path)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python drime_upload.py <file>")
    file_path = Path(sys.argv[1]).resolve()
    print(
        f"Uploading {file_path.name} ({file_path.stat().st_size:,} bytes) to Drime",
        flush=True,
    )
    result = upload(file_path)
    entry = result.get("fileEntry", {})
    print(
        f"Upload successful: {entry.get('name', file_path.name)} "
        f"(Drime ID: {entry.get('id', 'n/a')})",
        flush=True,
    )
