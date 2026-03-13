class AppUser {
  final int? id;
  final String name;
  final String email;
  final String passwordHash; // Store hashed password
  final String phone;
  final String address;
  final String city;
  final String country;
  final bool isAdmin;
  final String createdAt;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.phone = '',
    this.address = '',
    this.city = '',
    this.country = '',
    this.isAdmin = false,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  // ── Convert to map for SQLite ─────────────────
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'is_admin': isAdmin ? 1 : 0,
      'created_at': createdAt,
    };
  }

  // ── Create from SQLite map ────────────────────
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      country: map['country'] as String? ?? '',
      isAdmin: (map['is_admin'] as int?) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  // ── CopyWith ──────────────────────────────────
  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? phone,
    String? address,
    String? city,
    String? country,
    bool? isAdmin,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
    );
  }

  // ── Safe display (never expose passwordHash) ───
  @override
  String toString() =>
      'AppUser(id: $id, name: $name, email: $email, isAdmin: $isAdmin)';
}
