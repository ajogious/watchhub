import 'package:flutter/foundation.dart';
import '../models/wishlist_item.dart';
import 'database_helper.dart';

class WishlistProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<WishlistItem> _items = [];
  bool _isLoading = false;

  List<WishlistItem> get items => _items;
  bool get isLoading => _isLoading;
  int get count => _items.length;

  // ── Load wishlist ─────────────────────────────
  Future<void> loadWishlist(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _db.getWishlistItems(userId);
    } catch (e) {
      debugPrint('WishlistProvider.loadWishlist error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Toggle (add / remove) ─────────────────────
  Future<void> toggle(int userId, int watchId) async {
    await _db.toggleWishlist(userId, watchId);
    await loadWishlist(userId);
  }

  // ── Check if watch is wishlisted ──────────────
  bool isWishlisted(int watchId) {
    return _items.any((i) => i.watchId == watchId);
  }
}
