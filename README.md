# WatchHub 🕐
### Luxury Watch Shopping App

A premium Flutter mobile application for browsing and purchasing high-end watches.

---

## 📱 Features

- **Authentication** — Register, login, logout, forgot password
- **Browse Catalog** — Filter by brand, category, price range with search
- **Product Details** — Full specs, high-quality images, stock status
- **Shopping Cart** — Add/remove items, modify quantities, total price
- **Wishlist** — Save watches for later, move to cart
- **Reviews & Ratings** — Leave reviews, mark helpful, sort reviews
- **Order History** — Track past orders with status
- **User Profile** — Edit personal info and shipping address
- **Admin Panel** — Dashboard stats, product management
- **Customer Support** — FAQ and contact form

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| Flutter / Dart | UI framework |
| SQLite (sqflite) | Local database |
| Provider | State management |
| shared_preferences | Session persistence |
| cached_network_image | Image caching |
| carousel_slider | Banner carousel |
| flutter_rating_bar | Star ratings |

---

## 🗄️ Database Schema

| Table | Description |
|---|---|
| `users` | User accounts and profiles |
| `watches` | Watch catalog with specs |
| `cart` | Shopping cart items |
| `wishlist` | Saved/favourite watches |
| `orders` | Placed orders |
| `reviews` | User reviews and ratings |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android Studio / VS Code

### Run the app

```bash
# Clone the repo
git clone <repo-url>
cd watchhub

# Install dependencies
flutter pub get

# Run on emulator/device
flutter run

# Build APK
flutter build apk --release
```

### Demo Credentials
```
Email:    admin@watchhub.com
Password: admin123
```

---

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   ├── watch.dart         # Watch data model
│   ├── user.dart          # User data model
│   ├── cart_item.dart     # Cart item model
│   ├── order.dart         # Order model
│   ├── review.dart        # Review model
│   └── wishlist_item.dart # Wishlist model
├── services/
│   ├── database_helper.dart # SQLite CRUD operations
│   ├── auth_provider.dart   # Auth state management
│   ├── cart_provider.dart   # Cart state management
│   └── wishlist_provider.dart # Wishlist state management
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── forgot_password_screen.dart
│   ├── main_nav_screen.dart
│   ├── home_screen.dart
│   ├── catalog_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   ├── wishlist_screen.dart
│   ├── checkout_screen.dart
│   ├── profile_screen.dart
│   ├── order_history_screen.dart
│   └── admin_screen.dart
├── widgets/
│   └── watch_card.dart    # Reusable product card
└── utils/
    ├── constants.dart     # Colors, styles, strings
    ├── app_theme.dart     # Global ThemeData
    └── helpers.dart       # Utility functions
```

---

## 👥 Team

| Student ID | Name |
|---|---|
| Student1706374 | Zainab Umar Idris |
| Student1586464 | Cassandra Oziohu Naanzem Onotu |
| Student1701656 | Nuel Kasie Emeribe |

**Course:** Sem-3 eProject  
**Institution:** Aptech  
**Submission Date:** 17 March 2026
