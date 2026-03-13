// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _addrCtrl   = TextEditingController();
  final _cityCtrl   = TextEditingController();
  final _countryCtrl= TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _startEdit(dynamic user) {
    _nameCtrl.text    = user.name;
    _phoneCtrl.text   = user.phone;
    _addrCtrl.text    = user.address;
    _cityCtrl.text    = user.city;
    _countryCtrl.text = user.country;
    setState(() => _editing = true);
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final updated = auth.currentUser!.copyWith(
      name:    _nameCtrl.text.trim(),
      phone:   _phoneCtrl.text.trim(),
      address: _addrCtrl.text.trim(),
      city:    _cityCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
    );
    final error = await auth.updateProfile(updated);
    if (!mounted) return;
    setState(() => _editing = false);
    AppHelpers.showSnackBar(context,
        error ?? 'Profile updated!', isSuccess: error == null, isError: error != null);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryLight));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _startEdit(user),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // ── Avatar ──────────────────────────
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(user.name,  style: AppTextStyles.heading3),
            Text(user.email, style: AppTextStyles.bodyMedium),
            if (user.isAdmin) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Text('ADMIN', style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1,
                )),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),

            if (_editing)
              // ── Edit Form ──────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => AppHelpers.validateRequired(v, 'Name'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _addrCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Address', prefixIcon: Icon(Icons.home_outlined)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(child: TextFormField(
                          controller: _cityCtrl,
                          decoration: const InputDecoration(labelText: 'City'),
                        )),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: TextFormField(
                          controller: _countryCtrl,
                          decoration: const InputDecoration(labelText: 'Country'),
                        )),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _editing = false),
                            child: const Text('CANCEL'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveEdit,
                            child: const Text('SAVE'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              // ── Info Display ───────────────────
              Column(
                children: [
                  _InfoTile(Icons.phone_outlined, 'Phone',
                      user.phone.isEmpty ? 'Not set' : user.phone),
                  _InfoTile(Icons.location_on_outlined, 'Address',
                      user.address.isEmpty ? 'Not set' : user.address),
                  _InfoTile(Icons.location_city_outlined, 'City',
                      user.city.isEmpty ? 'Not set' : user.city),
                  _InfoTile(Icons.flag_outlined, 'Country',
                      user.country.isEmpty ? 'Not set' : user.country),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Quick Links ──────────────────
                  _ActionTile(Icons.receipt_long_outlined, 'Order History', () =>
                      Navigator.pushNamed(context, '/order-history')),
                  if (user.isAdmin)
                    _ActionTile(Icons.admin_panel_settings_outlined, 'Admin Panel', () =>
                        Navigator.pushNamed(context, '/admin')),
                  _ActionTile(Icons.support_agent_outlined, 'Customer Support', () =>
                      _showSupport(context)),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Logout ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          foregroundColor: AppColors.error),
                      onPressed: () async {
                        final confirm = await AppHelpers.showConfirmDialog(
                          context,
                          title:       'Logout',
                          message:     'Are you sure you want to logout?',
                          confirmText: 'Logout',
                          isDangerous: true,
                        );
                        if (confirm) {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          }
                        }
                      },
                      icon:  const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showSupport(BuildContext context) {
    showModalBottomSheet(
      context:          context,
      backgroundColor:  AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const _SupportSheet(),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight, size: 20),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value,  style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  const _ActionTile(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryLight),
      title:   Text(label, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}

class _SupportSheet extends StatefulWidget {
  const _SupportSheet();
  @override
  State<_SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends State<_SupportSheet> {
  final _msgCtrl = TextEditingController();
  bool _sent = false;

  final _faqs = [
    {'q': 'How do I track my order?', 'a': 'Go to Profile → Order History to view your order status.'},
    {'q': 'What is your return policy?', 'a': 'We accept returns within 30 days in original condition.'},
    {'q': 'Is my payment information secure?', 'a': 'Yes, all payments are encrypted and secure.'},
    {'q': 'How long does shipping take?', 'a': 'Standard: 5-7 days. Express: 2-3 days.'},
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.9,
      initialChildSize: 0.6,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ListView(
          controller: ctrl,
          children: [
            const Text('Customer Support', style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.lg),
            const Text('FAQ', style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            ..._faqs.map((f) => ExpansionTile(
              title: Text(f['q']!, style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  child: Text(f['a']!, style: AppTextStyles.bodyMedium),
                ),
              ],
            )),
            const SizedBox(height: AppSpacing.lg),
            const Text('Contact Us', style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            if (!_sent) ...[
              TextField(
                controller: _msgCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe your issue...',
                  filled: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  if (_msgCtrl.text.trim().isNotEmpty) {
                    setState(() => _sent = true);
                  }
                },
                child: const Text('SEND MESSAGE'),
              ),
            ] else
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: AppColors.success),
                    SizedBox(height: AppSpacing.sm),
                    Text('Message sent! We\'ll get back to you within 24 hours.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
