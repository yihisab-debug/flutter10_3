class Product {
  final String id;
  final String name;
  final String subtitle;
  final int price;
  final String emoji;
  final String categoryId;
  final bool inStock;
  final bool popular;

  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.emoji,
    required this.categoryId,
    this.inStock = true,
    this.popular = false,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      price: (map['price'] as num?)?.toInt() ?? 0,
      emoji: map['emoji'] as String? ?? '💊',
      categoryId: map['categoryId'] as String? ?? 'all',
      inStock: map['inStock'] as bool? ?? true,
      popular: map['popular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'subtitle': subtitle,
        'price': price,
        'emoji': emoji,
        'categoryId': categoryId,
        'inStock': inStock,
        'popular': popular,
      };
}
