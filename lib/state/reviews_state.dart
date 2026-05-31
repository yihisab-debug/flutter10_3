import 'package:flutter/foundation.dart';

import '../data/pharmacy_repository.dart';
import '../models/app_order.dart';
import '../models/review.dart';

class ReviewsState extends ChangeNotifier {
  final PharmacyRepository _repo = PharmacyRepository.instance;

  List<Review> _complaints = [];
  List<Review> _courierReviews = [];
  List<Review> _myReviews = [];
  bool _loading = false;

  List<Review> get complaints => _complaints;
  List<Review> get courierReviews => _courierReviews;
  List<Review> get myReviews => _myReviews;
  bool get loading => _loading;

  int get openComplaints =>
      _complaints.where((c) => c.status == ComplaintStatus.open).length;

  Future<void> submit({
    required AppOrder order,
    required String customerName,
    required int rating,
    required String comment,
    required bool isComplaint,
  }) async {
    final review = Review(
      id: 'rv-${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      customerUid: order.customerUid,
      customerName: customerName,
      courierUid: order.courierUid ?? '',
      courierName: order.courierName ?? 'Курьер',
      rating: rating,
      comment: comment,
      isComplaint: isComplaint,
      createdAt: DateTime.now(),
    );
    await _repo.submitReview(review);
    order.reviewed = true;
    notifyListeners();
  }

  Future<void> loadComplaints() async {
    _loading = true;
    notifyListeners();
    _complaints = await _repo.fetchComplaints();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadForCourier(String courierUid) async {
    _loading = true;
    notifyListeners();
    _courierReviews = await _repo.fetchReviewsForCourier(courierUid);
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMine(String customerUid) async {
    _loading = true;
    notifyListeners();
    _myReviews = await _repo.fetchReviewsByCustomer(customerUid);
    _loading = false;
    notifyListeners();
  }

  Future<void> resolve(Review complaint, bool approved) async {
    await _repo.resolveComplaint(complaint, approved);
    notifyListeners();
  }
}
