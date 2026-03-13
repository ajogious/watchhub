import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_helper.dart';
import '../models/watch.dart';
import '../utils/constants.dart';
import '../widgets/watch_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper();
  List<Watch> _featured = [];
  List<Watch> _recent = [];
  bool _loading = true;
  int _bannerIdx = 0;

  final _banners = [
    {
      'title': 'New Arrivals',
      'sub': 'Discover luxury timepieces',
      'color': 0xFF1A1A1A
    },
    {
      'title': 'Summer Sale',
      'sub': 'Up to 20% off selected models',
      'color': 0xFF0D1A0D
    },
    {
      'title': 'Rolex Collection',
      'sub': 'Iconic craftsmanship',
      'color': 0xFF1A0D0D
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final featured = await _db.getFeaturedWatches();
    final recent = await _db.getWatches(sortBy: 'Rating: High to Low');
    if (mounted) {
      setState(() {
        _featured = featured;
        _recent = recent.take(6).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight))
          : CustomScrollView(
              slivers: [
                // ── App Bar ─────────────────────
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  backgroundColor: AppColors.dark,
                  title: const Text('WATCHHUB',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: AppColors.textPrimary,
                      )),
                  actions: [
                    if (auth.isAdmin)
                      IconButton(
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        onPressed: () => Navigator.pushNamed(context, '/admin'),
                      ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => Navigator.pushNamed(context, '/home'),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Banner Carousel ────────
                      CarouselSlider.builder(
                        itemCount: _banners.length,
                        itemBuilder: (_, i, __) => _BannerCard(
                          title: _banners[i]['title'] as String,
                          sub: _banners[i]['sub'] as String,
                          color: Color(_banners[i]['color'] as int),
                        ),
                        options: CarouselOptions(
                          height: 180,
                          viewportFraction: 0.92,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          onPageChanged: (i, _) =>
                              setState(() => _bannerIdx = i),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Dot indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _banners.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _bannerIdx == i ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _bannerIdx == i
                                  ? AppColors.primaryLight
                                  : AppColors.textSecondary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),

                      // ── Categories ─────────────
                      const SizedBox(height: AppSpacing.lg),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child:
                            Text('Categories', style: AppTextStyles.heading3),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          itemCount: WatchCategories.all.length - 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (_, i) {
                            final cat = WatchCategories.all[i + 1];
                            return GestureDetector(
                              onTap: () =>
                                  Navigator.of(context).pushNamed('/home'),
                              child: Chip(
                                label: Text(cat),
                                backgroundColor: AppColors.darkSurface,
                                side:
                                    const BorderSide(color: AppColors.divider),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Featured Watches ────────
                      if (_featured.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Featured',
                                  style: AppTextStyles.heading3),
                              TextButton(
                                onPressed: () {},
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 240,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md),
                            itemCount: _featured.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.md),
                            itemBuilder: (_, i) => SizedBox(
                              width: 160,
                              child: WatchCard(watch: _featured[i]),
                            ),
                          ),
                        ),
                      ],

                      // ── Top Rated ──────────────
                      if (_recent.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Top Rated',
                                  style: AppTextStyles.heading3),
                              TextButton(
                                onPressed: () {},
                                child: const Text('See all'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Top Rated Grid ──────────────
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => WatchCard(watch: _recent[i]),
                      childCount: _recent.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String title;
  final String sub;
  final Color color;
  const _BannerCard(
      {required this.title, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        gradient: LinearGradient(
          colors: [color, AppColors.darkCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(Icons.watch_outlined,
                size: 140, color: AppColors.primary.withOpacity(0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: AppTextStyles.heading2
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text(sub, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text('Shop Now',
                      style: TextStyle(
                          color: AppColors.dark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
