// lib/models/review.dart
// ─────────────────────────────────────────────
// Review/Rating data model with SQLite serialization
// ─────────────────────────────────────────────

class Review {
  final int?   id;
  final int    userId;
  final int    watchId;
  final double rating;     // 1.0 - 5.0
  final String comment;
  final String userName;   // Denormalized for display
  final int    helpfulCount;
  final String createdAt;

  Review({
    this.id,
    required this.userId,
    required this.watchId,
    required this.rating,
    required this.comment,
    required this.userName,
    this.helpfulCount = 0,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id':      userId,
      'watch_id':     watchId,
      'rating':       rating,
      'comment':      comment,
      'user_name':    userName,
      'helpful_count':helpfulCount,
      'created_at':   createdAt,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id:           map['id'] as int?,
      userId:       map['user_id'] as int,
      watchId:      map['watch_id'] as int,
      rating:       (map['rating'] as num).toDouble(),
      comment:      map['comment'] as String,
      userName:     map['user_name'] as String,
      helpfulCount: map['helpful_count'] as int? ?? 0,
      createdAt:    map['created_at'] as String,
    );
  }

  Review copyWith({int? helpfulCount}) {
    return Review(
      id:           id,
      userId:       userId,
      watchId:      watchId,
      rating:       rating,
      comment:      comment,
      userName:     userName,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt:    createdAt,
    );
  }

  @override
  String toString() =>
    'Review(watchId: $watchId, rating: $rating, user: $userName)';
}
