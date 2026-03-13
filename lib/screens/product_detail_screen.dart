// lib/screens/product_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/cart_provider.dart';
import '../services/wishlist_provider.dart';
import '../services/database_helper.dart';
import '../models/watch.dart';
import '../models/review.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ProductDetailScreen extends StatefulWidget {
  final int watchId;
  const ProductDetailScreen({super.key, required this.watchId});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _db      = DatabaseHelper();
  Watch?         _watch;
  List<Review>   _reviews  = [];
  bool           _loading  = true;
  bool           _addingCart = false;
  double         _userRating = 0;
  final _reviewCtrl = TextEditingController();
  String _reviewSort = 'Newest';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final watch   = await _db.getWatchById(widget.watchId);
    final reviews = await _db.getReviewsByWatch(widget.watchId, sortBy: _reviewSort);
    if (mounted) setState(() { _watch = watch; _reviews = reviews; _loading = false; });
  }

  Future<void> _addToCart() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) {
      AppHelpers.showSnackBar(context, 'Please login first', isError: true);
      return;
    }
    setState(() => _addingCart = true);
    await context.read<CartProvider>().addToCart(auth.userId!, widget.watchId);
    if (mounted) {
      setState(() => _addingCart = false);
      AppHelpers.showSnackBar(context, AppStrings.addedToCart, isSuccess: true);
    }
  }

  Future<void> _submitReview() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) {
      AppHelpers.showSnackBar(context, 'Please login to review', isError: true);
      return;
    }
    if (_userRating == 0) {
      AppHelpers.showSnackBar(context, 'Please select a rating', isError: true);
      return;
    }
    if (_reviewCtrl.text.trim().isEmpty) {
      AppHelpers.showSnackBar(context, 'Please write a review', isError: true);
      return;
    }
    final alreadyReviewed =
        await _db.hasUserReviewed(auth.userId!, widget.watchId);
    if (!mounted) return;
    if (alreadyReviewed) {
      AppHelpers.showSnackBar(context, 'You already reviewed this watch', isError: true);
      return;
    }
    await _db.addReview(Review(
      userId:   auth.userId!,
      watchId:  widget.watchId,
      rating:   _userRating,
      comment:  _reviewCtrl.text.trim(),
      userName: auth.currentUser!.name,
    ));
    _reviewCtrl.clear();
    setState(() => _userRating = 0);
    await _load();
    if (mounted) AppHelpers.showSnackBar(context, 'Review submitted!', isSuccess: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _watch == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryLight)),
      );
    }

    final watch    = _watch!;
    final auth     = context.watch<AuthProvider>();
    final wishlist = context.watch<WishlistProvider>();
    final inWish   = wishlist.isWishlisted(watch.id!);
    Map<String, dynamic> specs = {};
    try { specs = jsonDecode(watch.specs); } catch (_) {}

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(watch.imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.darkSurface,
                      child: const Icon(Icons.watch_outlined,
                          size: 80, color: AppColors.textSecondary),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.dark],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(inWish ? Icons.favorite : Icons.favorite_outline,
                    color: inWish ? AppColors.error : null),
                onPressed: () async {
                  if (auth.userId == null) return;
                  await wishlist.toggle(auth.userId!, watch.id!);
                  if (mounted) AppHelpers.showSnackBar(context,
                    inWish ? AppStrings.removedFromWishlist : AppStrings.addedToWishlist,
                    isSuccess: !inWish);
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Name
                  Text(watch.brand, style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(watch.name, style: AppTextStyles.heading2),
                  const SizedBox(height: AppSpacing.sm),

                  // Rating row
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating:    watch.rating,
                        itemSize:  18,
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star_rounded, color: AppColors.warning),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('${watch.rating} (${watch.reviewCount} reviews)',
                          style: AppTextStyles.caption),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppHelpers.getStockColor(watch.stock).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                              color: AppHelpers.getStockColor(watch.stock), width: 0.5),
                        ),
                        child: Text(AppHelpers.getStockLabel(watch.stock),
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: AppHelpers.getStockColor(watch.stock),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Price
                  Text(AppHelpers.formatPrice(watch.price), style: AppTextStyles.price),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),

                  // Description
                  const Text('Description', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSpacing.sm),
                  Text(watch.description, style: AppTextStyles.bodyMedium),

                  // Specs
                  if (specs.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const Text('Specifications', style: AppTextStyles.heading3),
                    const SizedBox(height: AppSpacing.sm),
                    ...specs.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(e.key, style: AppTextStyles.caption),
                          ),
                          Expanded(
                            child: Text(e.value.toString(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                    )),
                  ],

                  // Reviews Section
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews (${_reviews.length})',
                          style: AppTextStyles.heading3),
                      DropdownButton<String>(
                        value: _reviewSort,
                        dropdownColor: AppColors.darkCard,
                        underline: const SizedBox.shrink(),
                        style: AppTextStyles.caption,
                        items: const [
                          DropdownMenuItem(value: 'Newest',          child: Text('Newest')),
                          DropdownMenuItem(value: 'Most Helpful',    child: Text('Most Helpful')),
                          DropdownMenuItem(value: 'Highest Rating',  child: Text('Top Rated')),
                        ],
                        onChanged: (v) {
                          setState(() => _reviewSort = v!);
                          _load();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Write review
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Write a Review', style: AppTextStyles.bodyLarge),
                        const SizedBox(height: AppSpacing.sm),
                        RatingBar.builder(
                          minRating:   1,
                          itemSize:    28,
                          glow:        false,
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star_rounded, color: AppColors.warning),
                          onRatingUpdate: (r) => setState(() => _userRating = r),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _reviewCtrl,
                          maxLines:   3,
                          decoration: const InputDecoration(
                            hintText:    'Share your experience...',
                            filled:      true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ElevatedButton(
                          onPressed: _submitReview,
                          child:     const Text('SUBMIT REVIEW'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Reviews list
                  ..._reviews.map((r) => _ReviewTile(review: r, db: _db, onHelpful: _load)),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Add to Cart ─────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.darkCard,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: watch.stock == 0 || _addingCart ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: _addingCart
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.dark))
                : Text(watch.stock == 0 ? 'OUT OF STOCK' : 'ADD TO CART'),
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review       review;
  final DatabaseHelper db;
  final VoidCallback onHelpful;
  const _ReviewTile({required this.review, required this.db, required this.onHelpful});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.3),
                child: Text(review.userName[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.primaryLight,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary)),
                    Text(AppHelpers.formatDate(review.createdAt),
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating:    review.rating,
                itemSize:  14,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star_rounded, color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.comment, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          GestureDetector(
            onTap: () async {
              await db.markReviewHelpful(review.id!);
              onHelpful();
            },
            child: Row(
              children: [
                const Icon(Icons.thumb_up_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Helpful (${review.helpfulCount})',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
