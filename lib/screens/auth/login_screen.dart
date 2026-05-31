import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config.dart';
import '../../models/app_user.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _google(BuildContext context) async {
    final auth = context.read<AuthState>();
    final ok = await auth.signInWithGoogle(role: AppFlavor.role);
    if (!ok && context.mounted) _err(context, auth.error);
  }

  Future<void> _testAccount(BuildContext context) async {
    final auth = context.read<AuthState>();
    final ok = await auth.testGoogleSignIn(role: AppFlavor.role);
    if (!ok && context.mounted) _err(context, auth.error);
  }

  void _err(BuildContext context, String? m) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(m ?? 'Ошибка'), backgroundColor: AppColors.danger),
      );

  String get _testLabel => switch (AppFlavor.role) {
        UserRole.courier => 'Тест Курьер',
        UserRole.admin => 'Тест Админ',
        UserRole.customer => 'Тест Клиент',
      };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final roleEmoji = switch (AppFlavor.role) {
      UserRole.courier => '🛵',
      UserRole.admin => '🛡️',
      UserRole.customer => '💊',
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Center(
                  child: Text(roleEmoji, style: const TextStyle(fontSize: 64))),
              const SizedBox(height: 12),
              Center(
                child: Text(AppFlavor.title,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Войдите, чтобы продолжить',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 40),

              ElevatedButton.icon(
                onPressed: auth.loading ? null : () => _google(context),
                icon: const Text('G',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 18)),
                label: const Text('Войти через Google'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Откроется выбор Google-аккаунта. Для нового аккаунта — регистрация (имя, фамилия, телефон, город).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 28),
              Row(children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('или',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 20),

              const Text('Готовый аккаунт для теста',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: .5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: auth.loading ? null : () => _testAccount(context),
                icon: const Icon(Icons.flash_on, size: 18),
                label: Text('Войти как «$_testLabel»'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFE3E7F0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),

              if (auth.loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
