import 'cart_item.dart';

enum OrderStatus {
  accepted,
  collecting,
  onTheWay,
  delivered,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.accepted:
        return 'Заказ принят';
      case OrderStatus.collecting:
        return 'Лекарства собираются';
      case OrderStatus.onTheWay:
        return 'Курьер в пути';
      case OrderStatus.delivered:
        return 'Доставлено';
    }
  }

  String get title {
    switch (this) {
      case OrderStatus.accepted:
        return 'Подтверждён ✓';
      case OrderStatus.collecting:
        return 'Лекарства готовятся...';
      case OrderStatus.onTheWay:
        return 'Курьер в пути 🛵';
      case OrderStatus.delivered:
        return 'Доставлено! 🎉';
    }
  }

  int get step => index;
}

class OrderLine {
  final String name;
  final String emoji;
  final int price;
  final int quantity;

  const OrderLine({
    required this.name,
    required this.emoji,
    required this.price,
    required this.quantity,
  });

  factory OrderLine.fromCartItem(CartItem item) => OrderLine(
        name: item.product.name,
        emoji: item.product.emoji,
        price: item.product.price,
        quantity: item.quantity,
      );

  factory OrderLine.fromMap(Map<String, dynamic> map) => OrderLine(
        name: map['name'] as String? ?? '',
        emoji: map['emoji'] as String? ?? '💊',
        price: (map['price'] as num?)?.toInt() ?? 0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'emoji': emoji,
        'price': price,
        'quantity': quantity,
      };
}

class AppOrder {
  final String id;
  final String customerUid;
  final String customerName;
  final String address;
  final int total;
  final List<OrderLine> lines;
  OrderStatus status;
  final DateTime createdAt;

  String? courierUid;
  String? courierName;
  String? courierVehicle;
  double? courierRating;

  bool reviewed;
  bool refunded;

  AppOrder({
    required this.id,
    required this.customerUid,
    this.customerName = '',
    required this.address,
    required this.total,
    required this.lines,
    this.status = OrderStatus.accepted,
    required this.createdAt,
    this.courierUid,
    this.courierName,
    this.courierVehicle,
    this.courierRating,
    this.reviewed = false,
    this.refunded = false,
  });

  String get itemsSummary {
    if (lines.isEmpty) return '';
    final first = lines.first.name;
    final rest = lines.length - 1;
    return rest > 0 ? '$first, ${lines[1].name} +$rest' : first;
  }

  String get composition =>
      lines.map((l) => '${l.emoji} ${l.name} × ${l.quantity}').join(', ');

  factory AppOrder.fromMap(String id, Map<String, dynamic> map) {
    return AppOrder(
      id: id,
      customerUid: map['customerUid'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      address: map['address'] as String? ?? '',
      total: (map['total'] as num?)?.toInt() ?? 0,
      lines: ((map['lines'] as List?) ?? [])
          .map((e) => OrderLine.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      status: OrderStatus.values[(map['status'] as num?)?.toInt() ?? 0],
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      courierUid: map['courierUid'] as String?,
      courierName: map['courierName'] as String?,
      courierVehicle: map['courierVehicle'] as String?,
      courierRating: (map['courierRating'] as num?)?.toDouble(),
      reviewed: map['reviewed'] as bool? ?? false,
      refunded: map['refunded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'customerUid': customerUid,
        'customerName': customerName,
        'address': address,
        'total': total,
        'lines': lines.map((l) => l.toMap()).toList(),
        'status': status.index,
        'createdAt': createdAt.toIso8601String(),
        'courierUid': courierUid,
        'courierName': courierName,
        'courierVehicle': courierVehicle,
        'courierRating': courierRating,
        'reviewed': reviewed,
        'refunded': refunded,
      };
}
