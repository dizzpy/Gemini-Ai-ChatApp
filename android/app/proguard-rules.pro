# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Play Core and Play Services classes
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.tasks.**

# Keep Flutter deferred components classes
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Keep classes that use reflection
-keepclassmembers class * {
    @com.google.android.gms.common.annotation.KeepForSdk *;
}

# If you're using any other Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**