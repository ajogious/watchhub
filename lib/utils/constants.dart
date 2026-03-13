import 'package:flutter/material.dart';

// ── Brand Colors ──────────────────────────────
class AppColors {
  static const Color primary = Color(0xFFB8860B); // Dark Gold
  static const Color primaryLight = Color(0xFFDAA520); // Gold
  static const Color accent = Color(0xFFC0A060); // Warm Gold
  static const Color dark = Color(0xFF0D0D0D); // Near Black
  static const Color darkCard = Color(0xFF1A1A1A); // Card BG
  static const Color darkSurface = Color(0xFF252525); // Surface
  static const Color textPrimary = Color(0xFFF5F5F0); // Off White
  static const Color textSecondary = Color(0xFFAAAAAA); // Grey
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color divider = Color(0xFF2E2E2E);
}

// ── Text Styles ────────────────────────────────
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle price = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryLight,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
    letterSpacing: 0.8,
  );
}

// ── Spacing ────────────────────────────────────
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ── Border Radius ──────────────────────────────
class AppRadius {
  static const double sm = 6.0;
  static const double md = 12.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double full = 100.0;
}

// ── App Strings ────────────────────────────────
class AppStrings {
  static const String appName = 'WatchHub';
  static const String tagline = 'Luxury at Your Wrist';
  static const String noInternet = 'No internet connection';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String addedToCart = 'Added to cart!';
  static const String removedFromCart = 'Removed from cart';
  static const String addedToWishlist = 'Added to wishlist!';
  static const String removedFromWishlist = 'Removed from wishlist';
  static const String loginSuccess = 'Welcome back!';
  static const String registerSuccess = 'Account created successfully!';
  static const String logoutSuccess = 'Logged out successfully';
}

// ── Watch Brands ────────────────────────────────
class WatchBrands {
  static const List<String> all = [
    'All',
    'Rolex',
    'Omega',
    'Tag Heuer',
    'Seiko',
    'Casio',
    'Fossil',
    'Citizen',
    'Breitling',
  ];
}

// ── Watch Categories ───────────────────────────
class WatchCategories {
  static const List<String> all = [
    'All',
    'Luxury',
    'Sport',
    'Casual',
    'Smart',
    'Vintage',
    'Dive',
    'Chronograph',
  ];
}

// ── Price Ranges ───────────────────────────────
class PriceRanges {
  static const List<Map<String, dynamic>> all = [
    {'label': 'All', 'min': 0.0, 'max': double.infinity},
    {'label': 'Under \$500', 'min': 0.0, 'max': 500.0},
    {'label': '\$500 - \$2K', 'min': 500.0, 'max': 2000.0},
    {'label': '\$2K - \$10K', 'min': 2000.0, 'max': 10000.0},
    {'label': 'Above \$10K', 'min': 10000.0, 'max': double.infinity},
  ];
}

// ── Sort Options ───────────────────────────────
class SortOptions {
  static const String priceLowHigh = 'Price: Low to High';
  static const String priceHighLow = 'Price: High to Low';
  static const String ratingHighLow = 'Rating: High to Low';
  static const String nameAZ = 'Name: A to Z';
  static const List<String> all = [
    priceLowHigh,
    priceHighLow,
    ratingHighLow,
    nameAZ,
  ];
}
