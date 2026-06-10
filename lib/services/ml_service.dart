import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:ui' as ui;

class MlService {
  static Interpreter? _interpreter;
  static List<String> _labels = [];
  static bool _initialized = false;
  static int _inputSize = 224;

  static const List<String> fallbackLabels = [
    'Kanker Kulit dan Lesi Akibat Sinar Matahari',
    'Melanoma (Kanker Kulit Berbahaya)',
    'Eksim Atopik (Dermatitis Atopik)',
    'Karsinoma Sel Basal',
    'Tahi Lalat (Nevus Melanositik)',
    'Lesi Keratosis Jinak',
    'Psoriasis dan Penyakit Kulit Terkait',
    'Keratosis Seboroik dan Tumor Jinak Lainnya',
    'Infeksi Jamur (Kurap, Kandidiasis, dll.)',
    'Infeksi Virus (Kutil, Molluscum, dll.)',
  ];

  static const Map<String, Map<String, dynamic>> diseaseInfo = {
    'Kanker Kulit dan Lesi Akibat Sinar Matahari': {
      'severity': 'Tinggi',
      'description': 'Kanker kulit akibat paparan sinar UV berlebihan. Termasuk keratosis aktinik dan karsinoma sel skuamosa. Sering muncul di area yang terpapar matahari seperti wajah, leher, dan tangan.',
      'recommendations': ['Segera konsultasi dokter spesialis kulit', 'Hindari paparan matahari langsung pukul 10.00-16.00', 'Gunakan tabir surya SPF 50+ setiap hari', 'Lakukan pemeriksaan kulit rutin setiap 3-6 bulan'],
    },
    'Melanoma (Kanker Kulit Berbahaya)': {
      'severity': 'Sangat Tinggi',
      'description': 'Jenis kanker kulit paling agresif yang berkembang dari sel melanosit. Deteksi dini sangat penting karena dapat menyebar ke organ lain. Tingkat kesembuhan >95% jika terdeteksi di stadium awal.',
      'recommendations': ['SEGERA kunjungi dokter spesialis kulit atau rumah sakit', 'Jangan menunda pemeriksaan - deteksi dini sangat penting', 'Dokumentasikan perubahan pada lesi dengan foto berkala', 'Tanyakan tentang pemeriksaan dermoskopi dan biopsi'],
    },
    'Eksim Atopik (Dermatitis Atopik)': {
      'severity': 'Sedang',
      'description': 'Kondisi kulit kronis yang menyebabkan kulit merah, gatal, kering, dan meradang. Sering terjadi pada lipatan kulit dan berkaitan dengan alergi.',
      'recommendations': ['Gunakan pelembap secara rutin minimal 2 kali sehari', 'Hindari sabun keras dan deterjen yang mengiritasi', 'Kenakan pakaian berbahan katun yang lembut', 'Konsultasi dokter untuk krim kortikosteroid jika diperlukan'],
    },
    'Karsinoma Sel Basal': {
      'severity': 'Tinggi',
      'description': 'Jenis kanker kulit paling umum namun paling tidak agresif. Tumbuh lambat dan jarang menyebar. Biasanya muncul sebagai benjolan berkilau atau luka yang tidak sembuh.',
      'recommendations': ['Konsultasi dokter spesialis kulit untuk evaluasi', 'Pengobatan melalui pembedahan minor dengan tingkat kesembuhan tinggi', 'Lakukan pemeriksaan kulit rutin setelah pengobatan', 'Gunakan tabir surya setiap hari'],
    },
    'Tahi Lalat (Nevus Melanositik)': {
      'severity': 'Rendah',
      'description': 'Pertumbuhan kulit jinak dari kumpulan melanosit. Umumnya tidak berbahaya, namun perlu dipantau perubahannya dengan metode ABCDE.',
      'recommendations': ['Pantau perubahan menggunakan metode ABCDE', 'Foto tahi lalat berkala untuk perbandingan', 'Konsultasi dokter jika berubah ukuran, bentuk, atau warna', 'Pemeriksaan kulit profesional setahun sekali'],
    },
    'Lesi Keratosis Jinak': {
      'severity': 'Rendah',
      'description': 'Pertumbuhan kulit jinak berupa bercak tebal dan kasar pada permukaan kulit. Umumnya tidak berbahaya dan tidak memerlukan pengobatan medis.',
      'recommendations': ['Umumnya tidak memerlukan pengobatan khusus', 'Konsultasi jika lesi berubah atau mengganggu', 'Jaga kelembapan kulit dengan pelembap yang tepat', 'Jangan menggaruk atau menghilangkan sendiri'],
    },
    'Psoriasis dan Penyakit Kulit Terkait': {
      'severity': 'Sedang',
      'description': 'Penyakit autoimun kronis yang menyebabkan sel kulit berkembang terlalu cepat, menghasilkan bercak tebal, merah, dan bersisik perak. Tidak menular.',
      'recommendations': ['Konsultasi dokter spesialis kulit untuk rencana pengobatan', 'Gunakan pelembap secara teratur', 'Kelola stres karena dapat memperburuk kondisi', 'Pertimbangkan fototerapi jika direkomendasikan dokter'],
    },
    'Keratosis Seboroik dan Tumor Jinak Lainnya': {
      'severity': 'Rendah',
      'description': 'Pertumbuhan kulit jinak yang umum pada usia di atas 50 tahun. Tampak seperti bercak cokelat/hitam "menempel" pada kulit. Tidak berbahaya.',
      'recommendations': ['Tidak memerlukan pengobatan jika tidak mengganggu', 'Konsultasi untuk membedakan dari lesi serius', 'Hindari iritasi pada area terkena', 'Periksakan jika pertumbuhan berubah cepat atau berdarah'],
    },
    'Infeksi Jamur (Kurap, Kandidiasis, dll.)': {
      'severity': 'Rendah - Sedang',
      'description': 'Infeksi kulit oleh jamur, sangat umum di Indonesia karena iklim tropis. Termasuk kurap (tinea), kandidiasis, dan panu.',
      'recommendations': ['Gunakan krim antijamur sesuai petunjuk', 'Jaga area terkena tetap bersih dan kering', 'Kenakan pakaian longgar berbahan katun', 'Konsultasi dokter jika tidak membaik dalam 2 minggu'],
    },
    'Infeksi Virus (Kutil, Molluscum, dll.)': {
      'severity': 'Rendah',
      'description': 'Infeksi kulit oleh virus. Kutil dari HPV dan molluscum dari poxvirus. Menular melalui kontak langsung.',
      'recommendations': ['Biasanya hilang sendiri dalam beberapa bulan', 'Hindari menyentuh, menggaruk, atau memencet lesi', 'Jaga kebersihan tangan', 'Konsultasi dokter untuk krioterapi jika diperlukan'],
    },
  };

