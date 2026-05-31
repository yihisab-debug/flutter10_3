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
    products = await _repo.fetchProducts();
    loading = false;
    _loaded = true;
    notifyListeners();
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
