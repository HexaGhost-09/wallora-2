package com.wallora.app

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.hexaghost.wallora/wallpaper_setter"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWallpaper") {
                val filePath = call.argument<String>("filePath")
                val type = call.argument<Int>("type") // 0: Home, 1: Lock, 2: Both
                if (filePath != null && type != null) {
                    setWallpaper(filePath, type, result)
                } else {
                    result.error("INVALID_ARGUMENT", "File path or type is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setWallpaper(filePath: String, type: Int, result: MethodChannel.Result) {
        val wallpaperManager = WallpaperManager.getInstance(applicationContext)
        val file = File(filePath)

        if (!file.exists()) {
            result.error("FILE_NOT_FOUND", "Image file not found at $filePath", null)
            return
        }

        try {
            val bitmap = BitmapFactory.decodeFile(filePath)
            if (bitmap == null) {
                result.error("DECODE_FAILED", "Failed to decode image from $filePath", null)
                return
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val wallpaperType = when (type) {
                    0 -> WallpaperManager.FLAG_SYSTEM
                    1 -> WallpaperManager.FLAG_LOCK
                    2 -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                    else -> WallpaperManager.FLAG_SYSTEM
                }
                wallpaperManager.setBitmap(bitmap, null, true, wallpaperType)
            } else {
                wallpaperManager.setBitmap(bitmap)
            }
            result.success("Wallpaper set successfully!")
        } catch (e: IOException) {
            result.error("SET_FAILED", "Failed to set wallpaper: ${e.message}", e.toString())
        } catch (e: Exception) {
            result.error("UNKNOWN_ERROR", "An unexpected error occurred: ${e.message}", e.toString())
        }
    }
}
