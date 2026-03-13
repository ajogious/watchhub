import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_helper.dart';
import '../models/review.dart';
import '../models/watch.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ReviewsScreen extends StatefulWidget {
  final int watchId;
  final Watch watch;
  const ReviewsScreen({super.key, required this.watchId, required this.watch});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _db = DatabaseHelper();
  final _reviewCtrl = TextEditingController();

  List<Review> _reviews = [];
  bool _loading = true;
  bool _submitting = false;
  double _userRating = 0;
  String _sortBy = 'Newest';

  static const _sortOptions = [
    'Newest',
    'Oldest',
    'Highest Rating',
    'Lowest Rating',
    'Most Helpful'
  ];

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
    setState(() => _loading = true);
    final reviews =
        await _db.getReviewsByWatch(widget.watchId, sortBy: _sortBy);
    if (mounted)
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
  }

  // Compute per-star counts
  Map<int, int> get _starCounts {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) {
      final star = r.rating.round().clamp(1, 5);
      counts[star] = (counts[star] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) {
      AppHelpers.showSnackBar(context, 'Please login to submit a review',
          isError: true);
      return;
    }
    if (_userRating == 0) {
      AppHelpers.showSnackBar(context, 'Please tap a star to rate',
          isError: true);
      return;
    }
    if (_reviewCtrl.text.trim().isEmpty) {
      AppHelpers.showSnackBar(context, 'Please write your review',
          isError: true);
      return;
    }

    final alreadyReviewed =
        await _db.hasUserReviewed(auth.userId!, widget.watchId);
    if (!mounted) return;
    if (alreadyReviewed) {
      AppHelpers.showSnackBar(context, 'You have already reviewed this watch',
          isError: true);
      return;
    }

    setState(() => _submitting = true);
    await _db.addReview(Review(
      userId: auth.userId!,
      watchId: widget.watchId,
      rating: _userRating,
      comment: _reviewCtrl.text.trim(),
      userName: auth.currentUser!.name,
    ));
    _reviewCtrl.clear();
    setState(() {
      _userRating = 0;
      _submitting = false;
    });
    await _load();
    if (mounted) {
      AppHelpers.showSnackBar(context, 'Review submitted! Thank you 🎉',
          isSuccess: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Reviews & Ratings'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            color: AppColors.darkCard,
            onSelected: (v) {
              setState(() => _sortBy = v);
              _load();
            },
            itemBuilder: (_) => _sortOptions
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Row(children: [
                        Icon(
                          _sortBy == s
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: _sortBy == s
                              ? AppColors.primaryLight
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(s,
                            style: TextStyle(
                              color: _sortBy == s
                                  ? AppColors.primaryLight
                                  : AppColors.textPrimary,
                            )),
                      ]),
                    ))
                .toList(),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // ── Rating summary ──────────────
                _RatingSummary(
                  watch: widget.watch,
                  reviews: _reviews,
                  starCounts: _starCounts,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Write review ────────────────
                if (auth.isLoggedIn) ...[
                  _WriteReviewCard(
                    ctrl: _reviewCtrl,
                    rating: _userRating,
                    submitting: _submitting,
                    onRating: (r) => setState(() => _userRating = r),
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // ── Reviews list ────────────────
                if (_reviews.isEmpty)
                  const _EmptyReviews()
                else ...[
                  Row(
                    children: [
                      Text(
                          '${_reviews.length} Review${_reviews.length != 1 ? "s" : ""}',
                          style: AppTextStyles.heading3),
                      const Spacer(),
                      Text('Sorted by: $_sortBy', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._reviews.map((r) => _ReviewCard(
                        review: r,
                        db: _db,
                        onHelpful: _load,
                      )),
                ],
              ],
            ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────

class _RatingSummary extends StatelessWidget {
  final Watch watch;
  final List<Review> reviews;
  final Map<int, int> starCounts;
  const _RatingSummary(
      {required this.watch, required this.reviews, required this.starCounts});

  @override
  Widget build(BuildContext context) {
    final total = reviews.length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Big score
          Column(
            children: [
              Text(
                watch.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              RatingBarIndicator(
                rating: watch.rating,
                itemSize: 18,
                itemBuilder: (_, __) =>
                    const Icon(Icons.star_rounded, color: AppColors.warning),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('$total review${total != 1 ? "s" : ""}',
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          const VerticalDivider(width: 1, color: AppColors.divider),
          const SizedBox(width: AppSpacing.lg),
          // Bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = starCounts[star] ?? 0;
                final pct = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text('$star',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: AppColors.divider,
                            valueColor:
                                const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 22,
                        child: Text('$count',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.caption),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WriteReviewCard extends StatelessWidget {
  final TextEditingController ctrl;
  final double rating;
  final bool submitting;
  final void Function(double) onRating;
  final VoidCallback onSubmit;
  const _WriteReviewCard({
    required this.ctrl,
    required this.rating,
    required this.submitting,
    required this.onRating,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rate_review_outlined,
                    size: 18, color: AppColors.primaryLight),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Write a Review', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Your Rating', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          RatingBar.builder(
            minRating: 1,
            itemSize: 36,
            glow: false,
            unratedColor: AppColors.divider,
            itemBuilder: (_, __) =>
                const Icon(Icons.star_rounded, color: AppColors.warning),
            onRatingUpdate: onRating,
          ),
          if (rating > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(_ratingLabel(rating),
                style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: AppSpacing.md),
          const Text('Your Review', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: ctrl,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Tell others what you think about this watch...',
              filled: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: submitting ? null : onSubmit,
              child: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.dark))
                  : const Text('SUBMIT REVIEW'),
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(double r) {
    if (r >= 5) return 'Excellent!';
    if (r >= 4) return 'Very Good';
    if (r >= 3) return 'Good';
    if (r >= 2) return 'Fair';
    return 'Poor';
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final DatabaseHelper db;
  final VoidCallback onHelpful;
  const _ReviewCard(
      {required this.review, required this.db, required this.onHelpful});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _avatarColor(review.userName),
                child: Text(review.userName[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    Text(AppHelpers.formatDate(review.createdAt),
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(review.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.comment, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await db.markReviewHelpful(review.id!);
                  onHelpful();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Helpful (${review.helpfulCount})',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _avatarColor(String name) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.purple.shade700,
      Colors.orange.shade700,
      Colors.teal.shade700,
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Icon(Icons.rate_review_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            const Text('No reviews yet', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.xs),
            const Text('Be the first to share your experience!',
                textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
