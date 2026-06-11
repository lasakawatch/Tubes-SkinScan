import 'dart:typed_data';

// Stub ML service untuk web (tflite_flutter tidak support web)
class MlService {
  static bool get isModelLoaded => false;
  static Future<bool> initialize() async => false;
  static Future<Map<String, dynamic>> predict(Uint8List imageBytes) async {
    return {'error': 'ML model hanya tersedia di Android'};
  }
  static void dispose() {}
}
