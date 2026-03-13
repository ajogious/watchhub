// lib/services/cart_provider.dart
// ─────────────────────────────────────────────
// Shopping cart state management
// ─────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import 'database_helper.dart';

class CartProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<CartItem> _items    = [];
  bool           _isLoading = false;

  List<CartItem> get items      => _items;
  bool           get isLoading  => _isLoading;
  int            get itemCount  => _items.fold(0, (sum, i) => sum + i.quantity);
  double         get totalPrice => _items.fold(0.0, (sum, i) => sum + i.totalPrice);
  bool           get isEmpty    => _items.isEmpty;

  // ── Load cart for user ────────────────────────
  Future<void> loadCart(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _db.getCartItems(userId);
    } catch (e) {
      debugPrint('CartProvider.loadCart error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Add to cart ───────────────────────────────
  Future<void> addToCart(int userId, int watchId, {int qty = 1}) async {
    await _db.addToCart(userId, watchId, qty: qty);
    await loadCart(userId);
  }

  // ── Update quantity ───────────────────────────
  Future<void> updateQuantity(int userId, int cartId, int newQty) async {
    await _db.updateCartQuantity(cartId, newQty);
    await loadCart(userId);
  }

  // ── Remove item ───────────────────────────────
  Future<void> removeItem(int userId, int cartId) async {
    await _db.removeFromCart(cartId);
    await loadCart(userId);
  }

  // ── Clear cart ────────────────────────────────
  Future<void> clearCart(int userId) async {
    await _db.clearCart(userId);
    _items = [];
    notifyListeners();
  }

  // ── Check if watch is in cart ─────────────────
  bool isInCart(int watchId) {
    return _items.any((i) => i.watchId == watchId);
  }

  // ── Place order ───────────────────────────────
  Future<bool> placeOrder(int userId, String shippingAddress) async {
    _isLoading = true;
    notifyListeners();
    try {
      final orderIds = await _db.placeOrder(userId, shippingAddress);
      if (orderIds.isNotEmpty) {
        _items = [];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('CartProvider.placeOrder error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
