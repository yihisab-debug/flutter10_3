import 'package:flutter/material.dart';

import '../../data/pharmacy_repository.dart';
import '../../models/app_user.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminCouriersScreen extends StatelessWidget {
  const AdminCouriersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('🛵 Курьеры',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: PharmacyRepository.instance.streamCouriers(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final couriers = snap.data ?? const <AppUser>[];
          if (couriers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                    'Курьеров пока нет.\nОни появятся после регистрации в приложении курьера.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: couriers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _card(couriers[i]),
          );
        },
      ),
    );
  }

  Widget _card(AppUser c) {
    return SoftCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(c.initials,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(c.phone,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: AppColors.star),
                  const SizedBox(width: 2),
                  Text(c.rating == 0 ? '—' : c.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 2),
              Text('${c.deliveriesDone} доставок',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
