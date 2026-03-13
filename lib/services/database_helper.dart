// lib/services/database_helper.dart
// ─────────────────────────────────────────────
// SQLite database: schema, CRUD, and seed data
// ─────────────────────────────────────────────

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/watch.dart';
import '../models/user.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/review.dart';
import '../models/wishlist_item.dart';

class DatabaseHelper {
  // ── Singleton ─────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  // ── Init & Schema ─────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'watchhub.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── Users ──────────────────────────────────
    await db.execute('''
      CREATE TABLE users (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT    NOT NULL,
        email         TEXT    NOT NULL UNIQUE,
        password_hash TEXT    NOT NULL,
        phone         TEXT    DEFAULT '',
        address       TEXT    DEFAULT '',
        city          TEXT    DEFAULT '',
        country       TEXT    DEFAULT '',
        is_admin      INTEGER DEFAULT 0,
        created_at    TEXT    NOT NULL
      )
    ''');

    // ── Watches ────────────────────────────────
    await db.execute('''
      CREATE TABLE watches (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT    NOT NULL,
        brand        TEXT    NOT NULL,
        category     TEXT    NOT NULL,
        description  TEXT    NOT NULL,
        image_url    TEXT    NOT NULL,
        price        REAL    NOT NULL,
        stock        INTEGER NOT NULL DEFAULT 0,
        rating       REAL    DEFAULT 0.0,
        review_count INTEGER DEFAULT 0,
        specs        TEXT    DEFAULT '{}',
        is_featured  INTEGER DEFAULT 0,
        created_at   TEXT    NOT NULL
      )
    ''');

    // ── Cart ───────────────────────────────────
    await db.execute('''
      CREATE TABLE cart (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id  INTEGER NOT NULL,
        watch_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        added_at TEXT    NOT NULL,
        FOREIGN KEY (user_id)  REFERENCES users(id)   ON DELETE CASCADE,
        FOREIGN KEY (watch_id) REFERENCES watches(id) ON DELETE CASCADE,
        UNIQUE(user_id, watch_id)
      )
    ''');

    // ── Wishlist ───────────────────────────────
    await db.execute('''
      CREATE TABLE wishlist (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id  INTEGER NOT NULL,
        watch_id INTEGER NOT NULL,
        added_at TEXT    NOT NULL,
        FOREIGN KEY (user_id)  REFERENCES users(id)   ON DELETE CASCADE,
        FOREIGN KEY (watch_id) REFERENCES watches(id) ON DELETE CASCADE,
        UNIQUE(user_id, watch_id)
      )
    ''');

    // ── Orders ─────────────────────────────────
    await db.execute('''
      CREATE TABLE orders (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id          INTEGER NOT NULL,
        watch_id         INTEGER NOT NULL,
        quantity         INTEGER NOT NULL DEFAULT 1,
        unit_price       REAL    NOT NULL,
        status           TEXT    DEFAULT 'pending',
        shipping_address TEXT    DEFAULT '',
        ordered_at       TEXT    NOT NULL,
        FOREIGN KEY (user_id)  REFERENCES users(id)   ON DELETE CASCADE,
        FOREIGN KEY (watch_id) REFERENCES watches(id) ON DELETE SET NULL
      )
    ''');

    // ── Reviews ────────────────────────────────
    await db.execute('''
      CREATE TABLE reviews (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id       INTEGER NOT NULL,
        watch_id      INTEGER NOT NULL,
        rating        REAL    NOT NULL,
        comment       TEXT    NOT NULL,
        user_name     TEXT    NOT NULL,
        helpful_count INTEGER DEFAULT 0,
        created_at    TEXT    NOT NULL,
        FOREIGN KEY (user_id)  REFERENCES users(id)   ON DELETE CASCADE,
        FOREIGN KEY (watch_id) REFERENCES watches(id) ON DELETE CASCADE,
        UNIQUE(user_id, watch_id)
      )
    ''');

