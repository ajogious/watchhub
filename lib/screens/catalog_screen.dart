import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/watch.dart';
import '../utils/constants.dart';
import '../widgets/watch_card.dart';
import '../widgets/filter_widget.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _db = DatabaseHelper();
  final _searchCtrl = TextEditingController();

  List<Watch> _watches = [];
  bool _loading = true;
  String _brand = 'All';
  String _category = 'All';
  String _sort = SortOptions.priceLowHigh;
  double _minPrice = 0;
  double _maxPrice = double.infinity;

  int get _activeFilters {
    int c = 0;
    if (_brand != 'All') c++;
    if (_category != 'All') c++;
    if (_minPrice > 0 || _maxPrice < double.infinity) c++;
    return c;
  }

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_load);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_load);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final watches = await _db.getWatches(
      brand: _brand == 'All' ? null : _brand,
      category: _category == 'All' ? null : _category,
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < double.infinity ? _maxPrice : null,
      searchQuery: _searchCtrl.text.trim(),
      sortBy: _sort,
    );
    if (mounted)
      setState(() {
        _watches = watches;
        _loading = false;
      });
  }

  void _openFilters() => FilterWidget.show(
        context,
        brand: _brand,
        category: _category,
        sort: _sort,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApply: (
            {required brand,
            required category,
            required sort,
            required minPrice,
            required maxPrice}) {
          setState(() {
            _brand = brand;
            _category = category;
            _sort = sort;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
          });
          _load();
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Browse Watches'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _openFilters,
              ),
              if (_activeFilters > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$_activeFilters',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.dark,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search watches, brands...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                        })
                    : null,
              ),
            ),
          ),

          // ── Active filter chips ─────────────
          if (_activeFilters > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_brand != 'All')
                      _ActiveChip(
                          label: _brand,
                          onRemove: () {
                            setState(() => _brand = 'All');
                            _load();
                          }),
                    if (_category != 'All')
                      _ActiveChip(
                          label: _category,
                          onRemove: () {
                            setState(() => _category = 'All');
                            _load();
                          }),
                    if (_minPrice > 0 || _maxPrice < double.infinity)
                      _ActiveChip(
                          label: '\$${_minPrice.toStringAsFixed(0)} – '
                              '${_maxPrice == double.infinity ? "∞" : "\$${_maxPrice.toStringAsFixed(0)}"}',
                          onRemove: () {
                            setState(() {
                              _minPrice = 0;
                              _maxPrice = double.infinity;
                            });
                            _load();
                          }),
                    _ActiveChip(
                        label: 'Clear all',
                        isDanger: true,
                        onRemove: () {
                          setState(() {
                            _brand = 'All';
                            _category = 'All';
                            _sort = SortOptions.priceLowHigh;
                            _minPrice = 0;
                            _maxPrice = double.infinity;
                          });
                          _load();
                        }),
                  ],
                ),
              ),
            ),

          // ── Results count ───────────────────
          if (!_loading)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: Row(
                children: [
                  Text('${_watches.length} watches found',
                      style: AppTextStyles.caption),
                  const Spacer(),
                  GestureDetector(
                    onTap: _openFilters,
                    child: Text(_sort,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.sm),

          // ── Grid / Empty ────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryLight))
                : _watches.isEmpty
                    ? _EmptyState(
                        query: _searchCtrl.text,
                        hasFilters: _activeFilters > 0,
                        onClearFilters: () {
                          _searchCtrl.clear();
                          setState(() {
                            _brand = 'All';
                            _category = 'All';
                            _minPrice = 0;
                            _maxPrice = double.infinity;
                          });
                          _load();
                        },
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _watches.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                        itemBuilder: (_, i) => WatchCard(watch: _watches[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  final bool isDanger;
  const _ActiveChip(
      {required this.label, required this.onRemove, this.isDanger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDanger
            ? AppColors.error.withOpacity(0.12)
            : AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isDanger
              ? AppColors.error.withOpacity(0.4)
              : AppColors.primary.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDanger ? AppColors.error : AppColors.primaryLight,
              )),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 14,
                color: isDanger ? AppColors.error : AppColors.primaryLight),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final bool hasFilters;
  final VoidCallback onClearFilters;
  const _EmptyState(
      {required this.query,
      required this.hasFilters,
      required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.watch_off_outlined,
                  size: 36, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              query.isNotEmpty
                  ? 'No results for "$query"'
                  : 'No watches match your filters',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('Try adjusting your search or filters',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
