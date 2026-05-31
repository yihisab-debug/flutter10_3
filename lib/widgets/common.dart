import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GradientHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const GradientHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: padding.add(EdgeInsets.only(top: top)),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class StockBadge extends StatelessWidget {
  const StockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '✓ В наличии',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  const AddButton({super.key, required this.onTap, this.size = 38});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: const Icon(Icons.add, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
