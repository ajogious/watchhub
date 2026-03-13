// lib/widgets/watch_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watch.dart';
import '../services/auth_provider.dart';
import '../services/wishlist_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class WatchCard extends StatelessWidget {
  final Watch watch;
  const WatchCard({super.key, required this.watch});

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final wishlist  = context.watch<WishlistProvider>();
    final inWishlist = wishlist.isWishlisted(watch.id ?? -1);

    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed('/product', arguments: watch.id),
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.md)),
                    child: Image.network(
                      watch.imageUrl,
                      width:  double.infinity,
                      height: double.infinity,
                      fit:    BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.darkSurface,
                        child: const Center(
                          child: Icon(Icons.watch_outlined,
                              size: 48, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  // Wishlist button
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: GestureDetector(
                      onTap: () async {
                        if (auth.userId == null) {
                          AppHelpers.showSnackBar(context,
                              'Please login to add to wishlist', isError: true);
                          return;
                        }
                        await wishlist.toggle(auth.userId!, watch.id!);
                        if (context.mounted) {
                          AppHelpers.showSnackBar(
                            context,
                            inWishlist
                                ? AppStrings.removedFromWishlist
                                : AppStrings.addedToWishlist,
                            isSuccess: !inWishlist,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.dark,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          inWishlist ? Icons.favorite : Icons.favorite_outline,
                          size:  16,
                          color: inWishlist ? AppColors.error : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  // Stock badge
                  if (watch.stock == 0)
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Text('Sold Out',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(watch.brand,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(watch.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppHelpers.formatPrice(watch.price),
                        style: AppTextStyles.price.copyWith(fontSize: 14),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 13, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(watch.rating.toStringAsFixed(1),
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
