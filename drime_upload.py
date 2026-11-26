#!/usr/bin/env python3
"""Upload a local file to Drime using its multipart S3 API."""
from __future__ import annotations

import mimetypes
import os
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import requests

TOKEN = os.environ["DRIME_TOKEN"]
BASE = "https://app.drime.cloud/api/v1"
CHUNK_SIZE = 5 * 1024 * 1024
WORKERS = 4

session = requests.Session()
session.headers.update({"Authorization": f"Bearer {TOKEN}"})


def api(method: str, path: str, **kwargs):
    response = session.request(method, BASE + path, timeout=60, **kwargs)
    response.raise_for_status()
    return response.json() if response.content else {}


def upload_part(url: str, part_number: int, data: bytes) -> dict:
    last_error = None
    for attempt in range(3):
        try:
            response = requests.put(url, data=data, timeout=300)
            response.raise_for_status()
            etag = response.headers.get("ETag", "").strip('"')
            if not etag:
                raise RuntimeError("Drime storage response did not include an ETag")
            return {"PartNumber": part_number, "ETag": etag}
        except Exception as exc:
            last_error = exc
            if attempt == 2:
                break
    raise RuntimeError(f"Upload part {part_number} failed after 3 attempts: {last_error}")


def upload_small(path: Path) -> dict:
    mime = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
    with path.open("rb") as stream:
        response = session.post(
            f"{BASE}/uploads",
            files={"file": (path.name, stream, mime)},
            data={"workspaceId": "0", "parentId": ""},
            timeout=300,
        )
    response.raise_for_status()
    return response.json()


def upload_large(path: Path) -> dict:
    size = path.stat().st_size
    name = path.name
    extension = path.suffix.lstrip(".").lower() or "bin"
    mime = mimetypes.guess_type(name)[0] or "application/octet-stream"

    created = api("POST", "/s3/multipart/create", json={
        "filename": name, "mime": mime, "size": size,
        "extension": extension, "workspaceId": 0,
    })
    key, upload_id = created["key"], created["uploadId"]
    part_count = (size + CHUNK_SIZE - 1) // CHUNK_SIZE

    signed = api("POST", "/s3/multipart/sign-part-urls", json={
        "key": key, "uploadId": upload_id,
        "partNumbers": list(range(1, part_count + 1)),
    })
    urls = signed["urls"]
    if len(urls) != part_count:
        raise RuntimeError(f"Drime returned {len(urls)} URLs; expected {part_count}")

    completed_parts = []
    # Keep at most WORKERS chunks in memory instead of loading the whole APK.
    with ThreadPoolExecutor(max_workers=WORKERS) as pool, path.open("rb") as stream:
        pending = []
        for number, url in enumerate(urls, start=1):
            chunk = stream.read(CHUNK_SIZE)
            if not chunk:
                break
            pending.append(pool.submit(upload_part, url, number, chunk))
            if len(pending) >= WORKERS:
                completed_parts.append(pending.pop(0).result())
                print(f"Uploaded parts: {len(completed_parts)}/{part_count}", flush=True)

        for future in pending:
            completed_parts.append(future.result())
            print(f"Uploaded parts: {len(completed_parts)}/{part_count}", flush=True)

    if len(completed_parts) != part_count:
        raise RuntimeError(f"Uploaded {len(completed_parts)} parts; expected {part_count}")

    completed_parts.sort(key=lambda item: item["PartNumber"])
    api("POST", "/s3/multipart/complete", json={
        "key": key, "uploadId": upload_id, "parts": completed_parts,
    })
    return api("POST", "/s3/entries", json={
        "filename": name, "mime": mime, "size": size,
        "extension": extension, "key": key, "workspaceId": 0,
    })


def upload(path: Path) -> dict:
    if not path.is_file():
        raise FileNotFoundError(path)
    return upload_small(path) if path.stat().st_size < CHUNK_SIZE else upload_large(path)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python drime_upload.py <file>")
    file_path = Path(sys.argv[1]).resolve()
    print(f"Uploading to Drime: {file_path.name}", flush=True)
    result = upload(file_path)
    print(f"Upload complete: {file_path.name}", flush=True)
    print(result)
