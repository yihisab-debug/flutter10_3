import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pharmacy_repository.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthState extends ChangeNotifier {
  final AuthService _auth = AuthService.instance;
  static const _prefsKey = 'auth_user';

  AppUser? _user;
  bool _loading = false;
  bool _ready = false;
  String? _error;

  AuthState() {
    _restore();
  }

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  bool get ready => _ready;
  String? get error => _error;
  bool get isCourier => _user?.role == UserRole.courier;
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get profileComplete => _user?.profileComplete ?? false;

  Future<void> _restore() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_prefsKey);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _user = AppUser.fromMap(m['uid'] as String? ?? '', m);
      }
    } catch (_) {}
    _ready = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      if (_user == null) {
        await p.remove(_prefsKey);
      } else {
        final m = _user!.toMap();
        m['uid'] = _user!.uid;
        await p.setString(_prefsKey, jsonEncode(m));
      }
    } catch (_) {}
  }

  void _setLoading(bool v) {
    _loading = v;
    if (v) _error = null;
    notifyListeners();
  }

  Future<void> _onLoggedIn(AppUser u) async {
    _user = u;
    if (u.profileComplete) PharmacyRepository.instance.saveUser(u);
    await _persist();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    final res = await _auth.signIn(email, password);
    _loading = false;
    if (res.ok) {
      await _onLoggedIn(res.user!);
    } else {
      _error = res.error;
    }
    notifyListeners();
    return res.ok;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String email,
    required String password,
    UserRole role = UserRole.customer,
  }) async {
    _setLoading(true);
    final res = await _auth.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
      email: email,
      password: password,
      role: role,
    );
    _loading = false;
    if (res.ok) {
      await _onLoggedIn(res.user!);
    } else {
      _error = res.error;
    }
    notifyListeners();
    return res.ok;
  }

  Future<bool> signInWithGoogle({UserRole role = UserRole.customer}) async {
    _setLoading(true);
    final res = await _auth.signInWithGoogle(role: role);
    _loading = false;
    if (res.ok) {
      await _onLoggedIn(res.user!);
    } else {
      _error = res.error;
    }
    notifyListeners();
    return res.ok;
  }

  Future<bool> testGoogleSignIn({
    required UserRole role,
    bool newUser = false,
  }) async {
    _setLoading(true);
    final res = await _auth.testGoogleSignIn(role: role, newUser: newUser);
    _loading = false;
    if (res.ok) {
      await _onLoggedIn(res.user!);
    } else {
      _error = res.error;
    }
    notifyListeners();
    return res.ok;
  }

  Future<void> completeProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
  }) async {
    if (_user == null) return;
    final updated = _user!.copyWith(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      city: city,
    );
    _user = await _auth.saveProfile(updated);
    PharmacyRepository.instance.saveUser(_user!);
    await _persist();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    await _persist();
    notifyListeners();
  }

  Future<void> spend(int amount) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      balance: _user!.balance - amount,
      totalSpent: _user!.totalSpent + amount,
      bonusPoints: _user!.bonusPoints + (amount ~/ 10),
    );
    notifyListeners();
    await _auth.saveProfile(_user!);
    await _persist();
  }

  Future<void> topUp([int amount = 10000]) async {
    if (_user == null) return;
    _user = _user!.copyWith(balance: _user!.balance + amount);
    notifyListeners();
    await _auth.saveProfile(_user!);
    await _persist();
  }

  Future<void> reloadUser() async {
    if (_user == null) return;
    final fresh = await PharmacyRepository.instance.fetchUser(_user!.uid);
    if (fresh != null) {
      _user = fresh;
      await _persist();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
