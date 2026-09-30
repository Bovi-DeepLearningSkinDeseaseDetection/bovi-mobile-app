# TensorFlow Lite (tflite_flutter): R8 can remove or rename classes loaded
# through JNI, causing release builds to fail on optional GPU delegate classes.
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
