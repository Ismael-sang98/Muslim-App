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
