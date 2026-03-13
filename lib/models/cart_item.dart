// lib/models/cart_item.dart
// ─────────────────────────────────────────────
// Cart item model with SQLite serialization
// ─────────────────────────────────────────────

import 'watch.dart';

class CartItem {
  final int?  id;
  final int   userId;
  final int   watchId;
  int         quantity;
  final String addedAt;

  // Populated via JOIN (not stored in cart table)
  Watch? watch;

  CartItem({
    this.id,
    required this.userId,
    required this.watchId,
    this.quantity = 1,
    String? addedAt,
    this.watch,
  }) : addedAt = addedAt ?? DateTime.now().toIso8601String();

  // ── Computed total ─────────────────────────────
  double get totalPrice => (watch?.price ?? 0.0) * quantity;

  // ── Convert to map for SQLite ─────────────────
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id':  userId,
      'watch_id': watchId,
      'quantity': quantity,
      'added_at': addedAt,
    };
  }

  // ── Create from SQLite map ────────────────────
  factory CartItem.fromMap(Map<String, dynamic> map, {Watch? watch}) {
    return CartItem(
      id:       map['id'] as int?,
      userId:   map['user_id'] as int,
      watchId:  map['watch_id'] as int,
      quantity: map['quantity'] as int,
      addedAt:  map['added_at'] as String,
      watch:    watch,
    );
  }

  CartItem copyWith({int? quantity, Watch? watch}) {
    return CartItem(
      id:       id,
      userId:   userId,
      watchId:  watchId,
      quantity: quantity ?? this.quantity,
      addedAt:  addedAt,
      watch:    watch ?? this.watch,
    );
  }

  @override
  String toString() =>
    'CartItem(watchId: $watchId, qty: $quantity, total: \$${totalPrice.toStringAsFixed(2)})';
}
