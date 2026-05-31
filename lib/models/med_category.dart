class MedCategory {
  final String id;
  final String name;
  final String emoji;

  const MedCategory({
    required this.id,
    required this.name,
    required this.emoji,
  });

  factory MedCategory.fromMap(String id, Map<String, dynamic> map) {
    return MedCategory(
      id: id,
      name: map['name'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '💊',
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'emoji': emoji};
}
