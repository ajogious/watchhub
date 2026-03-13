// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cart.itemCount})'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirm = await AppHelpers.showConfirmDialog(
                  context,
                  title:       'Clear Cart',
                  message:     'Remove all items from cart?',
                  confirmText: 'Clear',
                  isDangerous: true,
                );
                if (confirm && auth.userId != null) {
                  cart.clearCart(auth.userId!);
                }
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
        ? const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textSecondary),
                SizedBox(height: AppSpacing.md),
                Text('Your cart is empty', style: AppTextStyles.heading3),
                SizedBox(height: AppSpacing.sm),
                Text('Browse our collection and add some watches!',
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: cart.items.length,
                  itemBuilder: (_, i) {
                    final item = cart.items[i];
                    final watch = item.watch;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: watch != null
                              ? Image.network(watch.imageUrl,
                                  width: 72, height: 72, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _watchPlaceholder())
                              : _watchPlaceholder(),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(watch?.brand ?? '', style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryLight)),
                                Text(watch?.name ?? '', style: AppTextStyles.bodyLarge,
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(AppHelpers.formatPrice(item.totalPrice),
                                    style: AppTextStyles.price.copyWith(fontSize: 15)),
                              ],
                            ),
                          ),
                          // Qty controls
                          Column(
                            children: [
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove,
                                    onTap: () => cart.updateQuantity(
                                        auth.userId!, item.id!, item.quantity - 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                    child: Text('${item.quantity}',
                                        style: AppTextStyles.bodyLarge),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    onTap: () => cart.updateQuantity(
                                        auth.userId!, item.id!, item.quantity + 1),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => cart.removeItem(auth.userId!, item.id!),
                                child: const Text('Remove',
                                    style: TextStyle(color: AppColors.error, fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Checkout Panel ─────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.darkCard,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: AppTextStyles.heading3),
                          Text(AppHelpers.formatPrice(cart.totalPrice),
                              style: AppTextStyles.price),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/checkout'),
                        child: const Text('PROCEED TO CHECKOUT'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _watchPlaceholder() => Container(
    width: 72, height: 72,
    color: AppColors.darkSurface,
    child: const Icon(Icons.watch_outlined, color: AppColors.textSecondary),
  );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}
