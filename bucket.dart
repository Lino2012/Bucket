class Bucket {
  final int? id;
  final String name;
  final String icon; // icon name string, e.g. 'identity', 'travel'
  final String color; // hex color string, e.g. '#EEEDFE'
  final DateTime createdAt;

  const Bucket({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  Bucket copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    DateTime? createdAt,
  }) {
    return Bucket(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bucket.fromMap(Map<String, dynamic> map) {
    return Bucket(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() => 'Bucket(id: $id, name: $name)';
}
