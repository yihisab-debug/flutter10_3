enum ComplaintStatus { open, approved, rejected }

ComplaintStatus complaintStatusFromString(String? v) {
  switch (v) {
    case 'approved':
      return ComplaintStatus.approved;
    case 'rejected':
      return ComplaintStatus.rejected;
    default:
      return ComplaintStatus.open;
  }
}

String complaintStatusToString(ComplaintStatus s) {
  switch (s) {
    case ComplaintStatus.approved:
      return 'approved';
    case ComplaintStatus.rejected:
      return 'rejected';
    case ComplaintStatus.open:
      return 'open';
  }
}

class Review {
  final String id;
  final String orderId;
  final String customerUid;
  final String customerName;
  final String courierUid;
  final String courierName;
  final int rating;
  final String comment;
  final bool isComplaint;
  final DateTime createdAt;

  ComplaintStatus status;

  Review({
    required this.id,
    required this.orderId,
    required this.customerUid,
    required this.customerName,
    required this.courierUid,
    required this.courierName,
    required this.rating,
    required this.comment,
    required this.isComplaint,
    required this.createdAt,
    this.status = ComplaintStatus.open,
  });

  String get statusLabel {
    switch (status) {
      case ComplaintStatus.approved:
        return 'Одобрена · деньги возвращены';
      case ComplaintStatus.rejected:
        return 'Отклонена';
      case ComplaintStatus.open:
        return 'На рассмотрении';
    }
  }

  factory Review.fromMap(String id, Map<String, dynamic> map) {
    ComplaintStatus st = complaintStatusFromString(map['status'] as String?);
    if (map['status'] == null && map['resolved'] == true) {
      st = ComplaintStatus.approved;
    }
    return Review(
      id: id,
      orderId: map['orderId'] as String? ?? '',
      customerUid: map['customerUid'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      courierUid: map['courierUid'] as String? ?? '',
      courierName: map['courierName'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 5,
      comment: map['comment'] as String? ?? '',
      isComplaint: map['isComplaint'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: st,
    );
  }

  Map<String, dynamic> toMap() => {
        'orderId': orderId,
        'customerUid': customerUid,
        'customerName': customerName,
        'courierUid': courierUid,
        'courierName': courierName,
        'rating': rating,
        'comment': comment,
        'isComplaint': isComplaint,
        'createdAt': createdAt.toIso8601String(),
        'status': complaintStatusToString(status),
      };
}
