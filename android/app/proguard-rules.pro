# Suppress warnings for missing classes
-dontwarn javax.annotation.Nullable
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.OpenSSLProvider

# Keep OkHttp classes
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep Picasso classes (used by async_wallpaper)
-keep class com.squareup.picasso.** { *; }
-dontwarn com.squareup.picasso.**
