// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/watch.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseHelper();
  late TabController _tabCtrl;
  Map<String, int> _stats  = {};
  List<Watch>      _watches = [];
  bool             _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final stats   = await _db.getAdminStats();
    final watches = await _db.getWatches();
    if (mounted) {
      setState(() { _stats = stats; _watches = watches; _loading = false; });
    }
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text('$value', style: AppTextStyles.heading2.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Products'),
          ],
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
        : TabBarView(
            controller: _tabCtrl,
            children: [
              // ── Dashboard tab ────────────────
              _DashboardTab(stats: _stats, statCard: _statCard),
              // ── Products tab ─────────────────
              _ProductsTab(watches: _watches, db: _db, onRefresh: _load),
            ],
          ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final Map<String, int> stats;
  final Widget Function(String, int, IconData, Color) statCard;
  const _DashboardTab({required this.stats, required this.statCard});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              statCard('Users',   stats['users']   ?? 0, Icons.people_outlined,       AppColors.primaryLight),
              const SizedBox(width: AppSpacing.sm),
              statCard('Watches', stats['watches'] ?? 0, Icons.watch_outlined,         AppColors.accent),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              statCard('Orders',  stats['orders']  ?? 0, Icons.shopping_bag_outlined,  AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              statCard('Reviews', stats['reviews'] ?? 0, Icons.star_outline,           AppColors.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Admin Credentials', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: admin@watchhub.com', style: AppTextStyles.bodyMedium),
                Text('Password: admin123',        style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final List<Watch> watches;
  final DatabaseHelper db;
  final VoidCallback onRefresh;
  const _ProductsTab({required this.watches, required this.db, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: watches.length,
      itemBuilder: (_, i) {
        final w = watches[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.network(
                w.imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48, height: 48, color: AppColors.darkSurface,
                  child: const Icon(Icons.watch, color: AppColors.textSecondary, size: 20),
                ),
              ),
            ),
            title: Text(w.name, style: AppTextStyles.bodyLarge),
            subtitle: Text(
              '${w.brand} · ${AppHelpers.formatPrice(w.price)} · Stock: ${w.stock}',
              style: AppTextStyles.caption,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: AppHelpers.getStockColor(w.stock),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () async {
                    final confirm = await AppHelpers.showConfirmDialog(
                      context,
                      title:       'Delete Watch',
                      message:     'Are you sure you want to delete "${w.name}"?',
                      confirmText: 'Delete',
                      isDangerous: true,
                    );
                    if (confirm) {
                      await db.deleteWatch(w.id!);
                      onRefresh();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
