# Flutter Play Store deferred components (not used in this app — suppress R8 warnings)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# flutter_local_notifications — keep receivers and models
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Hive — keep generated TypeAdapters
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Timezone data
-keep class org.joda.time.** { *; }

# Flutter engine (covered by flutter default rules, kept here as safety net)
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
