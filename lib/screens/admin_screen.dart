import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/watch.dart';
import '../models/order.dart';
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
  late TabController _tab;

  Map<String, int> _stats = {};
  List<Watch> _watches = [];
  List<OrderItem> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stats = await _db.getAdminStats();
    final watches = await _db.getWatches();
    final orders = await _db.getAllOrders();
    if (mounted) {
      setState(() {
        _stats = stats;
        _watches = watches;
        _orders = orders;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings_rounded,
                size: 20, color: AppColors.primaryLight),
            SizedBox(width: AppSpacing.sm),
            Text('Admin Panel'),
          ],
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Products'),
            Tab(text: 'Orders'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryLight))
          : TabBarView(
              controller: _tab,
              children: [
                _DashboardTab(stats: _stats),
                _ProductsTab(
                    watches: _watches,
                    db: _db,
                    onRefresh: _load,
                    context: context),
                _OrdersTab(orders: _orders, db: _db, onRefresh: _load),
              ],
            ),
      floatingActionButton: AnimatedBuilder(
        animation: _tab,
        builder: (_, __) => _tab.index == 1
            ? FloatingActionButton.extended(
                onPressed: () => _showAddProductDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Watch'),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _AddProductSheet(
        db: _db,
        onSaved: _load,
      ),
    );
  }
}

// ── Dashboard Tab ─────────────────────────────

class _DashboardTab extends StatelessWidget {
  final Map<String, int> stats;
  const _DashboardTab({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Text('Overview', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.md),

        // Stat grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.6,
          children: [
            _StatCard('Users', stats['users'] ?? 0,
                Icons.people_outline_rounded, AppColors.primaryLight),
            _StatCard('Watches', stats['watches'] ?? 0, Icons.watch_rounded,
                AppColors.accent),
            _StatCard('Orders', stats['orders'] ?? 0,
                Icons.shopping_bag_outlined, AppColors.success),
            _StatCard('Reviews', stats['reviews'] ?? 0,
                Icons.star_outline_rounded, AppColors.warning),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),
        const Text('Quick Actions', style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.md),

        ...[
          [
            'View All Orders',
            Icons.receipt_long_outlined,
            AppColors.primaryLight
          ],
          ['Manage Products', Icons.inventory_2_outlined, AppColors.success],
          ['Export Reports', Icons.download_outlined, AppColors.accent],
        ].map((item) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: const BorderSide(color: AppColors.divider),
                ),
                tileColor: AppColors.darkCard,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (item[2] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(item[1] as IconData,
                      color: item[2] as Color, size: 18),
                ),
                title: Text(item[0] as String, style: AppTextStyles.bodyLarge),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ),
            )),

        const SizedBox(height: AppSpacing.lg),
        // Credentials reminder
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Credentials',
                  style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: AppSpacing.xs),
              Text('Email: admin@watchhub.com', style: AppTextStyles.caption),
              Text('Password: admin123', style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: color,
                  )),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Products Tab ──────────────────────────────

class _ProductsTab extends StatelessWidget {
  final List<Watch> watches;
  final DatabaseHelper db;
  final VoidCallback onRefresh;
  final BuildContext context;
  const _ProductsTab({
    required this.watches,
    required this.db,
    required this.onRefresh,
    required this.context,
  });

  @override
  Widget build(BuildContext c) {
    return watches.isEmpty
        ? const Center(
            child: Text('No products yet', style: AppTextStyles.bodyMedium))
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: watches.length,
            itemBuilder: (_, i) {
              final w = watches[i];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppRadius.md)),
                      child: Image.network(
                        w.imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: AppColors.darkSurface,
                          child: const Icon(Icons.watch_outlined,
                              color: AppColors.textSecondary, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.name,
                                style: AppTextStyles.bodyLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(
                                '${w.brand}  ·  ${AppHelpers.formatPrice(w.price)}',
                                style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppHelpers.getStockColor(w.stock),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(AppHelpers.getStockLabel(w.stock),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppHelpers.getStockColor(w.stock),
                                      fontWeight: FontWeight.w600,
                                    )),
                                const SizedBox(width: AppSpacing.sm),
                                Text('(${w.stock} left)',
                                    style: AppTextStyles.caption),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Actions
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (w.isFeatured)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('★',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primaryLight)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error, size: 20),
                          onPressed: () async {
                            final confirm = await AppHelpers.showConfirmDialog(
                              c,
                              title: 'Delete Product',
                              message:
                                  'Delete "${w.name}"? This cannot be undone.',
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
                  ],
                ),
              );
            },
          );
  }
}

