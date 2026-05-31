import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import '../config.dart';
import '../models/app_user.dart';

class AuthResult {
  final AppUser? user;
  final String? error;
  const AuthResult.success(this.user) : error = null;
  const AuthResult.failure(this.error) : user = null;
  bool get ok => user != null;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final GoogleSignIn _google = GoogleSignIn();

  static final Map<String, _MockAccount> _mockAccounts = {
    AppConfig.demoUserEmail: _MockAccount(
      AppConfig.demoPassword,
      const AppUser(
        uid: 'mock-user',
        email: AppConfig.demoUserEmail,
        firstName: 'Айбек',
        lastName: 'Осмонов',
        phone: '+7 700 123 45 67',
        city: 'Алматы',
        role: UserRole.customer,
        bonusPoints: 0,
        totalSpent: 0,
      ),
    ),
    AppConfig.demoCourierEmail: _MockAccount(
      AppConfig.demoPassword,
      const AppUser(
        uid: 'mock-courier',
        email: AppConfig.demoCourierEmail,
        firstName: 'Бекзод',
        lastName: 'Тураев',
        phone: '+7 555 000 00 11',
        city: 'Алматы',
        role: UserRole.courier,
        bonusPoints: 0,
        rating: 0,
        deliveriesDone: 0,
      ),
    ),
    AppConfig.demoAdminEmail: _MockAccount(
      AppConfig.demoPassword,
      const AppUser(
        uid: 'mock-admin',
        email: AppConfig.demoAdminEmail,
        firstName: 'Админ',
        lastName: 'Аптеки',
        phone: '+7 555 111 22 33',
        city: 'Алматы',
        role: UserRole.admin,
      ),
    ),
  };

  Future<AuthResult> signIn(String email, String password) async {
    email = email.trim().toLowerCase();
    if (!AppConfig.useFirebase) {
      await Future.delayed(const Duration(milliseconds: 400));
      final acc = _mockAccounts[email];
      if (acc == null) return const AuthResult.failure('Аккаунт не найден');
      if (acc.password != password) {
        return const AuthResult.failure('Неверный пароль');
      }
      return AuthResult.success(acc.user);
    }
    try {
      final cred = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return AuthResult.success(await _loadOrCreateProfile(cred.user!));
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendly(e));
    } catch (e) {
      return AuthResult.failure('Ошибка: $e');
    }
  }

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String city,
    required String email,
    required String password,
    UserRole role = UserRole.customer,
  }) async {
    email = email.trim().toLowerCase();
    if (!AppConfig.useFirebase) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (_mockAccounts.containsKey(email)) {
        return const AuthResult.failure('Такой email уже зарегистрирован');
      }
      final user = AppUser(
        uid: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        city: city,
        role: role,
      );
      _mockAccounts[email] = _MockAccount(password, user);
      return AuthResult.success(user);
    }
    try {
      final cred = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = AppUser(
        uid: cred.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        city: city,
        role: role,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
      return AuthResult.success(user);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendly(e));
    } catch (e) {
      return AuthResult.failure('Ошибка: $e');
    }
  }

  Future<AuthResult> signInWithGoogle({UserRole role = UserRole.customer}) async {
    if (!AppConfig.useFirebase) {
      await Future.delayed(const Duration(milliseconds: 500));
      final user = AppUser(
        uid: 'mock-google-${role.name}',
        email: 'google.user@gmail.com',
        firstName: 'Гость',
        lastName: '',
        phone: '',
        city: '',
        role: role,
      );
      return AuthResult.success(user);
    }
    try {
      final account = await _google.signIn();
      if (account == null) return const AuthResult.failure('Отменено');
      final auth = await account.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final cred =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      return AuthResult.success(await _loadOrCreateProfile(cred.user!, role));
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendly(e));
    } catch (e) {
      return AuthResult.failure('Ошибка входа через Google: $e');
    }
  }

  Future<AuthResult> testGoogleSignIn({
    required UserRole role,
    bool newUser = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (newUser) {
      return AuthResult.success(AppUser(
        uid: 'test-google-new-${role.name}',
        email: 'new.user@gmail.com',
        firstName: '',
        lastName: '',
        phone: '',
        city: '',
        role: role,
      ));
    }
    switch (role) {
      case UserRole.customer:
        return const AuthResult.success(AppUser(
          uid: 'test-google-customer',
          email: 'client.test@gmail.com',
          firstName: 'Тест',
          lastName: 'Клиент',
          phone: '+7 700 000 00 01',
          city: 'Алматы',
          role: UserRole.customer,
          bonusPoints: 0,
          totalSpent: 0,
        ));
      case UserRole.courier:
        return const AuthResult.success(AppUser(
          uid: 'test-google-courier',
          email: 'courier.test@gmail.com',
          firstName: 'Тест',
          lastName: 'Курьер',
          phone: '+7 700 000 00 02',
          city: 'Алматы',
          role: UserRole.courier,
          rating: 0,
          deliveriesDone: 0,
        ));
      case UserRole.admin:
        return const AuthResult.success(AppUser(
          uid: 'test-google-admin',
          email: 'admin.test@gmail.com',
          firstName: 'Тест',
          lastName: 'Админ',
          phone: '+7 700 000 00 03',
          city: 'Алматы',
          role: UserRole.admin,
        ));
    }
  }

  Future<AppUser> saveProfile(AppUser user) async {
    if (AppConfig.useFirebase) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
    } else {
      final entry = _mockAccounts[user.email];
      if (entry != null) {
        _mockAccounts[user.email] = _MockAccount(entry.password, user);
      }
    }
    return user;
  }

  Future<void> signOut() async {
    if (AppConfig.useFirebase) {
      await _google.signOut();
      await fb.FirebaseAuth.instance.signOut();
    }
  }

  Future<AppUser> _loadOrCreateProfile(fb.User fbUser,
      [UserRole role = UserRole.customer]) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(fbUser.uid);
    final snap = await doc.get();
    if (snap.exists) {
      return AppUser.fromMap(fbUser.uid, snap.data()!);
    }
    final display = (fbUser.displayName ?? '').trim().split(RegExp(r'\s+'));
    final user = AppUser(
      uid: fbUser.uid,
      email: fbUser.email ?? '',
      firstName: display.isNotEmpty ? display.first : '',
      lastName: display.length > 1 ? display.sublist(1).join(' ') : '',
      phone: fbUser.phoneNumber ?? '',
      city: '',
      role: role,
    );
    await doc.set(user.toMap());
    return user;
  }

  String _friendly(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Аккаунт не найден';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный email или пароль';
      case 'email-already-in-use':
        return 'Такой email уже зарегистрирован';
      case 'weak-password':
        return 'Слишком простой пароль (мин. 6 символов)';
      case 'invalid-email':
        return 'Неверный email';
      default:
        return e.message ?? 'Ошибка авторизации';
    }
  }
}

class _MockAccount {
  final String password;
  final AppUser user;
  const _MockAccount(this.password, this.user);
}
