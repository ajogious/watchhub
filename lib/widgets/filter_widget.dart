import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FilterWidget extends StatefulWidget {
  final String selectedBrand;
  final String selectedCategory;
  final String selectedSort;
  final double minPrice;
  final double maxPrice;
  final void Function({
    required String brand,
    required String category,
    required String sort,
    required double minPrice,
    required double maxPrice,
  }) onApply;

  const FilterWidget({
    super.key,
    required this.selectedBrand,
    required this.selectedCategory,
    required this.selectedSort,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  });

  /// Convenience: show as bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String brand,
    required String category,
    required String sort,
    required double minPrice,
    required double maxPrice,
    required void Function({
      required String brand,
      required String category,
      required String sort,
      required double minPrice,
      required double maxPrice,
    }) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        builder: (_, ctrl) => FilterWidget(
          selectedBrand: brand,
          selectedCategory: category,
          selectedSort: sort,
          minPrice: minPrice,
          maxPrice: maxPrice,
          onApply: onApply,
        ),
      ),
    );
  }

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late String _brand;
  late String _category;
  late String _sort;
  late RangeValues _priceRange;

  static const double _absMin = 0;
  static const double _absMax = 40000;

  int get _activeCount {
    int c = 0;
    if (_brand != 'All') c++;
    if (_category != 'All') c++;
    if (_priceRange.start > _absMin || _priceRange.end < _absMax) c++;
    return c;
  }

  @override
  void initState() {
    super.initState();
    _brand = widget.selectedBrand;
    _category = widget.selectedCategory;
    _sort = widget.selectedSort;
    _priceRange = RangeValues(
      widget.minPrice,
      widget.maxPrice == double.infinity ? _absMax : widget.maxPrice,
    );
  }

  void _reset() => setState(() {
        _brand = 'All';
        _category = 'All';
        _sort = SortOptions.priceLowHigh;
        _priceRange = const RangeValues(_absMin, _absMax);
      });

  void _apply() {
    widget.onApply(
      brand: _brand,
      category: _category,
      sort: _sort,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end >= _absMax ? double.infinity : _priceRange.end,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle ─────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ─────────────────────────
          Row(
            children: [
              const Text('Filters & Sort', style: AppTextStyles.heading3),
              if (_activeCount > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text('$_activeCount',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.dark,
                          fontWeight: FontWeight.w700)),
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: _reset,
                child: const Text('Reset All',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Sort ───────────────────────
                  _SectionTitle('Sort By'),
                  const SizedBox(height: AppSpacing.sm),
                  ...SortOptions.all.map((s) => _SortTile(
                        label: s,
                        selected: _sort == s,
                        onTap: () => setState(() => _sort = s),
                      )),

                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),

                  // ── Brand ──────────────────────
                  _SectionTitle('Brand'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: WatchBrands.all
                        .map((b) => _FilterChip(
                              label: b,
                              selected: _brand == b,
                              onTap: () => setState(() => _brand = b),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),

                  // ── Category ───────────────────
                  _SectionTitle('Category'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: WatchCategories.all
                        .map((c) => _FilterChip(
                              label: c,
                              selected: _category == c,
                              onTap: () => setState(() => _category = c),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),

                  // ── Price Range ────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle('Price Range'),
                      Text(
                        '\$${_priceRange.start.toStringAsFixed(0)}  –  '
                        '${_priceRange.end >= _absMax ? "\$40k+" : "\$${_priceRange.end.toStringAsFixed(0)}"}',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _absMin,
                    max: _absMax,
                    divisions: 80,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.divider,
                    onChanged: (v) => setState(() => _priceRange = v),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // ── Apply button ───────────────────
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _apply,
              child: Text(
                _activeCount > 0
                    ? 'APPLY FILTERS ($_activeCount active)'
                    : 'APPLY FILTERS',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: AppColors.dark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ));
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.dark : AppColors.textPrimary,
            )),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortTile(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected
                        ? AppColors.primaryLight
                        : AppColors.textPrimary,
                  )),
            ),
            if (selected)
              const Icon(Icons.check_rounded,
                  size: 18, color: AppColors.primaryLight),
          ],
        ),
      ),
    );
  }
}
