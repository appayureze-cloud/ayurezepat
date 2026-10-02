# Keep annotations
-keepattributes *Annotation*

# Keep Parcelable classes
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Flutter integration
-keep class io.flutter.** { *; }

# Keep necessary dependencies
-keep class com.smart_auth.** { *; }
-keep class com.flutter_tts.** { *; }

# Google Play Services & Authentication
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.** { *; }

# Keep Retrofit, Gson, and OkHttp dependencies
-dontwarn okhttp3.**
-dontwarn org.conscrypt.**
-dontwarn retrofit2.**  
-dontwarn com.google.gson.**  
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }

# Razorpay SDK
-keep class com.razorpay.** { *; }
-keep class com.razorpay.AnalyticsEvent { *; }
-keepclassmembers class com.razorpay.** {
    @Keep <methods>;
    @KeepClassMembers <methods>;
}

# Play Store Split Install
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }

# Prevent minification of JavaScript interface methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep Razorpay Google Pay Integration
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.Wallet
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils

# Keep Google Play Core Split Install classes
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

# Keep ProGuard annotations
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers
