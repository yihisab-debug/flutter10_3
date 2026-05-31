import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/cart_state.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final qty = cart.quantityOf(product.id);

    return SoftCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.emoji, style: const TextStyle(fontSize: 30)),
              if (product.inStock) const StockBadge(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            product.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${product.price} ₸',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              qty == 0
                  ? AddButton(onTap: () => cart.add(product))
                  : _QtyStepper(product: product),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;
  const ProductListTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final qty = cart.quantityOf(product.id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F1F5))),
      ),
      child: Row(
        children: [
          Text(product.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(product.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${product.price} ₸',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          const SizedBox(width: 10),
          qty == 0
              ? AddButton(onTap: () => cart.add(product), size: 34)
              : _QtyStepper(product: product, compact: true),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final Product product;
  final bool compact;
  const _QtyStepper({required this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final qty = cart.quantityOf(product.id);
    final h = compact ? 34.0 : 38.0;
    return Container(
      height: h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _btn(Icons.remove, () => cart.decrement(product)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('$qty',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          _btn(Icons.add, () => cart.add(product)),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}
