import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addrCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  bool _placing = false;

  @override
  void dispose() {
    _addrCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final address = '${_addrCtrl.text}, ${_cityCtrl.text}';

    final success = await cart.placeOrder(auth.userId!, address);

    if (!mounted) return;
    setState(() => _placing = false);

    if (success) {
      AppHelpers.showSnackBar(context, '🎉 Order placed successfully!',
          isSuccess: true);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (r) => false);
    } else {
      AppHelpers.showSnackBar(
          context, 'Failed to place order. Please try again.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text('Shipping Details', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _addrCtrl,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) => AppHelpers.validateRequired(v, 'Address'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: (v) => AppHelpers.validateRequired(v, 'City'),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: AppTextStyles.heading3),
                Text(
                  AppHelpers.formatPrice(cart.totalPrice),
                  style: AppTextStyles.price,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _placing ? null : _placeOrder,
              child: _placing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.dark),
                    )
                  : const Text('PLACE ORDER'),
            ),
          ],
        ),
      ),
    );
  }
}
