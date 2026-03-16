import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/auth_provider.dart';
import 'services/cart_provider.dart';
import 'services/wishlist_provider.dart';
import 'utils/app_theme.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/support_screen.dart';
import 'screens/feedback_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WatchHubApp());
}

class WatchHubApp extends StatelessWidget {
  const WatchHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title:        'WatchHub',
        debugShowCheckedModeBanner: false,
        theme:        AppTheme.darkTheme,

        // ── Routes ──────────────────────────────
        initialRoute: '/splash',
        routes: {
          '/splash':         (_) => const SplashScreen(),
          '/login':          (_) => const LoginScreen(),
          '/register':       (_) => const RegisterScreen(),
          '/forgot-password':(_) => const ForgotPasswordScreen(),
          '/home':           (_) => const MainNavScreen(),
          '/checkout':       (_) => const CheckoutScreen(),
          '/order-history':  (_) => const OrderHistoryScreen(),
          '/admin':          (_) => const AdminScreen(),
          '/support':        (_) => const SupportScreen(),
          '/feedback':       (_) => const FeedbackScreen(),
        },

        // ── Route with arguments ─────────────────
        onGenerateRoute: (settings) {
          if (settings.name == '/product') {
            final watchId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(watchId: watchId),
            );
          }
          if (settings.name == '/reviews') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ReviewsScreen(
                watchId: args['watchId'] as int,
                watch:   args['watch'],
              ),
            );
          }
          return null;
        },

        // ── Transition animations ────────────────
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      ),
    );
  }
}
