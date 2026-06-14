// lib/viewmodels/auth_viewmodel.dart
// MVVM - ViewModel untuk Authentication
// Bertanggung jawab mengelola state login, register, dan user aktif

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthViewModel extends ChangeNotifier {
  // ── State ──
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  Map<String, dynamic>? _userProfile;

  // ── Getters (dibaca oleh View) ──
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String get userName => _userProfile?['fullName'] ?? _currentUser?.displayName ?? 'User';
  String get userEmail => _currentUser?.email ?? '';
  String get userPhone => _userProfile?['phone'] ?? '';

  AuthViewModel() {
    // Inisialisasi: ambil user yang sedang login
    _currentUser = FirebaseService.currentUser;
    if (_currentUser != null) loadUserProfile();
  }

  /// LOGIN - dipanggil dari View (LoginScreen)
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await FirebaseService.login(email: email, password: password);

    if (result['success'] == true) {
      _currentUser = FirebaseService.currentUser;
      await loadUserProfile();
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result['error'];
      _setLoading(false);
      return false;
    }
  }

  /// REGISTER - dipanggil dari View (RegisterScreen)
  Future<bool> register(String fullName, String email, String password, String phone) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await FirebaseService.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );

    if (result['success'] == true) {
      _currentUser = FirebaseService.currentUser;
      await loadUserProfile();
      _setLoading(false);
      return true;
    } else {
      _errorMessage = result['error'];
      _setLoading(false);
      return false;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await FirebaseService.logout();
    _currentUser = null;
    _userProfile = null;
    notifyListeners();
  }

  /// Ambil profil lengkap dari Firestore
  Future<void> loadUserProfile() async {
    final data = await FirebaseService.getUserProfile();
    if (data != null) {
      _userProfile = data;
      notifyListeners();
    }
  }

  /// UPDATE PROFIL - dipanggil dari ProfileTab (Edit Profil)
  Future<bool> updateProfile(String fullName, String phone) async {
    _setLoading(true);
    final ok = await FirebaseService.updateUserProfile(fullName: fullName, phone: phone);
    if (ok) {
      _userProfile = {...?_userProfile, 'fullName': fullName, 'phone': phone};
      // Update display name di Firebase Auth
      await _currentUser?.updateDisplayName(fullName);
    }
    _setLoading(false);
    return ok;
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
