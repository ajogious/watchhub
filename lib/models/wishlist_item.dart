// lib/models/wishlist_item.dart
// ─────────────────────────────────────────────
// Wishlist item model with SQLite serialization
// ─────────────────────────────────────────────

import 'watch.dart';

class WishlistItem {
  final int?  id;
  final int   userId;
  final int   watchId;
  final String addedAt;

  // Populated via JOIN
  Watch? watch;

  WishlistItem({
    this.id,
    required this.userId,
    required this.watchId,
    String? addedAt,
    this.watch,
  }) : addedAt = addedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id':  userId,
      'watch_id': watchId,
      'added_at': addedAt,
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map, {Watch? watch}) {
    return WishlistItem(
      id:      map['id'] as int?,
      userId:  map['user_id'] as int,
      watchId: map['watch_id'] as int,
      addedAt: map['added_at'] as String,
      watch:   watch,
    );
  }

  @override
  String toString() => 'WishlistItem(userId: $userId, watchId: $watchId)';
}
