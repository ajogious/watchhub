import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/cart_provider.dart';
import '../services/wishlist_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Wishlist (${wishlist.count})')),
      body: wishlist.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 80, color: AppColors.textSecondary),
                  SizedBox(height: AppSpacing.md),
                  Text('Your wishlist is empty', style: AppTextStyles.heading3),
                  SizedBox(height: AppSpacing.sm),
                  Text('Save watches you love for later.',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: wishlist.items.length,
              itemBuilder: (_, i) {
                final item = wishlist.items[i];
                final watch = item.watch;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      // Image
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/product',
                            arguments: item.watchId),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(AppRadius.md)),
                          child: watch != null
                              ? Image.network(watch.imageUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                        width: 90,
                                        height: 90,
                                        color: AppColors.darkSurface,
                                        child: const Icon(Icons.watch_outlined,
                                            color: AppColors.textSecondary),
                                      ))
                              : Container(
                                  width: 90,
                                  height: 90,
                                  color: AppColors.darkSurface,
                                  child: const Icon(Icons.watch_outlined,
                                      color: AppColors.textSecondary),
                                ),
                        ),
                      ),
                      // Info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(watch?.brand ?? '',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.primaryLight)),
                              Text(watch?.name ?? '',
                                  style: AppTextStyles.bodyLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: AppSpacing.xs),
                              Text(AppHelpers.formatPrice(watch?.price ?? 0),
                                  style: AppTextStyles.price
                                      .copyWith(fontSize: 15)),
                              const SizedBox(height: AppSpacing.sm),
                              // Add to cart button
                              SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md),
                                    textStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: watch?.stock == 0
                                      ? null
                                      : () async {
                                          await cart.addToCart(
                                              auth.userId!, item.watchId);
                                          if (context.mounted) {
                                            AppHelpers.showSnackBar(
                                                context, AppStrings.addedToCart,
                                                isSuccess: true);
                                          }
                                        },
                                  child: Text(watch?.stock == 0
                                      ? 'OUT OF STOCK'
                                      : 'ADD TO CART'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Remove
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary, size: 18),
                        onPressed: () =>
                            wishlist.toggle(auth.userId!, item.watchId),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
