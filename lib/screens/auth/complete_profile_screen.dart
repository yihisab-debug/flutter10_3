import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config.dart';
import '../../data/kz_cities.dart';
import '../../models/app_user.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  final _phone = TextEditingController(text: '+7 ');
  String? _city;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthState>().user;
    _firstName = TextEditingController(text: u?.firstName ?? '');
    _lastName = TextEditingController(text: u?.lastName ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final needCity = AppFlavor.role == UserRole.customer;
    if (_firstName.text.trim().isEmpty ||
        _phone.text.trim().length < 5 ||
        (needCity && (_city == null || _city!.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(needCity
              ? 'Укажите имя, телефон и город'
              : 'Укажите имя и телефон'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    await context.read<AuthState>().completeProfile(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          phone: _phone.text.trim(),
          city: needCity ? _city! : '',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(child: Text('👋', style: TextStyle(fontSize: 56))),
              const SizedBox(height: 12),
              const Center(
                child: Text('Завершите регистрацию',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Заполните данные, чтобы оформлять заказы',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 28),
              _field('Имя', _firstName, hint: 'Айбек'),
              _field('Фамилия', _lastName, hint: 'Осмонов'),
              _field('Телефон', _phone, type: TextInputType.phone),
              if (AppFlavor.role == UserRole.customer)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Город',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _city,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(hintText: 'Выберите город'),
                        items: KzCities.all
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _city = v),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Сохранить и продолжить →'),
              ),
              TextButton(
                onPressed: () => context.read<AuthState>().signOut(),
                child: const Text('Выйти'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {String? hint, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
              controller: c,
              keyboardType: type,
              decoration: InputDecoration(hintText: hint)),
        ],
      ),
    );
  }
}