  static Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      // Load labels
      final labelsData = await rootBundle.loadString('assets/ml/labels.txt');
      _labels = labelsData.split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (_labels.isEmpty) _labels = fallbackLabels;

      // Load TFLite model
      _interpreter = await Interpreter.fromAsset('ml/skin_disease_model.tflite');

      // Get input shape from model
      final inputTensor = _interpreter!.getInputTensor(0);
      final inputShape = inputTensor.shape;
      if (inputShape.length >= 3) {
        _inputSize = inputShape[1]; // [1, height, width, channels]
      }

      _initialized = true;
      return true;
    } catch (e) {
      _labels = fallbackLabels;
      _initialized = false;
      return false;
    }
  }

  static bool get isModelLoaded => _initialized && _interpreter != null;

  /// Run inference pada image bytes (JPEG/PNG dari kamera/galeri)
  static Future<Map<String, dynamic>> predict(Uint8List imageBytes) async {
    if (!isModelLoaded) {
      await initialize();
    }
    if (!isModelLoaded) {
      return {'error': 'Model tidak tersedia'};
    }

    try {
      // Decode & resize image ke ukuran yang model butuhkan
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: _inputSize,
        targetHeight: _inputSize,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Get pixel data sebagai RGBA
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (byteData == null) return {'error': 'Gagal memproses gambar'};

      final rgbaBytes = byteData.buffer.asUint8List();
      final numPixels = _inputSize * _inputSize;

      // Cek input type model
      final inputTensor = _interpreter!.getInputTensor(0);
      final inputType = inputTensor.type;

      // Prepare input sesuai type model
      Object input;
      if (inputType == TensorType.uint8) {
        // Model expects UINT8 [0-255] — sesuai app Kotlin asli
        final uint8Input = Uint8List(numPixels * 3);
        for (int i = 0; i < numPixels; i++) {
          uint8Input[i * 3] = rgbaBytes[i * 4];         // R
          uint8Input[i * 3 + 1] = rgbaBytes[i * 4 + 1]; // G
          uint8Input[i * 3 + 2] = rgbaBytes[i * 4 + 2]; // B
        }
        input = uint8Input.reshape([1, _inputSize, _inputSize, 3]);
      } else {
        // Model expects FLOAT32 [0.0-1.0]
        final float32Input = Float32List(numPixels * 3);
        for (int i = 0; i < numPixels; i++) {
          float32Input[i * 3] = rgbaBytes[i * 4] / 255.0;
          float32Input[i * 3 + 1] = rgbaBytes[i * 4 + 1] / 255.0;
          float32Input[i * 3 + 2] = rgbaBytes[i * 4 + 2] / 255.0;
        }
        input = float32Input.reshape([1, _inputSize, _inputSize, 3]);
      }

      // Cek output type + shape
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputType = outputTensor.type;
      final numClasses = outputTensor.shape.last;

      // Prepare output sesuai type
      Object output;
      if (outputType == TensorType.uint8) {
        output = Uint8List(numClasses).reshape([1, numClasses]);
      } else {
        output = Float32List(numClasses).reshape([1, numClasses]);
      }

      // Run inference!
      _interpreter!.run(input, output);

      // Parse output scores ke List<double>
      List<double> scores;
      final rawOutput = (output as List)[0];
      if (rawOutput is Uint8List) {
        // Dequantize: score = (value - zeroPoint) * scale
        final params = outputTensor.params;
        scores = rawOutput.map((v) => (v - params.zeroPoint) * params.scale).toList();
      } else if (rawOutput is List<int>) {
        final params = outputTensor.params;
        scores = rawOutput.map((v) => (v - params.zeroPoint) * params.scale).toList();
      } else {
        scores = (rawOutput as List).map((v) => (v as num).toDouble()).toList();
      }

      // Apply softmax if scores don't sum to ~1
      final sum = scores.fold<double>(0, (s, v) => s + v);
      if (sum < 0.9 || sum > 1.1) {
        // Probably logits, apply softmax
        final maxVal = scores.reduce((a, b) => a > b ? a : b);
        final expScores = scores.map((s) => _exp(s - maxVal)).toList();
        final expSum = expScores.fold<double>(0, (s, v) => s + v);
        scores = expScores.map((s) => s / expSum).toList();
      }

      // Find best prediction
      int maxIdx = 0;
      double maxScore = scores[0];
      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIdx = i;
        }
      }

      // Make sure label index is valid
      final labelIdx = maxIdx < _labels.length ? maxIdx : 0;
      final label = _labels[labelIdx];
      final info = diseaseInfo[label] ?? {};

      return {
        'label': label,
        'confidence': maxScore,
        'severity': info['severity'] ?? 'Unknown',
        'description': info['description'] ?? '',
        'recommendations': info['recommendations'] ?? [],
        'allPredictions': List.generate(
          scores.length > _labels.length ? _labels.length : scores.length,
          (i) => {'label': _labels[i], 'confidence': scores[i]},
        )..sort((a, b) => ((b['confidence'] ?? 0) as double).compareTo((a['confidence'] ?? 0) as double)),
        'source': 'on-device-tflite',
      };
    } catch (e) {
      return {'error': 'Gagal menjalankan model: $e'};
    }
  }

  static double _exp(double x) {
    // Capped exp to prevent overflow
    if (x > 80) return 5.54e34;
    if (x < -80) return 0;
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 20; i++) {
      term *= x / i;
      result += term;
    }
    return result;
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _initialized = false;
  }
}
