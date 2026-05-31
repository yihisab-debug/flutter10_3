import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'state/auth_state.dart';
import 'state/catalog_state.dart';
import 'theme/app_theme.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    if (!auth.ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isLoggedIn) return const LoginScreen();

    final user = auth.user!;
    if (user.role != AppFlavor.role) {
      return _WrongAppScreen(role: user.role);
    }
    if (!auth.profileComplete) return const CompleteProfileScreen();

    return const AdminShell();
  }
}

class _WrongAppScreen extends StatelessWidget {
  final dynamic role;
  const _WrongAppScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚫', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('Это приложение «\${AppFlavor.title}»',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Этот аккаунт для другого приложения. Войдите подходящим аккаунтом.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<AuthState>().signOut(),
                child: const Text('Выйти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
