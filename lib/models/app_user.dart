enum UserRole { customer, courier, admin }

UserRole roleFromString(String? value) {
  switch (value) {
    case 'courier':
      return UserRole.courier;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.customer;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.courier:
      return 'courier';
    case UserRole.admin:
      return 'admin';
    case UserRole.customer:
      return 'customer';
  }
}

class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String city;
  final UserRole role;
  final int bonusPoints;
  final int totalSpent;
  final int balance;
  final String? cardLast4;
  final double rating;
  final int deliveriesDone;

  const AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
    required this.role,
    this.bonusPoints = 0,
    this.totalSpent = 0,
    this.balance = 0,
    this.cardLast4,
    this.rating = 0,
    this.deliveriesDone = 0,
  });

  String get name => '$firstName $lastName'.trim();

  bool get profileComplete {
    final base =
        firstName.trim().isNotEmpty && phone.trim().isNotEmpty;
    if (role == UserRole.customer) return base && city.trim().isNotEmpty;
    return base;
  }

  String get initials {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return '?';
    if (l.isEmpty) return f[0].toUpperCase();
    return (f[0] + l[0]).toUpperCase();
  }

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    int? bonusPoints,
    int? totalSpent,
    int? balance,
    String? cardLast4,
    double? rating,
    int? deliveriesDone,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      role: role,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      totalSpent: totalSpent ?? this.totalSpent,
      balance: balance ?? this.balance,
      cardLast4: cardLast4 ?? this.cardLast4,
      rating: rating ?? this.rating,
      deliveriesDone: deliveriesDone ?? this.deliveriesDone,
    );
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    String first = map['firstName'] as String? ?? '';
    String last = map['lastName'] as String? ?? '';
    if (first.isEmpty && last.isEmpty && map['name'] != null) {
      final parts = (map['name'] as String).trim().split(RegExp(r'\s+'));
      first = parts.isNotEmpty ? parts.first : '';
      last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      firstName: first,
      lastName: last,
      phone: map['phone'] as String? ?? '',
      city: map['city'] as String? ?? '',
      role: roleFromString(map['role'] as String?),
      bonusPoints: (map['bonusPoints'] as num?)?.toInt() ?? 0,
      totalSpent: (map['totalSpent'] as num?)?.toInt() ?? 0,
      balance: (map['balance'] as num?)?.toInt() ?? 0,
      cardLast4: map['cardLast4'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      deliveriesDone: (map['deliveriesDone'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'name': name,
        'phone': phone,
        'city': city,
        'role': roleToString(role),
        'bonusPoints': bonusPoints,
        'totalSpent': totalSpent,
        'balance': balance,
        'cardLast4': cardLast4,
        'rating': rating,
        'deliveriesDone': deliveriesDone,
      };
}
