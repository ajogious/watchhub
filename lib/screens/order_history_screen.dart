// lib/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/database_helper.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _db          = DatabaseHelper();
  List<OrderItem> _orders = [];
  bool            _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;
    final orders = await _db.getOrdersByUser(userId);
    if (mounted) setState(() { _orders = orders; _loading = false; });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':  return AppColors.success;
      case 'shipped':    return AppColors.primaryLight;
      case 'processing': return AppColors.warning;
      case 'cancelled':  return AppColors.error;
      default:           return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
        : _orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: AppSpacing.md),
                  Text('No orders yet', style: AppTextStyles.bodyMedium),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _orders.length,
              itemBuilder: (_, i) {
                final order = _orders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Watch image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: order.watch != null
                            ? Image.network(
                                order.watch!.imageUrl,
                                width: 60, height: 60, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60, height: 60,
                                  color: AppColors.darkSurface,
                                  child: const Icon(Icons.watch, color: AppColors.textSecondary),
                                ),
                              )
                            : Container(
                                width: 60, height: 60,
                                color: AppColors.darkSurface,
                                child: const Icon(Icons.watch, color: AppColors.textSecondary),
                              ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.watch?.name ?? 'Unknown Watch',
                                style: AppTextStyles.bodyLarge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('Qty: ${order.quantity}', style: AppTextStyles.caption),
                              Text(AppHelpers.formatDate(order.orderedAt), style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppHelpers.formatPrice(order.totalPrice),
                              style: AppTextStyles.price.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(order.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(color: _statusColor(order.status), width: 0.5),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor(order.status),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
