import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_state.dart';
import '../../state/reviews_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final reviews = context.watch<ReviewsState>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GradientHeader(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Text(user.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      const Text('Администратор',
                          style: TextStyle(color: Colors.white70)),
                      Text(user.phone,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SoftCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${reviews.openComplaints}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.danger)),
                        const Text('Открытых жалоб',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SoftCard(
              onTap: () => auth.signOut(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: AppColors.danger),
                  SizedBox(width: 14),
                  Text('Выйти',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
