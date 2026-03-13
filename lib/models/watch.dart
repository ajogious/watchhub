// lib/models/watch.dart
// ─────────────────────────────────────────────
// Watch data model with SQLite serialization
// ─────────────────────────────────────────────

class Watch {
  final int?   id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final String imageUrl;
  final double price;
  final int    stock;
  final double rating;
  final int    reviewCount;
  final String specs;       // JSON string of key-value specs
  final bool   isFeatured;
  final String createdAt;

  Watch({
    this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.stock,
    this.rating      = 0.0,
    this.reviewCount = 0,
    this.specs       = '{}',
    this.isFeatured  = false,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  // ── Convert to map for SQLite ─────────────────
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name':         name,
      'brand':        brand,
      'category':     category,
      'description':  description,
      'image_url':    imageUrl,
      'price':        price,
      'stock':        stock,
      'rating':       rating,
      'review_count': reviewCount,
      'specs':        specs,
      'is_featured':  isFeatured ? 1 : 0,
      'created_at':   createdAt,
    };
  }

  // ── Create from SQLite map ────────────────────
  factory Watch.fromMap(Map<String, dynamic> map) {
    return Watch(
      id:          map['id'] as int?,
      name:        map['name'] as String,
      brand:       map['brand'] as String,
      category:    map['category'] as String,
      description: map['description'] as String,
      imageUrl:    map['image_url'] as String,
      price:       (map['price'] as num).toDouble(),
      stock:       map['stock'] as int,
      rating:      (map['rating'] as num).toDouble(),
      reviewCount: map['review_count'] as int,
      specs:       map['specs'] as String,
      isFeatured:  (map['is_featured'] as int) == 1,
      createdAt:   map['created_at'] as String,
    );
  }

  // ── CopyWith ──────────────────────────────────
  Watch copyWith({
    int?    id,
    String? name,
    String? brand,
    String? category,
    String? description,
    String? imageUrl,
    double? price,
    int?    stock,
    double? rating,
    int?    reviewCount,
    String? specs,
    bool?   isFeatured,
  }) {
    return Watch(
      id:          id          ?? this.id,
      name:        name        ?? this.name,
      brand:       brand       ?? this.brand,
      category:    category    ?? this.category,
      description: description ?? this.description,
      imageUrl:    imageUrl    ?? this.imageUrl,
      price:       price       ?? this.price,
      stock:       stock       ?? this.stock,
      rating:      rating      ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      specs:       specs       ?? this.specs,
      isFeatured:  isFeatured  ?? this.isFeatured,
      createdAt:   createdAt,
    );
  }

  @override
  String toString() =>
    'Watch(id: $id, name: $name, brand: $brand, price: \$$price)';
}
