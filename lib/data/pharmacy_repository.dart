import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../config.dart';
import '../models/app_order.dart';
import '../models/app_user.dart';
import '../models/med_category.dart';
import '../models/product.dart';
import '../models/review.dart';
import 'mock_data.dart';

class PharmacyRepository {
  PharmacyRepository._();
  static final PharmacyRepository instance = PharmacyRepository._();

  final List<AppOrder> _mockOrders = [];
  final List<Review> _mockReviews = [];
  final List<AppUser> _mockUsers = [];
  final Map<String, Product> _productOverrides = {};

  bool get _fb => AppConfig.useFirebase;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<List<MedCategory>> fetchCategories() async {
    if (!_fb) return MockData.categories;
    try {
      final snap = await _db.collection('categories').get();
      if (snap.docs.isEmpty) return MockData.categories;
      return snap.docs.map((d) => MedCategory.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return MockData.categories;
    }
  }

  Future<List<Product>> fetchProducts() async {
    if (!_fb) {
      return MockData.products
          .map((p) => _productOverrides[p.id] ?? p)
          .toList();
    }
    try {
      final snap = await _db.collection('products').get();
      if (snap.docs.isEmpty) return MockData.products;
      return snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return MockData.products;
    }
  }

  Future<void> updateProductPrice(String productId, int price) async {
    if (_fb) {
      await _db.collection('products').doc(productId).update({'price': price});
    } else {
      final base = _productOverrides[productId] ??
          MockData.products.firstWhere((p) => p.id == productId);
      _productOverrides[productId] = base.copyWith(price: price);
    }
  }

  Future<void> setProductInStock(String productId, bool inStock) async {
    if (_fb) {
      await _db
          .collection('products')
          .doc(productId)
          .update({'inStock': inStock});
    } else {
      final base = _productOverrides[productId] ??
          MockData.products.firstWhere((p) => p.id == productId);
      _productOverrides[productId] = base.copyWith(inStock: inStock);
    }
  }

  Future<void> saveUser(AppUser user) async {
    if (_fb) {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } else {
      _mockUsers.removeWhere((u) => u.uid == user.uid);
      _mockUsers.add(user);
    }
  }

  Future<List<AppUser>> fetchCouriers() async {
    if (!_fb) {
      return _mockUsers.where((u) => u.role == UserRole.courier).toList();
    }
    try {
      final snap =
          await _db.collection('users').where('role', isEqualTo: 'courier').get();
      return snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
    } catch (_) {
      return [];
    }
  }

  String _newOrderId() => 'PH-${10000 + Random().nextInt(89999)}';

  Future<AppOrder> createOrder({
    required String customerUid,
    required String customerName,
    required String address,
    required List<OrderLine> lines,
    required int total,
  }) async {
    final order = AppOrder(
      id: _newOrderId(),
      customerUid: customerUid,
      customerName: customerName,
      address: address,
      total: total,
      lines: lines,
      status: OrderStatus.accepted,
      createdAt: DateTime.now(),
    );
    if (_fb) {
      await _db.collection('orders').doc(order.id).set(order.toMap());
    } else {
      _mockOrders.insert(0, order);
    }
    return order;
  }

  Future<List<AppOrder>> fetchOrdersForCustomer(String uid) async {
    if (!_fb) {
      return _mockOrders.where((o) => o.customerUid == uid).toList();
    }
    try {
      final snap = await _db
          .collection('orders')
          .where('customerUid', isEqualTo: uid)
          .get();
      final list =
          snap.docs.map((d) => AppOrder.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<AppOrder>> fetchCourierQueue() async {
    bool unassigned(AppOrder o) =>
        o.status == OrderStatus.accepted &&
        (o.courierUid == null || o.courierUid!.isEmpty);
    if (!_fb) {
      return _mockOrders.where(unassigned).toList();
    }
    try {
      final snap = await _db
          .collection('orders')
          .where('status', isEqualTo: OrderStatus.accepted.index)
          .get();
      final list = snap.docs
          .map((d) => AppOrder.fromMap(d.id, d.data()))
          .where(unassigned)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<AppOrder>> fetchOrdersForCourier(String courierUid) async {
    if (!_fb) {
      return _mockOrders.where((o) => o.courierUid == courierUid).toList();
    }
    try {
      final snap = await _db
          .collection('orders')
          .where('courierUid', isEqualTo: courierUid)
          .get();
      final list =
          snap.docs.map((d) => AppOrder.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<AppOrder>> fetchAllOrders() async {
    if (!_fb) return List.of(_mockOrders);
    try {
      final snap = await _db.collection('orders').get();
      final list =
          snap.docs.map((d) => AppOrder.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (_fb) {
      await _db.collection('orders').doc(orderId).update({'status': status.index});
    } else {
      final i = _mockOrders.indexWhere((e) => e.id == orderId);
      if (i != -1) _mockOrders[i].status = status;
    }
  }

  Future<void> assignCourier(
    AppOrder order, {
    required String courierUid,
    required String courierName,
    String vehicle = 'Мотоцикл',
    double rating = 5.0,
  }) async {
    order.courierUid = courierUid;
    order.courierName = courierName;
    order.courierVehicle = vehicle;
    order.courierRating = rating;
    if (_fb) {
      await _db.collection('orders').doc(order.id).update({
        'courierUid': courierUid,
        'courierName': courierName,
        'courierVehicle': vehicle,
        'courierRating': rating,
      });
    }
  }

  Future<void> markReviewed(String orderId) async {
    if (_fb) {
      await _db.collection('orders').doc(orderId).update({'reviewed': true});
    } else {
      final i = _mockOrders.indexWhere((e) => e.id == orderId);
      if (i != -1) _mockOrders[i].reviewed = true;
    }
  }

  Future<Review> submitReview(Review review) async {
    if (_fb) {
      final doc = _db.collection('reviews').doc();
      final r = Review(
        id: doc.id,
        orderId: review.orderId,
        customerUid: review.customerUid,
        customerName: review.customerName,
        courierUid: review.courierUid,
        courierName: review.courierName,
        rating: review.rating,
        comment: review.comment,
        isComplaint: review.isComplaint,
        createdAt: review.createdAt,
      );
      await doc.set(r.toMap());
      await markReviewed(review.orderId);
      return r;
    } else {
      _mockReviews.insert(0, review);
      await markReviewed(review.orderId);
      return review;
    }
  }

  Future<List<Review>> fetchComplaints() async {
    if (!_fb) return _mockReviews.where((r) => r.isComplaint).toList();
    try {
      final snap =
          await _db.collection('reviews').where('isComplaint', isEqualTo: true).get();
      final list = snap.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<Review>> fetchReviewsForCourier(String courierUid) async {
    if (!_fb) {
      return _mockReviews.where((r) => r.courierUid == courierUid).toList();
    }
    try {
      final snap = await _db
          .collection('reviews')
          .where('courierUid', isEqualTo: courierUid)
          .get();
      final list = snap.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<List<Review>> fetchReviewsByCustomer(String customerUid) async {
    if (!_fb) {
      return _mockReviews.where((r) => r.customerUid == customerUid).toList();
    }
    try {
      final snap = await _db
          .collection('reviews')
          .where('customerUid', isEqualTo: customerUid)
          .get();
      final list = snap.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> resolveComplaint(Review complaint, bool approved) async {
    complaint.status =
        approved ? ComplaintStatus.approved : ComplaintStatus.rejected;
    if (_fb) {
      await _db.collection('reviews').doc(complaint.id).update(
          {'status': complaintStatusToString(complaint.status)});
      if (approved) {
        final ordSnap =
            await _db.collection('orders').doc(complaint.orderId).get();
        final total = (ordSnap.data()?['total'] as num?)?.toInt() ?? 0;
        await _db
            .collection('orders')
            .doc(complaint.orderId)
            .update({'refunded': true});
        if (complaint.customerUid.isNotEmpty && total > 0) {
          await _db
              .collection('users')
              .doc(complaint.customerUid)
              .update({'balance': FieldValue.increment(total)});
        }
      }
    } else {
      if (approved) {
        final i = _mockOrders.indexWhere((o) => o.id == complaint.orderId);
        if (i != -1) _mockOrders[i].refunded = true;
        final ui = _mockUsers.indexWhere((u) => u.uid == complaint.customerUid);
        if (i != -1 && ui != -1) {
          _mockUsers[ui] = _mockUsers[ui]
              .copyWith(balance: _mockUsers[ui].balance + _mockOrders[i].total);
        }
      }
    }
  }

  Future<AppUser?> fetchUser(String uid) async {
    if (!_fb) {
      final i = _mockUsers.indexWhere((u) => u.uid == uid);
      return i == -1 ? null : _mockUsers[i];
    }
    try {
      final snap = await _db.collection('users').doc(uid).get();
      if (!snap.exists) return null;
      return AppUser.fromMap(uid, snap.data()!);
    } catch (_) {
      return null;
    }
  }

  Stream<List<AppOrder>> streamCourierQueue() {
    bool unassigned(AppOrder o) =>
        o.status == OrderStatus.accepted &&
        (o.courierUid == null || o.courierUid!.isEmpty);
    if (!_fb) return Stream.value(_mockOrders.where(unassigned).toList());
    return _db
        .collection('orders')
        .where('status', isEqualTo: OrderStatus.accepted.index)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => AppOrder.fromMap(d.id, d.data()))
          .where(unassigned)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<AppOrder>> streamOrdersForCourier(String courierUid) {
    if (!_fb) {
      return Stream.value(
          _mockOrders.where((o) => o.courierUid == courierUid).toList());
    }
    return _db
        .collection('orders')
        .where('courierUid', isEqualTo: courierUid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => AppOrder.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<AppOrder>> streamAllOrders() {
    if (!_fb) return Stream.value(List.of(_mockOrders));
    return _db.collection('orders').snapshots().map((s) {
      final list = s.docs.map((d) => AppOrder.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<AppOrder>> streamOrdersForCustomer(String uid) {
    if (!_fb) {
      return Stream.value(
          _mockOrders.where((o) => o.customerUid == uid).toList());
    }
    return _db
        .collection('orders')
        .where('customerUid', isEqualTo: uid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => AppOrder.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<AppOrder?> streamOrder(String orderId) {
    if (!_fb) {
      final i = _mockOrders.indexWhere((o) => o.id == orderId);
      return Stream.value(i == -1 ? null : _mockOrders[i]);
    }
    return _db.collection('orders').doc(orderId).snapshots().map(
        (d) => d.exists ? AppOrder.fromMap(d.id, d.data()!) : null);
  }

  Stream<List<Review>> streamComplaints() {
    if (!_fb) {
      return Stream.value(_mockReviews.where((r) => r.isComplaint).toList());
    }
    return _db
        .collection('reviews')
        .where('isComplaint', isEqualTo: true)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Review>> streamReviewsForCourier(String courierUid) {
    if (!_fb) {
      return Stream.value(
          _mockReviews.where((r) => r.courierUid == courierUid).toList());
    }
    return _db
        .collection('reviews')
        .where('courierUid', isEqualTo: courierUid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Review>> streamReviewsByCustomer(String customerUid) {
    if (!_fb) {
      return Stream.value(
          _mockReviews.where((r) => r.customerUid == customerUid).toList());
    }
    return _db
        .collection('reviews')
        .where('customerUid', isEqualTo: customerUid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<AppUser>> streamCouriers() {
    if (!_fb) {
      return Stream.value(
          _mockUsers.where((u) => u.role == UserRole.courier).toList());
    }
    return _db
        .collection('users')
        .where('role', isEqualTo: 'courier')
        .snapshots()
        .map((s) => s.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
  }

  Future<void> seedFirestore() async {
    if (!_fb) return;
    final batch = _db.batch();
    for (final c in MockData.categories) {
      batch.set(_db.collection('categories').doc(c.id), c.toMap());
    }
    for (final p in MockData.products) {
      batch.set(_db.collection('products').doc(p.id), p.toMap());
    }
    await batch.commit();
  }
}
