// lib/services/firebase_service.dart
// Implementasi Firebase: Authentication + Cloud Firestore
// Materi Kuliah: Data Storage Part 4

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class untuk semua operasi Firebase
/// Mencakup: Authentication dan Firestore Database
class FirebaseService {
  // ==========================================
  // 1. FIREBASE AUTHENTICATION
  // ==========================================
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mendapatkan user yang sedang login
  static User? get currentUser => _auth.currentUser;

  /// Stream status autentikasi (login/logout)
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// REGISTER - Daftar akun baru dengan email & password
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      // Buat akun di Firebase Authentication
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name di Firebase Auth
      await credential.user?.updateDisplayName(fullName);

      // Simpan data user lengkap ke Firestore
      await _saveUserToFirestore(
        uid: credential.user!.uid,
        fullName: fullName,
        email: email,
        phone: phone ?? '',
      );

      return {
        'success': true,
        'uid': credential.user?.uid,
        'message': 'Registrasi berhasil!',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Terjadi kesalahan: $e',
      };
    }
  }

  /// LOGIN - Masuk dengan email & password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'uid': credential.user?.uid,
        'email': credential.user?.email,
        'displayName': credential.user?.displayName,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Gagal login: $e',
      };
    }
  }

  /// LOGOUT - Keluar dari akun
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Mendapatkan pesan error yang user-friendly
  static String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah (min. 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan autentikasi ($code)';
    }
  }

  // ==========================================
  // 2. CLOUD FIRESTORE - DATABASE
  // ==========================================
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Menyimpan data user ke koleksi 'users' di Firestore
  static Future<void> _saveUserToFirestore({
    required String uid,
    required String fullName,
    required String email,
    String phone = '',
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mengambil data profil user dari Firestore
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update data profil user di Firestore
  static Future<bool> updateUserProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return false;

      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (fullName != null) updates['fullName'] = fullName;
      if (phone != null) updates['phone'] = phone;

      await _firestore.collection('users').doc(uid).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 3. FIRESTORE - RIWAYAT SCAN
  // ==========================================

  /// Menyimpan hasil scan ke koleksi 'scan_history' di Firestore
  static Future<bool> saveScanHistory({
    required String label,
    required double confidence,
    required String severity,
    String? description,
  }) async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return false;

      await _firestore.collection('scan_history').add({
        'userId': uid,
        'result': {
          'label': label,
          'confidence': confidence,
          'severity': severity,
          'description': description ?? '',
        },
        'scannedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mengambil riwayat scan user dari Firestore
  /// Sort dilakukan client-side untuk menghindari kebutuhan composite index
  static Future<List<Map<String, dynamic>>> getScanHistory() async {
    try {
      final uid = currentUser?.uid;
      if (uid == null) return [];

      // Query tanpa orderBy agar tidak perlu composite index di Firestore
      final snapshot = await _firestore
          .collection('scan_history')
          .where('userId', isEqualTo: uid)
          .limit(50)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort client-side: terbaru di atas
      list.sort((a, b) {
        final aTime = a['scannedAt'];
        final bTime = b['scannedAt'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        // Firestore Timestamp comparison
        try {
          return bTime.compareTo(aTime);
        } catch (_) {
          return 0;
        }
      });

      return list;
    } catch (e) {
      return [];
    }
  }

  /// Stream real-time riwayat scan (auto-update saat ada perubahan)
  static Stream<List<Map<String, dynamic>>> getScanHistoryStream() {
    final uid = currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('scan_history')
        .where('userId', isEqualTo: uid)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          // Sort client-side
          list.sort((a, b) {
            try { return b['scannedAt'].compareTo(a['scannedAt']); }
            catch (_) { return 0; }
          });
          return list;
        });
  }

  /// Menghapus item riwayat scan dari Firestore
  static Future<bool> deleteScanHistory(String docId) async {
    try {
      await _firestore.collection('scan_history').doc(docId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // 4. FIRESTORE - BERITA (READ ONLY)
  // ==========================================

  /// Mengambil daftar berita kesehatan dari Firestore
  static Future<List<Map<String, dynamic>>> getNewsFromFirestore() async {
    try {
      final snapshot = await _firestore
          .collection('news')
          .orderBy('publishedAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
