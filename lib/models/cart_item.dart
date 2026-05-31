import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get lineTotal => product.price * quantity;

  Map<String, dynamic> toMap() => {
        'productId': product.id,
        'name': product.name,
        'emoji': product.emoji,
        'price': product.price,
        'quantity': quantity,
      };
}
