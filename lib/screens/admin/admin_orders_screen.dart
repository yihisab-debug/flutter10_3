import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/pharmacy_repository.dart';
import '../../models/app_order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('📦 Все заказы',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<List<AppOrder>>(
        stream: PharmacyRepository.instance.streamAllOrders(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? const <AppOrder>[];
          final revenue =
              list.where((o) => !o.refunded).fold<int>(0, (s, o) => s + o.total);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _stat('Заказов', '${list.length}', '📦')),
                  const SizedBox(width: 12),
                  Expanded(child: _stat('Выручка', '$revenue ₸', '💰')),
                ],
              ),
              const SizedBox(height: 16),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('Заказов пока нет',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              else
                ...list.map(_tile),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, String emoji) => SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );

  Widget _tile(AppOrder o) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SoftCard(
          child: Row(
            children: [
              const Text('💊', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.id,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                        '${o.customerName} · ${DateFormat('dd.MM HH:mm').format(o.createdAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    Text('Курьер: ${o.courierName ?? "—"}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${o.total} ₸',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          decoration: o.refunded
                              ? TextDecoration.lineThrough
                              : null,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(o.refunded ? 'Возврат' : o.status.label,
                      style: TextStyle(
                          fontSize: 11,
                          color: o.refunded
                              ? AppColors.danger
                              : AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      );
}
