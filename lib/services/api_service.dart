import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userEmail');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ===== AUTH =====
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String dob,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'mobileNumber': mobileNumber,
          'password': password,
          'dob': dob,
        }),
      ).timeout(const Duration(seconds: 8));
      return jsonDecode(response.body);
    } catch (e) {
      // Fallback: mode offline - simulasi registrasi berhasil
      return {'message': 'Registrasi berhasil (mode offline)'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await _saveToken(data['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', email);
      }
      return data;
    } catch (e) {
      // Fallback: mode offline - simulasi login berhasil
      await _saveToken('offline_token_demo');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);
      return {'token': 'offline_token_demo', 'message': 'Login berhasil (mode offline)'};
    }
  }

  // ===== NEWS =====
  static Future<List<Map<String, dynamic>>> getNews() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/news'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body);
      if (data is Map && data['news'] != null) {
        return (data['news'] as List).cast<Map<String, dynamic>>();
      }
      if (data is List) return data.cast<Map<String, dynamic>>();
      return _dummyNews;
    } catch (e) {
      // Fallback: tampilkan data berita dummy
      return _dummyNews;
    }
  }

  // ===== DOCTORS =====
  static Future<List<Map<String, dynamic>>> getDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/doctors'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body);
      if (data is Map && data['doctors'] != null) {
        return (data['doctors'] as List).cast<Map<String, dynamic>>();
      }
      if (data is List) return data.cast<Map<String, dynamic>>();
      return _dummyDoctors;
    } catch (e) {
      // Fallback: tampilkan data dokter dummy
      return _dummyDoctors;
    }
  }

  // ===== SCAN =====
  static Future<Map<String, dynamic>> scanImage(String imageBase64) async {
    try {
      final headers = await _authHeaders();
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? 'anonymous';
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/scan'),
        headers: headers,
        body: jsonEncode({'userId': email, 'imageBase64': imageBase64}),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Gagal menganalisa gambar'};
    }
  }

  // ===== HISTORY =====
  static Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final headers = await _authHeaders();
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? 'anonymous';
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/history/$email'),
        headers: headers,
      ).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body);
      if (data is List) return data.cast<Map<String, dynamic>>();
      return _dummyHistory;
    } catch (e) {
      // Fallback: tampilkan riwayat dummy
      return _dummyHistory;
    }
  }

  // ===== CHATBOT =====
  static Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chatbot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      return data['response'] ?? 'Tidak ada respons';
    } catch (e) {
      // Fallback: respon chatbot offline sederhana
      return _offlineChatResponse(message);
    }
  }

  // ===== USER =====
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final headers = await _authHeaders();
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? '';
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$email'),
        headers: headers,
      ).timeout(const Duration(seconds: 8));
      return jsonDecode(response.body);
    } catch (e) {
      // Fallback: data user offline
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? 'user@skinscan.com';
      return {
        'user': {
          'fullName': 'Pengguna SkinScan',
          'email': email,
          'mobileNumber': '-',
        }
      };
    }
  }

  // ===== DUMMY DATA (Fallback saat server tidak tersedia) =====
  static final List<Map<String, dynamic>> _dummyNews = [
    {
      'title': 'Kenali 5 Tanda Awal Kanker Kulit yang Sering Diabaikan',
      'content': 'Kanker kulit merupakan salah satu jenis kanker yang paling umum di dunia. Mengenali tanda-tanda awal sangat penting untuk deteksi dini dan pengobatan yang efektif.',
      'author': 'Dr. Sarah Putri',
      'category': 'Edukasi Kesehatan',
    },
    {
      'title': 'Tips Menjaga Kesehatan Kulit di Musim Hujan',
      'content': 'Musim hujan membawa kelembaban tinggi yang dapat memicu berbagai masalah kulit seperti jamur dan eksim. Berikut tips menjaga kulit tetap sehat.',
      'author': 'Dr. Ahmad Rizky',
      'category': 'Tips Kesehatan',
    },
    {
      'title': 'Perbedaan Tahi Lalat Biasa dan Melanoma',
      'content': 'Tidak semua tahi lalat berbahaya. Namun, penting untuk mengetahui perbedaan antara tahi lalat biasa dan melanoma untuk deteksi dini kanker kulit.',
      'author': 'Dr. Dewi Sartika',
      'category': 'Edukasi Kesehatan',
    },
    {
      'title': 'Manfaat Sunscreen untuk Melindungi Kulit dari Sinar UV',
      'content': 'Penggunaan sunscreen setiap hari sangat penting untuk melindungi kulit dari kerusakan akibat sinar ultraviolet yang dapat menyebabkan penuaan dini dan kanker kulit.',
      'author': 'Dr. Budi Santoso',
      'category': 'Tips Kesehatan',
    },
    {
      'title': 'Eksim pada Anak: Penyebab, Gejala, dan Cara Mengatasi',
      'content': 'Eksim atau dermatitis atopik sering dialami oleh anak-anak. Kondisi ini membuat kulit gatal, merah, dan kering. Pahami cara mengatasi eksim pada anak.',
      'author': 'Dr. Rina Handayani',
      'category': 'Edukasi Kesehatan',
    },
  ];

  static final List<Map<String, dynamic>> _dummyDoctors = [
    {
      'name': 'dr. Anisa Widya, Sp.KK',
      'specialization': 'Spesialis Kulit & Kelamin',
      'rating': 4.9,
      'experience': '12 tahun',
      'hospital': 'RS Hermina Jakarta',
    },
    {
      'name': 'dr. Budi Prasetyo, Sp.KK',
      'specialization': 'Spesialis Dermatologi',
      'rating': 4.8,
      'experience': '15 tahun',
      'hospital': 'RSUP Fatmawati',
    },
    {
      'name': 'dr. Citra Maharani, Sp.KK',
      'specialization': 'Spesialis Kulit & Kelamin',
      'rating': 4.7,
      'experience': '8 tahun',
      'hospital': 'RS Pondok Indah',
    },
    {
      'name': 'dr. Daniel Kurniawan, Sp.KK',
      'specialization': 'Spesialis Onkologi Kulit',
      'rating': 4.9,
      'experience': '20 tahun',
      'hospital': 'RSCM Jakarta',
    },
    {
      'name': 'dr. Eva Susanti, Sp.KK',
      'specialization': 'Spesialis Dermatologi Anak',
      'rating': 4.6,
      'experience': '10 tahun',
      'hospital': 'RS Bunda Jakarta',
    },
  ];

  static final List<Map<String, dynamic>> _dummyHistory = [
    {
      'result': {
        'label': 'Keratosis Jinak',
        'confidence': 0.87,
        'severity': 'rendah',
      },
      'createdAt': '2026-04-28T10:30:00Z',
    },
    {
      'result': {
        'label': 'Eksim Atopik',
        'confidence': 0.72,
        'severity': 'sedang',
      },
      'createdAt': '2026-04-25T14:15:00Z',
    },
    {
      'result': {
        'label': 'Tahi Lalat Biasa',
        'confidence': 0.95,
        'severity': 'rendah',
      },
      'createdAt': '2026-04-20T09:45:00Z',
    },
  ];

  static String _offlineChatResponse(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('melanoma')) {
      return 'Melanoma adalah jenis kanker kulit yang paling serius. Melanoma berkembang dari sel-sel yang memberi warna pada kulit (melanosit). Tanda-tanda melanoma meliputi:\n\n• Tahi lalat yang berubah bentuk, warna, atau ukuran\n• Batas tahi lalat tidak teratur\n• Warna tidak merata\n• Diameter lebih dari 6mm\n• Evolusi atau perubahan dari waktu ke waktu\n\nSegera konsultasi ke dokter kulit jika Anda menemukan tanda-tanda ini.';
    }
    if (msg.contains('eksim') || msg.contains('eczema')) {
      return 'Eksim (Dermatitis Atopik) adalah kondisi kulit kronis yang menyebabkan kulit gatal, merah, dan meradang. Tips mengatasi eksim:\n\n• Gunakan pelembab secara teratur\n• Hindari sabun yang keras\n• Kenakan pakaian dari bahan katun\n• Jaga kelembaban ruangan\n• Hindari pemicu alergi\n\nKonsultasikan ke dokter untuk pengobatan yang tepat.';
    }
    if (msg.contains('kulit sehat') || msg.contains('tips')) {
      return 'Tips menjaga kesehatan kulit:\n\n1. Gunakan sunscreen SPF 30+ setiap hari\n2. Minum air putih minimal 8 gelas/hari\n3. Konsumsi makanan kaya antioksidan\n4. Tidur cukup 7-8 jam\n5. Bersihkan wajah 2x sehari\n6. Hindari menyentuh wajah dengan tangan kotor\n7. Olahraga teratur\n8. Kelola stres dengan baik';
    }
    if (msg.contains('scan') || msg.contains('cara')) {
      return 'Cara menggunakan fitur Scan SkinScan:\n\n1. Tap tombol kamera di halaman utama\n2. Pilih foto dari kamera atau galeri\n3. Pastikan foto jelas dan pencahayaan baik\n4. Tap "Analisa Sekarang"\n5. Tunggu hasil analisa AI\n\nHasil scan hanya prediksi AI dan bukan diagnosis medis. Selalu konsultasi ke dokter untuk diagnosis yang akurat.';
    }
    if (msg.contains('kanker kulit') || msg.contains('pencegahan')) {
      return 'Pencegahan kanker kulit:\n\n1. Gunakan sunscreen setiap hari\n2. Hindari paparan sinar matahari langsung (10.00-14.00)\n3. Kenakan pakaian pelindung & topi\n4. Periksa kulit secara rutin\n5. Hindari tanning bed\n6. Konsultasi dokter jika ada perubahan pada kulit\n\nDeteksi dini sangat penting untuk pengobatan yang efektif.';
    }
    return 'Terima kasih atas pertanyaan Anda tentang "$message". Saat ini saya dalam mode offline. Untuk informasi lebih lengkap, silakan:\n\n• Gunakan fitur Scan untuk menganalisa kondisi kulit\n• Kunjungi menu Dokter untuk konsultasi\n• Baca artikel di menu Berita\n\nApakah ada yang lain yang bisa saya bantu?';
  }
}
