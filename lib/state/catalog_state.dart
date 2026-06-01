import 'package:flutter/foundation.dart';

import '../data/pharmacy_repository.dart';
import '../models/med_category.dart';
import '../models/product.dart';

class CatalogState extends ChangeNotifier {
  final PharmacyRepository _repo = PharmacyRepository.instance;

  List<MedCategory> categories = [];
  List<Product> products = [];
  bool loading = false;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    loading = true;
    notifyListeners();
    categories = await _repo.fetchCategories();
    try {
      await _repo.seedProductsIfEmpty();
    } catch (_) {/* нет прав на запись — покажем при первой правке */}
    products = await _repo.fetchProducts();
    loading = false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _loaded = false;
    await load();
  }

  Future<void> updateProductPrice(String productId, int price) async {
    final i = products.indexWhere((p) => p.id == productId);
    if (i == -1) return;
    products[i] = products[i].copyWith(price: price);
    notifyListeners();
    await _repo.saveProduct(products[i]);
  }

  Future<void> setProductStock(String productId, bool inStock) async {
    final i = products.indexWhere((p) => p.id == productId);
    if (i == -1) return;
    products[i] = products[i].copyWith(inStock: inStock);
    notifyListeners();
    await _repo.saveProduct(products[i]);
  }

  List<Product> get popular => products.where((p) => p.popular).toList();

  List<Product> byCategory(String categoryId) {
    if (categoryId == 'all') return products;
    return products.where((p) => p.categoryId == categoryId).toList();
  }

  List<Product> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.subtitle.toLowerCase().contains(q))
        .toList();
  }
}
