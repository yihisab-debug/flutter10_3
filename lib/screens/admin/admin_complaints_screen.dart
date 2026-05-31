import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/pharmacy_repository.dart';
import '../../models/review.dart';
import '../../state/reviews_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminComplaintsScreen extends StatelessWidget {
  const AdminComplaintsScreen({super.key});

  Future<void> _resolve(BuildContext context, Review c, bool approved) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(approved ? 'Одобрить жалобу?' : 'Отклонить жалобу?'),
        content: Text(approved
            ? 'Заказ ${c.orderId}: деньги вернутся на баланс клиента ${c.customerName}.'
            : 'Заказ ${c.orderId}: жалоба будет отклонена, возврата не будет.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      approved ? AppColors.success : AppColors.danger),
              child: Text(approved ? 'Вернуть деньги' : 'Отклонить')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<ReviewsState>().resolve(c, approved);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(approved
                  ? 'Деньги по заказу ${c.orderId} возвращены клиенту'
                  : 'Жалоба по заказу ${c.orderId} отклонена'),
              backgroundColor:
                  approved ? AppColors.success : AppColors.textSecondary),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('🛡️ Жалобы',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<List<Review>>(
        stream: PharmacyRepository.instance.streamComplaints(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? const <Review>[];
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Жалоб нет',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _card(context, list[i]),
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, Review c) {
    final open = c.status == ComplaintStatus.open;
    final approved = c.status == ComplaintStatus.approved;
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Заказ ${c.orderId}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: open
                      ? const Color(0xFFFFF1D6)
                      : approved
                          ? AppColors.successBg
                          : const Color(0xFFEDEFF3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c.statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: open
                            ? const Color(0xFFB8860B)
                            : approved
                                ? AppColors.success
                                : AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Клиент: ${c.customerName}',
              style: const TextStyle(color: AppColors.textSecondary)),
          Row(
            children: [
              Text('Курьер: ${c.courierName}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Row(
                  children: List.generate(
                      5,
                      (i) => Icon(
                          i < c.rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: AppColors.star))),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.comment.isEmpty ? '(без комментария)' : c.comment,
              style: const TextStyle(height: 1.3)),
          const SizedBox(height: 6),
          Text(DateFormat('dd.MM.yyyy HH:mm').format(c.createdAt),
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          if (open) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _resolve(context, c, true),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Разрешить'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        backgroundColor: AppColors.success),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resolve(context, c, false),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Отклонить'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: Color(0xFFF3D2D2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
