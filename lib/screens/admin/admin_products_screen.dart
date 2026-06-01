import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/med_category.dart';
import '../../models/product.dart';
import '../../state/catalog_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _query = '';
  String _categoryId = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogState>().load();
    });
  }

  List<Product> _visible(CatalogState catalog) {
    var list = catalog.products;
    if (_categoryId != 'all') {
      list = list.where((p) => p.categoryId == _categoryId).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.subtitle.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogState>();
    final total = catalog.products.length;
    final outOfStock = catalog.products.where((p) => !p.inStock).length;
    final visible = _visible(catalog);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('🏷️ Товары',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: catalog.loading && catalog.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<CatalogState>().reload(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _stat('Всего товаров', '$total', '📦')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _stat('Нет в наличии', '$outOfStock', '🚫',
                            danger: outOfStock > 0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Поиск товара…',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _categoryChips(catalog.categories),
                  const SizedBox(height: 12),
                  if (visible.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('Ничего не найдено',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    )
                  else
                    ...visible.map((p) => Padding(
                          key: ValueKey(p.id),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProductTile(product: p),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _categoryChips(List<MedCategory> categories) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = categories[i];
          final selected = c.id == _categoryId;
          return ChoiceChip(
            label: Text('${c.emoji} ${c.name}'),
            selected: selected,
            onSelected: (_) => setState(() => _categoryId = c.id),
            showCheckmark: false,
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE3E7F0)),
            ),
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value, String emoji,
          {bool danger = false}) =>
      SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: danger ? AppColors.danger : AppColors.primary)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _ProductTile extends StatefulWidget {
  final Product product;
  const _ProductTile({super.key, required this.product});

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> {
  late bool _inStock;
  late int _price;

  @override
  void initState() {
    super.initState();
    _inStock = widget.product.inStock;
    _price = widget.product.price;
  }

  @override
  void didUpdateWidget(covariant _ProductTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.inStock != widget.product.inStock) {
      _inStock = widget.product.inStock;
    }
    if (oldWidget.product.price != widget.product.price) {
      _price = widget.product.price;
    }
  }

  Future<void> _toggleStock(bool v) async {
    setState(() => _inStock = v); // мгновенно меняем переключатель
    final messenger = ScaffoldMessenger.of(context);
    final catalog = context.read<CatalogState>();
    try {
      await catalog.setProductStock(widget.product.id, v);
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1000),
          content: Text(v
              ? '${widget.product.name}: в наличии'
              : '${widget.product.name}: нет в наличии'),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _inStock = !v); // откат
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 4),
          content: Text('Не удалось сохранить: $e'),
        ),
      );
    }
  }

  Future<void> _editPrice() async {
    final controller = TextEditingController(text: _price.toString());
    final newPrice = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Цена · ${widget.product.name}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Цена', suffixText: '₸'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(96, 44)),
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v >= 0) Navigator.pop(ctx, v);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (newPrice != null && newPrice != _price && mounted) {
      final old = _price;
      setState(() => _price = newPrice); // мгновенно меняем цену
      final messenger = ScaffoldMessenger.of(context);
      final catalog = context.read<CatalogState>();
      try {
        await catalog.updateProductPrice(widget.product.id, newPrice);
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1000),
            content: Text('Цена обновлена: $newPrice ₸'),
          ),
        );
      } catch (e) {
        if (mounted) setState(() => _price = old); // откат
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 4),
            content: Text('Не удалось сохранить: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return SoftCard(
      child: Opacity(
        opacity: _inStock ? 1 : 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(p.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(p.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEDF0F7)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _editPrice,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text('$_price ₸',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.primary)),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit,
                              size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    _inStock ? 'В наличии' : 'Нет в наличии',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _inStock ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: _inStock,
                  activeColor: AppColors.success,
                  onChanged: _toggleStock,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
