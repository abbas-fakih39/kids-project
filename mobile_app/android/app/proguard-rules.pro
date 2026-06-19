# ─── Flutter Stripe: suppress missing push provisioning classes ───
# These classes are referenced by the React Native Stripe SDK
# (bundled inside the Android Stripe SDK) but are not needed
# for Flutter. R8 fails without these rules.
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.**

# Keep Stripe SDK classes that are used
-keep class com.stripe.android.** { *; }