    // ── Seed data ──────────────────────────────
    await _seedData(db);
  }

  // ── Seed: 12 sample watches ────────────────────
  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    final watches = [
      {
        'name': 'Submariner Date',
        'brand': 'Rolex',
        'category': 'Dive',
        'description': 'The iconic Rolex Submariner, the reference among divers\' watches. Waterproof to 300 metres, it features a unidirectional rotatable bezel and luminescent display.',
        'image_url': 'https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=500',
        'price': 10550.0,
        'stock': 8,
        'rating': 4.9,
        'review_count': 234,
        'specs': jsonEncode({'Case': '41mm', 'Material': 'Oystersteel', 'Movement': 'Automatic', 'Water Resistance': '300m', 'Crystal': 'Sapphire'}),
        'is_featured': 1,
      },
      {
        'name': 'Seamaster Diver 300M',
        'brand': 'Omega',
        'category': 'Dive',
        'description': 'The Seamaster Diver 300M is a true diver\'s watch, water resistant to 300 metres, with a ceramic bezel and co-axial escapement.',
        'image_url': 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=500',
        'price': 5200.0,
        'stock': 15,
        'rating': 4.8,
        'review_count': 189,
        'specs': jsonEncode({'Case': '42mm', 'Material': 'Stainless Steel', 'Movement': 'Co-Axial', 'Water Resistance': '300m', 'Crystal': 'Sapphire'}),
        'is_featured': 1,
      },
      {
        'name': 'Carrera Chronograph',
        'brand': 'Tag Heuer',
        'category': 'Chronograph',
        'description': 'A legend born on the racetrack. The TAG Heuer Carrera is the ultimate sports watch for those who live to push boundaries.',
        'image_url': 'https://images.unsplash.com/photo-1539874754764-5a96559165b0?w=500',
        'price': 3450.0,
        'stock': 20,
        'rating': 4.7,
        'review_count': 145,
        'specs': jsonEncode({'Case': '44mm', 'Material': 'Titanium', 'Movement': 'Automatic', 'Water Resistance': '100m', 'Crystal': 'Sapphire'}),
        'is_featured': 1,
      },
      {
        'name': 'Prospex Sea SRPD21',
        'brand': 'Seiko',
        'category': 'Dive',
        'description': 'Seiko Prospex Turtle Re-edition. A reliable automatic diver\'s watch with impressive depth rating and Seiko\'s legendary durability.',
        'image_url': 'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=500',
        'price': 395.0,
        'stock': 42,
        'rating': 4.6,
        'review_count': 312,
        'specs': jsonEncode({'Case': '45mm', 'Material': 'Stainless Steel', 'Movement': 'Automatic', 'Water Resistance': '200m', 'Crystal': 'Hardlex'}),
        'is_featured': 0,
      },
      {
        'name': 'G-Shock GA-2100',
        'brand': 'Casio',
        'category': 'Sport',
        'description': 'The CasiOak. Ultra-slim carbon core guard structure combines with the iconic G-SHOCK design for an exceptionally slim yet shock-resistant timepiece.',
        'image_url': 'https://images.unsplash.com/photo-1508057198894-247b23fe5ade?w=500',
        'price': 99.0,
        'stock': 100,
        'rating': 4.7,
        'review_count': 876,
        'specs': jsonEncode({'Case': '48.5mm', 'Material': 'Resin', 'Movement': 'Quartz', 'Water Resistance': '200m', 'Crystal': 'Mineral'}),
        'is_featured': 0,
      },
      {
        'name': 'Minimalist ME3172',
        'brand': 'Fossil',
        'category': 'Casual',
        'description': 'Clean, sophisticated design meets everyday reliability. The Fossil Minimalist features a slim profile with premium materials at an accessible price.',
        'image_url': 'https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=500',
        'price': 149.0,
        'stock': 55,
        'rating': 4.3,
        'review_count': 421,
        'specs': jsonEncode({'Case': '40mm', 'Material': 'Stainless Steel', 'Movement': 'Quartz', 'Water Resistance': '50m', 'Crystal': 'Mineral'}),
        'is_featured': 0,
      },
      {
        'name': 'Promaster BN0150',
        'brand': 'Citizen',
        'category': 'Sport',
        'description': 'Eco-Drive technology powers this professional dive watch using any light source. Never needs a battery change — truly sustainable luxury.',
        'image_url': 'https://images.unsplash.com/photo-1569397288884-4d43d6738fbd?w=500',
        'price': 345.0,
        'stock': 33,
        'rating': 4.5,
        'review_count': 267,
        'specs': jsonEncode({'Case': '44mm', 'Material': 'Stainless Steel', 'Movement': 'Eco-Drive', 'Water Resistance': '200m', 'Crystal': 'Sapphire'}),
        'is_featured': 0,
      },
      {
        'name': 'Navitimer B01',
        'brand': 'Breitling',
        'category': 'Chronograph',
        'description': 'The iconic aviation chronograph. The Navitimer features a circular slide rule allowing pilots to perform various calculations in flight.',
        'image_url': 'https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=500',
        'price': 8900.0,
        'stock': 6,
        'rating': 4.8,
        'review_count': 98,
        'specs': jsonEncode({'Case': '43mm', 'Material': 'Stainless Steel', 'Movement': 'COSC Chronometer', 'Water Resistance': '30m', 'Crystal': 'Sapphire'}),
        'is_featured': 1,
      },
      {
        'name': 'Day-Date 40',
        'brand': 'Rolex',
        'category': 'Luxury',
        'description': 'The "President\'s Watch". Worn by world leaders since 1956, the Day-Date is available exclusively in 18 ct gold or platinum.',
        'image_url': 'https://images.unsplash.com/photo-1548169874-53e85f753f1e?w=500',
        'price': 36550.0,
        'stock': 3,
        'rating': 5.0,
        'review_count': 45,
        'specs': jsonEncode({'Case': '40mm', 'Material': '18ct Yellow Gold', 'Movement': 'Calibre 3255', 'Water Resistance': '100m', 'Crystal': 'Sapphire'}),
        'is_featured': 1,
      },
      {
        'name': 'Speedmaster Professional',
        'brand': 'Omega',
        'category': 'Chronograph',
        'description': 'The Moonwatch. The only watch worn on the Moon and the first watch worn in space. A piece of human history on your wrist.',
        'image_url': 'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e?w=500',
        'price': 6350.0,
        'stock': 11,
        'rating': 4.9,
        'review_count': 567,
        'specs': jsonEncode({'Case': '42mm', 'Material': 'Stainless Steel', 'Movement': 'Manual', 'Water Resistance': '50m', 'Crystal': 'Hesalite'}),
        'is_featured': 1,
      },
      {
        'name': 'PRW-6600Y-1A',
        'brand': 'Casio',
        'category': 'Sport',
        'description': 'Triple Sensor Pathfinder. Features altitude, barometric pressure, temperature, and compass direction — the ultimate outdoor tool watch.',
        'image_url': 'https://images.unsplash.com/photo-1590736969596-a0d9d6cdd4b7?w=500',
        'price': 180.0,
        'stock': 28,
        'rating': 4.5,
        'review_count': 203,
        'specs': jsonEncode({'Case': '50mm', 'Material': 'Resin/Titanium', 'Movement': 'Solar Quartz', 'Water Resistance': '100m', 'Crystal': 'Mineral'}),
        'is_featured': 0,
      },
      {
        'name': 'Aquaracer Professional',
        'brand': 'Tag Heuer',
        'category': 'Dive',
        'description': 'Born to dive, designed to perform. The Aquaracer Professional 300 features a ceramic unidirectional bezel and automatic movement.',
        'image_url': 'https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=500',
        'price': 1650.0,
        'stock': 22,
        'rating': 4.6,
        'review_count': 178,
        'specs': jsonEncode({'Case': '43mm', 'Material': 'Stainless Steel', 'Movement': 'Automatic', 'Water Resistance': '300m', 'Crystal': 'Sapphire'}),
        'is_featured': 0,
      },
    ];

    for (final w in watches) {
      await db.insert('watches', {...w, 'created_at': now});
    }

    // Seed admin user (password: admin123)
    await db.insert('users', {
      'name':          'Admin User',
      'email':         'admin@watchhub.com',
      'password_hash': 'admin123', // In production, use bcrypt
      'phone':         '+1234567890',
      'address':       '123 Watch Street',
      'city':          'New York',
      'country':       'USA',
      'is_admin':      1,
      'created_at':    now,
    });
  }

  // ══════════════════════════════════════════════
  //  USER OPERATIONS
  // ══════════════════════════════════════════════

  /// Register a new user. Returns user id or -1 if email exists.
  Future<int> registerUser(AppUser user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1; // Duplicate email
    }
  }

  /// Login: returns AppUser or null if credentials don't match.
  Future<AppUser?> loginUser(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email, password],
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  /// Get user by id.
  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  /// Update user profile.
  Future<int> updateUser(AppUser user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ══════════════════════════════════════════════
  //  WATCH OPERATIONS
  // ══════════════════════════════════════════════

  /// Get all watches with optional filters.
  Future<List<Watch>> getWatches({
    String? brand,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    String? sortBy,
    bool featuredOnly = false,
  }) async {
    final db   = await database;
    final where = <String>[];
    final args  = <dynamic>[];

    if (brand != null && brand != 'All') {
      where.add('brand = ?');
      args.add(brand);
    }
    if (category != null && category != 'All') {
      where.add('category = ?');
      args.add(category);
    }
    if (minPrice != null) {
      where.add('price >= ?');
      args.add(minPrice);
    }
    if (maxPrice != null && maxPrice != double.infinity) {
      where.add('price <= ?');
      args.add(maxPrice);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      where.add('(name LIKE ? OR brand LIKE ? OR description LIKE ?)');
      final q = '%$searchQuery%';
      args.addAll([q, q, q]);
    }
    if (featuredOnly) {
      where.add('is_featured = 1');
    }

    String? orderBy;
    switch (sortBy) {
      case 'Price: Low to High':  orderBy = 'price ASC';   break;
      case 'Price: High to Low':  orderBy = 'price DESC';  break;
      case 'Rating: High to Low': orderBy = 'rating DESC'; break;
      case 'Name: A to Z':        orderBy = 'name ASC';    break;
      default:                    orderBy = 'is_featured DESC, id ASC';
    }

    final rows = await db.query(
      'watches',
      where:   where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: orderBy,
    );
    return rows.map(Watch.fromMap).toList();
  }

  /// Get watch by id.
  Future<Watch?> getWatchById(int id) async {
    final db   = await database;
    final rows = await db.query('watches', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Watch.fromMap(rows.first);
  }

  /// Get featured watches.
  Future<List<Watch>> getFeaturedWatches() =>
      getWatches(featuredOnly: true);

  /// Insert / update watch (admin).
  Future<int> upsertWatch(Watch watch) async {
    final db = await database;
    if (watch.id == null) {
      return await db.insert('watches', watch.toMap());
    }
    await db.update('watches', watch.toMap(),
        where: 'id = ?', whereArgs: [watch.id]);
    return watch.id!;
  }

  /// Delete watch (admin).
  Future<void> deleteWatch(int id) async {
    final db = await database;
    await db.delete('watches', where: 'id = ?', whereArgs: [id]);
  }

  // ══════════════════════════════════════════════
  //  CART OPERATIONS
  // ══════════════════════════════════════════════

  Future<List<CartItem>> getCartItems(int userId) async {
    final db   = await database;
    final rows = await db.query(
      'cart',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'added_at DESC',
    );
    final items = <CartItem>[];
    for (final row in rows) {
      final watch = await getWatchById(row['watch_id'] as int);
      items.add(CartItem.fromMap(row, watch: watch));
    }
    return items;
  }

  /// Add to cart or increment quantity if exists.
  Future<void> addToCart(int userId, int watchId, {int qty = 1}) async {
    final db = await database;
    final existing = await db.query(
      'cart',
      where: 'user_id = ? AND watch_id = ?',
      whereArgs: [userId, watchId],
    );
    if (existing.isNotEmpty) {
      final newQty = (existing.first['quantity'] as int) + qty;
      await db.update(
        'cart',
        {'quantity': newQty},
        where: 'user_id = ? AND watch_id = ?',
        whereArgs: [userId, watchId],
      );
    } else {
      await db.insert('cart', {
        'user_id':  userId,
        'watch_id': watchId,
        'quantity': qty,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> updateCartQuantity(int cartId, int newQty) async {
    final db = await database;
    if (newQty <= 0) {
      await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
    } else {
      await db.update('cart', {'quantity': newQty},
          where: 'id = ?', whereArgs: [cartId]);
    }
  }

  Future<void> removeFromCart(int cartId) async {
    final db = await database;
    await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<void> clearCart(int userId) async {
    final db = await database;
    await db.delete('cart', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> getCartCount(int userId) async {
    final db   = await database;
    final rows = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM cart WHERE user_id = ?',
      [userId],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  // ══════════════════════════════════════════════
  //  WISHLIST OPERATIONS
  // ══════════════════════════════════════════════

  Future<List<WishlistItem>> getWishlistItems(int userId) async {
    final db   = await database;
    final rows = await db.query(
      'wishlist',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'added_at DESC',
    );
    final items = <WishlistItem>[];
    for (final row in rows) {
      final watch = await getWatchById(row['watch_id'] as int);
      items.add(WishlistItem.fromMap(row, watch: watch));
    }
    return items;
  }

  Future<bool> isInWishlist(int userId, int watchId) async {
    final db   = await database;
    final rows = await db.query(
      'wishlist',
      where: 'user_id = ? AND watch_id = ?',
      whereArgs: [userId, watchId],
    );
    return rows.isNotEmpty;
  }

  Future<void> toggleWishlist(int userId, int watchId) async {
    final db      = await database;
    final inList  = await isInWishlist(userId, watchId);
    if (inList) {
      await db.delete('wishlist',
          where: 'user_id = ? AND watch_id = ?',
          whereArgs: [userId, watchId]);
    } else {
      await db.insert('wishlist', {
        'user_id':  userId,
        'watch_id': watchId,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ══════════════════════════════════════════════
  //  ORDER OPERATIONS
  // ══════════════════════════════════════════════

  Future<List<OrderItem>> getOrdersByUser(int userId) async {
    final db   = await database;
    final rows = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'ordered_at DESC',
    );
    final orders = <OrderItem>[];
    for (final row in rows) {
      final watch = await getWatchById(row['watch_id'] as int);
      orders.add(OrderItem.fromMap(row, watch: watch));
    }
    return orders;
  }

  Future<List<OrderItem>> getAllOrders() async {
    final db   = await database;
    final rows = await db.query('orders', orderBy: 'ordered_at DESC');
    final orders = <OrderItem>[];
    for (final row in rows) {
      final watch = await getWatchById(row['watch_id'] as int);
      orders.add(OrderItem.fromMap(row, watch: watch));
    }
    return orders;
  }

  /// Place order from cart items. Returns order ids.
  Future<List<int>> placeOrder(int userId, String shippingAddress) async {
    final db       = await database;
    final cartItems = await getCartItems(userId);
    final orderIds  = <int>[];
    final now       = DateTime.now().toIso8601String();

    for (final item in cartItems) {
      if (item.watch == null) continue;
      final id = await db.insert('orders', {
        'user_id':          userId,
        'watch_id':         item.watchId,
        'quantity':         item.quantity,
        'unit_price':       item.watch!.price,
        'status':           'pending',
        'shipping_address': shippingAddress,
        'ordered_at':       now,
      });
      orderIds.add(id);
      // Decrement stock
      await db.rawUpdate(
        'UPDATE watches SET stock = MAX(0, stock - ?) WHERE id = ?',
        [item.quantity, item.watchId],
      );
    }
    await clearCart(userId);
    return orderIds;
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    final db = await database;
    await db.update('orders', {'status': status},
        where: 'id = ?', whereArgs: [orderId]);
  }

  // ══════════════════════════════════════════════
  //  REVIEW OPERATIONS
  // ══════════════════════════════════════════════

  Future<List<Review>> getReviewsByWatch(int watchId, {String? sortBy}) async {
    final db = await database;
    String orderBy;
    switch (sortBy) {
      case 'Most Helpful': orderBy = 'helpful_count DESC'; break;
      case 'Highest Rating': orderBy = 'rating DESC';      break;
      case 'Lowest Rating':  orderBy = 'rating ASC';       break;
      default:               orderBy = 'created_at DESC';
    }
    final rows = await db.query(
      'reviews',
      where: 'watch_id = ?',
      whereArgs: [watchId],
      orderBy: orderBy,
    );
    return rows.map(Review.fromMap).toList();
  }

  Future<bool> hasUserReviewed(int userId, int watchId) async {
    final db   = await database;
    final rows = await db.query(
      'reviews',
      where: 'user_id = ? AND watch_id = ?',
      whereArgs: [userId, watchId],
    );
    return rows.isNotEmpty;
  }

  Future<int> addReview(Review review) async {
    final db = await database;
    final id = await db.insert('reviews', review.toMap());
    // Recalculate watch average rating
    await _recalcWatchRating(db, review.watchId);
    return id;
  }

  Future<void> markReviewHelpful(int reviewId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE reviews SET helpful_count = helpful_count + 1 WHERE id = ?',
      [reviewId],
    );
  }

  Future<void> _recalcWatchRating(Database db, int watchId) async {
    final rows = await db.rawQuery(
      'SELECT AVG(rating) as avg, COUNT(*) as cnt FROM reviews WHERE watch_id = ?',
      [watchId],
    );
    final avg = (rows.first['avg'] as num?)?.toDouble() ?? 0.0;
    final cnt = rows.first['cnt'] as int;
    await db.update(
      'watches',
      {'rating': double.parse(avg.toStringAsFixed(1)), 'review_count': cnt},
      where: 'id = ?',
      whereArgs: [watchId],
    );
  }

  // ══════════════════════════════════════════════
  //  ADMIN STATS
  // ══════════════════════════════════════════════

  Future<Map<String, int>> getAdminStats() async {
    final db = await database;
    final userCount  = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users WHERE is_admin = 0')) ?? 0;
    final watchCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM watches'))               ?? 0;
    final orderCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM orders'))                ?? 0;
    final reviewCount= Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM reviews'))               ?? 0;
    return {
      'users':   userCount,
      'watches': watchCount,
      'orders':  orderCount,
      'reviews': reviewCount,
    };
  }
}
