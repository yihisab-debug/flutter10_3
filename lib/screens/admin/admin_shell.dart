import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/reviews_state.dart';
import '../../theme/app_theme.dart';
import 'admin_complaints_screen.dart';
import 'admin_couriers_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_profile_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final open = context.watch<ReviewsState>().openComplaints;
    const pages = [
      AdminComplaintsScreen(),
      AdminOrdersScreen(),
      AdminCouriersScreen(),
      AdminProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
        ),
        child: NavigationBar(
          height: 66,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Badge(
                isLabelVisible: open > 0,
                label: Text('$open'),
                child: const Icon(Icons.report_gmailerrorred,
                    color: AppColors.textSecondary),
              ),
              selectedIcon: Badge(
                isLabelVisible: open > 0,
                label: Text('$open'),
                child: const Icon(Icons.report, color: AppColors.primary),
              ),
              label: 'Жалобы',
            ),
            const NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined,
                  color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.inventory_2, color: AppColors.primary),
              label: 'Заказы',
            ),
            const NavigationDestination(
              icon: Icon(Icons.moped_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.moped, color: AppColors.primary),
              label: 'Курьеры',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