// ── Orders Tab ────────────────────────────────

class _OrdersTab extends StatelessWidget {
  final List<OrderItem> orders;
  final DatabaseHelper db;
  final VoidCallback onRefresh;
  const _OrdersTab(
      {required this.orders, required this.db, required this.onRefresh});

  Color _statusColor(String s) {
    switch (s) {
      case 'delivered':
        return AppColors.success;
      case 'shipped':
        return AppColors.primaryLight;
      case 'processing':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
          child: Text('No orders yet', style: AppTextStyles.bodyMedium));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final o = orders[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Order #${o.id}',
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showStatusPicker(context, o),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(o.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                            color: _statusColor(o.status), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(o.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _statusColor(o.status),
                                letterSpacing: 0.5,
                              )),
                          const SizedBox(width: 2),
                          Icon(Icons.edit_outlined,
                              size: 10, color: _statusColor(o.status)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                      child:
                          _OrderDetail('Product', o.watch?.name ?? 'Unknown')),
                  Expanded(child: _OrderDetail('Qty', '${o.quantity}')),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                      child: _OrderDetail(
                          'Total', AppHelpers.formatPrice(o.totalPrice))),
                  Expanded(
                      child: _OrderDetail(
                          'Date', AppHelpers.formatDate(o.orderedAt))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatusPicker(BuildContext ctx, OrderItem order) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Update Status — Order #${order.id}',
                style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.md),
            ...['pending', 'processing', 'shipped', 'delivered', 'cancelled']
                .map((s) => ListTile(
                      title: Text(s.toUpperCase(),
                          style: TextStyle(
                              color: _statusColor(s),
                              fontWeight: order.status == s
                                  ? FontWeight.w800
                                  : FontWeight.w400)),
                      trailing: order.status == s
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.primaryLight)
                          : null,
                      onTap: () async {
                        await db.updateOrderStatus(order.id!, s);
                        onRefresh();
                        Navigator.pop(ctx);
                      },
                    )),
          ],
        ),
      ),
    );
  }
}

class _OrderDetail extends StatelessWidget {
  final String label;
  final String value;
  const _OrderDetail(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      );
}

// ── Add Product Sheet ──────────────────────────

class _AddProductSheet extends StatefulWidget {
  final DatabaseHelper db;
  final VoidCallback onSaved;
  const _AddProductSheet({required this.db, required this.onSaved});
  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imgCtrl = TextEditingController();

  String _category = WatchCategories.all[1];
  bool _featured = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final watch = Watch(
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      category: _category,
      description: _descCtrl.text.trim(),
      imageUrl: _imgCtrl.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=500'
          : _imgCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 0,
      stock: int.tryParse(_stockCtrl.text) ?? 0,
      isFeatured: _featured,
    );
    await widget.db.upsertWatch(watch);
    widget.onSaved();
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      AppHelpers.showSnackBar(context, 'Product added successfully!',
          isSuccess: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Add New Watch', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Watch Name'),
                  validator: (v) => AppHelpers.validateRequired(v, 'Name'),
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                    child: TextFormField(
                  controller: _brandCtrl,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  validator: (v) => AppHelpers.validateRequired(v, 'Brand'),
                )),
              ]),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Price (\$)', prefixText: '\$'),
                  validator: (v) {
                    if (v == null || double.tryParse(v) == null) {
                      return 'Enter valid price';
                    }
                    return null;
                  },
                )),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                    child: TextFormField(
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock Qty'),
                )),
              ]),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppColors.darkSurface,
                decoration: const InputDecoration(labelText: 'Category'),
                items: WatchCategories.all
                    .skip(1)
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _imgCtrl,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                value: _featured,
                onChanged: (v) => setState(() => _featured = v),
                title: const Text('Feature on Homepage',
                    style: AppTextStyles.bodyMedium),
                activeColor: AppColors.primaryLight,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.dark))
                      : const Text('SAVE PRODUCT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
