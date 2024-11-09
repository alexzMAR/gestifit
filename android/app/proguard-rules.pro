-ignorewarnings

# Mantener todas las clases relacionadas con TensorFlow Lite GPU
-keep class org.tensorflow.lite.gpu.** { *; }

# Mantener todas las clases relacionadas con TensorFlow
-keep class org.tensorflow.** { *; }

# Mantener todas las clases relacionadas con TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }

# Suprimir advertencias relacionadas con GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

-keep class android.support.v7.widget.** { *; }
-keep class androidx.appcompat.widget.** { *; }


# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend

