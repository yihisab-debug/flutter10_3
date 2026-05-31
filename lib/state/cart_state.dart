import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartState extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;

  int get count =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  int get total =>
      _items.values.fold(0, (sum, item) => sum + item.lineTotal);

  int quantityOf(String productId) => _items[productId]?.quantity ?? 0;

  void add(Product product) {
    final existing = _items[product.id];
    if (existing != null) {
      existing.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void decrement(Product product) {
    final existing = _items[product.id];
    if (existing == null) return;
    if (existing.quantity > 1) {
      existing.quantity--;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  void remove(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
