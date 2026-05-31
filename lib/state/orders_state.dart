import 'package:flutter/foundation.dart';

import '../data/pharmacy_repository.dart';
import '../models/app_order.dart';
import '../models/app_user.dart';
import '../models/cart_item.dart';

class OrdersState extends ChangeNotifier {
  final PharmacyRepository _repo = PharmacyRepository.instance;

  List<AppOrder> _myOrders = [];
  List<AppOrder> _courierQueue = [];
  List<AppOrder> _allOrders = [];
  bool _loading = false;

  List<AppOrder> get myOrders => _myOrders;
  List<AppOrder> get courierQueue => _courierQueue;
  List<AppOrder> get allOrders => _allOrders;
  bool get loading => _loading;

  Future<AppOrder> placeOrder({
    required String customerUid,
    required String customerName,
    required String address,
    required List<CartItem> cartItems,
    required int total,
  }) async {
    final lines = cartItems.map(OrderLine.fromCartItem).toList();
    final order = await _repo.createOrder(
      customerUid: customerUid,
      customerName: customerName,
      address: address,
      lines: lines,
      total: total,
    );
    await loadMyOrders(customerUid);
    return order;
  }

  Future<void> loadMyOrders(String uid) async {
    _loading = true;
    notifyListeners();
    _myOrders = await _repo.fetchOrdersForCustomer(uid);
    _loading = false;
    notifyListeners();
  }

  Future<void> loadCourierQueue() async {
    _loading = true;
    notifyListeners();
    _courierQueue = await _repo.fetchCourierQueue();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadAllOrders() async {
    _loading = true;
    notifyListeners();
    _allOrders = await _repo.fetchAllOrders();
    _loading = false;
    notifyListeners();
  }

  Future<void> advanceStatus(AppOrder order) async {
    final next = OrderStatus.values[
        (order.status.index + 1).clamp(0, OrderStatus.values.length - 1)];
    await _repo.updateOrderStatus(order.id, next);
    order.status = next;
    notifyListeners();
  }

  Future<void> setStatus(AppOrder order, OrderStatus status) async {
    await _repo.updateOrderStatus(order.id, status);
    order.status = status;
    notifyListeners();
  }

  Future<void> acceptOrder(AppOrder order, AppUser courier) async {
    await _repo.assignCourier(
      order,
      courierUid: courier.uid,
      courierName: courier.name,
      rating: courier.rating == 0 ? 5.0 : courier.rating,
    );
    await loadCourierQueue();
  }

  void declineOrder(AppOrder order) {
    _courierQueue.removeWhere((o) => o.id == order.id);
    notifyListeners();
  }
}
