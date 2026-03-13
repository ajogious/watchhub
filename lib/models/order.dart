import 'watch.dart';

class OrderItem {
  final int? id;
  final int userId;
  final int watchId;
  final int quantity;
  final double unitPrice; // Price at time of order (price may change later)
  final String status; // pending | processing | shipped | delivered | cancelled
  final String shippingAddress;
  final String orderedAt;

  // Populated via JOIN
  Watch? watch;

  OrderItem({
    this.id,
    required this.userId,
    required this.watchId,
    required this.quantity,
    required this.unitPrice,
    this.status = 'pending',
    this.shippingAddress = '',
    String? orderedAt,
    this.watch,
  }) : orderedAt = orderedAt ?? DateTime.now().toIso8601String();

  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'watch_id': watchId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'status': status,
      'shipping_address': shippingAddress,
      'ordered_at': orderedAt,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map, {Watch? watch}) {
    return OrderItem(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      watchId: map['watch_id'] as int,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      status: map['status'] as String,
      shippingAddress: map['shipping_address'] as String? ?? '',
      orderedAt: map['ordered_at'] as String,
      watch: watch,
    );
  }

  OrderItem copyWith({String? status}) {
    return OrderItem(
      id: id,
      userId: userId,
      watchId: watchId,
      quantity: quantity,
      unitPrice: unitPrice,
      status: status ?? this.status,
      shippingAddress: shippingAddress,
      orderedAt: orderedAt,
      watch: watch,
    );
  }

  @override
  String toString() =>
      'OrderItem(id: $id, watchId: $watchId, qty: $quantity, status: $status)';
}
