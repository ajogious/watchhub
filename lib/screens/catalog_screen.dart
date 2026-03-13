// lib/screens/catalog_screen.dart
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/watch.dart';
import '../utils/constants.dart';
import '../widgets/watch_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _db          = DatabaseHelper();
  final _searchCtrl  = TextEditingController();
  List<Watch> _watches    = [];
  bool        _loading    = true;
  String      _brand      = 'All';
  String      _category   = 'All';
  String      _sort       = SortOptions.priceLowHigh;
  double      _minPrice   = 0;
  double      _maxPrice   = double.infinity;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    final watches = await _db.getWatches(
      brand:       _brand == 'All'    ? null : _brand,
      category:    _category == 'All' ? null : _category,
      minPrice:    _minPrice > 0      ? _minPrice : null,
      maxPrice:    _maxPrice < double.infinity ? _maxPrice : null,
      searchQuery: _searchCtrl.text.trim(),
      sortBy:      _sort,
    );
    if (mounted) setState(() { _watches = watches; _loading = false; });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _FiltersSheet(
        brand:    _brand,
        category: _category,
        sort:     _sort,
        onApply:  (brand, category, sort) {
          setState(() { _brand = brand; _category = category; _sort = sort; });
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Watches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText:    'Search watches, brands...',
                prefixIcon:  const Icon(Icons.search),
                suffixIcon:  _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () { _searchCtrl.clear(); _load(); },
                      )
                    : null,
              ),
            ),
          ),

          // ── Active filter chips ─────────────
          if (_brand != 'All' || _category != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  if (_brand != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Chip(
                        label: Text(_brand),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () { setState(() => _brand = 'All'); _load(); },
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  if (_category != 'All')
                    Chip(
                      label: Text(_category),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () { setState(() => _category = 'All'); _load(); },
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                    ),
                ],
              ),
            ),

          // ── Results ──────────────────────────
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
              : _watches.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.watch_off_outlined, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: AppSpacing.md),
                        Text('No watches found', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _watches.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing:  AppSpacing.md,
                    ),
                    itemBuilder: (_, i) => WatchCard(watch: _watches[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final String brand;
  final String category;
  final String sort;
  final void Function(String brand, String category, String sort) onApply;
  const _FiltersSheet({
    required this.brand, required this.category,
    required this.sort,  required this.onApply,
  });
  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String _brand;
  late String _category;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _brand    = widget.brand;
    _category = widget.category;
    _sort     = widget.sort;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Filters & Sort', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.lg),

          const Text('Brand', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: WatchBrands.all.map((b) => ChoiceChip(
              label: Text(b),
              selected: _brand == b,
              onSelected: (_) => setState(() => _brand = b),
            )).toList(),
          ),

          const SizedBox(height: AppSpacing.md),
          const Text('Category', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: WatchCategories.all.map((c) => ChoiceChip(
              label: Text(c),
              selected: _category == c,
              onSelected: (_) => setState(() => _category = c),
            )).toList(),
          ),

          const SizedBox(height: AppSpacing.md),
          const Text('Sort By', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            value: _sort,
            dropdownColor: AppColors.darkSurface,
            items: SortOptions.all.map((s) => DropdownMenuItem(
              value: s, child: Text(s),
            )).toList(),
            onChanged: (v) => setState(() => _sort = v!),
          ),

          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              widget.onApply(_brand, _category, _sort);
              Navigator.pop(context);
            },
            child: const Text('APPLY FILTERS'),
          ),
        ],
      ),
    );
  }
}
