// lib/viewmodels/history_viewmodel.dart
// MVVM - ViewModel untuk Riwayat Scan
// Mengelola CRUD: Read (load), Delete (hapus item) dari Firestore

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class HistoryViewModel extends ChangeNotifier {
  // ── State ──
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ──
  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalScans => _history.length;

  /// READ - Ambil semua riwayat scan dari Firestore
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await FirebaseService.getScanHistory();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// DELETE - Hapus satu item riwayat scan dari Firestore
  Future<bool> deleteHistory(String docId) async {
    final ok = await FirebaseService.deleteScanHistory(docId);
    if (ok) {
      _history.removeWhere((item) => item['id'] == docId);
      notifyListeners();
    }
    return ok;
  }

  /// Stream real-time (opsional, untuk update otomatis)
  Stream<List<Map<String, dynamic>>> get historyStream =>
      FirebaseService.getScanHistoryStream();
}
