// lib/services/auth_provider.dart
// ─────────────────────────────────────────────
// Authentication state using Provider pattern
// ─────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_helper.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  AppUser? _currentUser;
  bool     _isLoading = false;
  String?  _error;

  AppUser? get currentUser  => _currentUser;
  bool     get isLoading    => _isLoading;
  String?  get error        => _error;
  bool     get isLoggedIn   => _currentUser != null;
  bool     get isAdmin      => _currentUser?.isAdmin ?? false;
  int?     get userId       => _currentUser?.id;

  // ── Restore session on app start ──────────────
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      _currentUser = await _db.getUserById(userId);
      notifyListeners();
    }
  }

  // ── Register ──────────────────────────────────
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final user = AppUser(
        name:         name,
        email:        email.trim().toLowerCase(),
        passwordHash: password, // In production: hash this
      );
      final id = await _db.registerUser(user);
      if (id == -1) return 'An account with this email already exists.';

      _currentUser = user.copyWith(id: id);
      await _saveSession(_currentUser!.id!);
      return null; // success
    } catch (e) {
      return 'Registration failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ─────────────────────────────────────
  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _db.loginUser(
        email.trim().toLowerCase(),
        password,
      );
      if (user == null) return 'Invalid email or password.';
      _currentUser = user;
      await _saveSession(user.id!);
      return null; // success
    } catch (e) {
      return 'Login failed: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  // ── Update profile ────────────────────────────
  Future<String?> updateProfile(AppUser updatedUser) async {
    _setLoading(true);
    try {
      await _db.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Failed to update profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ───────────────────────────────────
  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
