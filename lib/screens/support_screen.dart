import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'feedback_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  static const _faqs = [
    {
      'category': 'Orders',
      'icon': Icons.receipt_long_outlined,
      'items': [
        {
          'q': 'How do I track my order?',
          'a':
              'Go to Profile → Order History. Each order shows its current status: Pending, Processing, Shipped, or Delivered. You\'ll see a real-time update every time the status changes.',
        },
        {
          'q': 'Can I cancel my order?',
          'a':
              'Orders can be cancelled within 2 hours of placement if they haven\'t been processed yet. Go to Order History and tap Cancel. After processing begins, cancellation is no longer possible.',
        },
        {
          'q': 'How long does shipping take?',
          'a':
              'Standard shipping takes 5–7 business days. Express shipping (2–3 days) is available at checkout. International orders may take 10–14 days.',
        },
      ],
    },
    {
      'category': 'Returns & Refunds',
      'icon': Icons.replay_outlined,
      'items': [
        {
          'q': 'What is the return policy?',
          'a':
              'We offer 30-day hassle-free returns. Items must be in original condition with all packaging. Personalized or engraved items cannot be returned.',
        },
        {
          'q': 'How long do refunds take?',
          'a':
              'After we receive your return, refunds are processed within 3–5 business days. The amount will appear in your original payment method within 7–10 business days.',
        },
      ],
    },
    {
      'category': 'Products',
      'icon': Icons.watch_outlined,
      'items': [
        {
          'q': 'Are the watches genuine / authentic?',
          'a':
              'Absolutely. WatchHub is an authorized retailer for all brands we carry. Every watch comes with the manufacturer\'s warranty card and original packaging.',
        },
        {
          'q': 'Do the watches come with warranty?',
          'a':
              'Yes! All watches come with the manufacturer\'s official warranty — typically 2–5 years depending on the brand. We also offer an optional extended WatchHub protection plan.',
        },
        {
          'q': 'Can I get a watch serviced through WatchHub?',
          'a':
              'We offer servicing for most brands through our certified partners. Contact our support team for a service quote and to arrange collection.',
        },
      ],
    },
    {
      'category': 'Account & Payments',
      'icon': Icons.payment_outlined,
      'items': [
        {
          'q': 'Is my payment information secure?',
          'a':
              'Yes. All payments are processed through bank-grade 256-bit SSL encryption. We never store your full card details on our servers.',
        },
        {
          'q': 'How do I change my password?',
          'a':
              'Go to Profile → Edit Profile and tap "Change Password". You\'ll need to enter your current password before setting a new one.',
        },
        {
          'q': 'Can I have multiple shipping addresses?',
          'a':
              'Currently you can store one primary shipping address in your profile. You can update it at any time, or enter a different address at checkout.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return List.from(_faqs);
    final q = _searchQuery.toLowerCase();
    return _faqs
        .map((cat) {
          final items = (cat['items'] as List)
              .where((item) =>
                  (item['q'] as String).toLowerCase().contains(q) ||
                  (item['a'] as String).toLowerCase().contains(q))
              .toList();
          return {...cat, 'items': items};
        })
        .where((cat) => (cat['items'] as List).isNotEmpty)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _searchCtrl
        .addListener(() => setState(() => _searchQuery = _searchCtrl.text));
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.help_outline_rounded), text: 'FAQ'),
            Tab(icon: Icon(Icons.headset_mic_outlined), text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _FaqTab(
            searchCtrl: _searchCtrl,
            filteredFaqs: _filteredFaqs,
            searchQuery: _searchQuery,
          ),
          const _ContactTab(),
        ],
      ),
    );
  }
}

// ── FAQ Tab ───────────────────────────────────

class _FaqTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final List<Map<String, dynamic>> filteredFaqs;
  final String searchQuery;
  const _FaqTab({
    required this.searchCtrl,
    required this.filteredFaqs,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search frequently asked questions...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: searchCtrl.clear)
                  : null,
            ),
          ),
        ),
        Expanded(
          child: filteredFaqs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: AppSpacing.md),
                      Text('No results for "$searchQuery"',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                )
              : ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    ...filteredFaqs.map((cat) {
                      return _FaqCategory(
                        icon: cat['icon'] as IconData,
                        category: cat['category'] as String,
                        items:
                            (cat['items'] as List).cast<Map<String, dynamic>>(),
                      );
                    }).toList(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
        ),
      ],
    );
  }
}

class _FaqCategory extends StatelessWidget {
  final IconData icon;
  final String category;
  final List<Map<String, dynamic>> items;
  const _FaqCategory(
      {required this.icon, required this.category, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryLight),
            const SizedBox(width: AppSpacing.sm),
            Text(category,
                style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => _FaqTile(
              question: item['q'] as String,
              answer: item['a'] as String,
            )),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: _expanded
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.question,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                  ),
                  RotationTransition(
                    turns:
                        Tween<double>(begin: 0, end: 0.5).animate(_expandAnim),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Text(widget.answer, style: AppTextStyles.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Contact Tab ───────────────────────────────

class _ContactTab extends StatefulWidget {
  const _ContactTab();
  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── Contact cards ──────────────────────
        _ContactCard(
          icon: Icons.email_outlined,
          title: 'Email Support',
          sub: 'support@watchhub.com',
          detail: 'Response within 24 hours',
          color: AppColors.primaryLight,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        _ContactCard(
          icon: Icons.phone_outlined,
          title: 'Phone Support',
          sub: '+1 (800) WATCH-HUB',
          detail: 'Mon–Fri  9am – 6pm EST',
          color: AppColors.success,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        _ContactCard(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Live Chat',
          sub: 'Start a conversation',
          detail: 'Average wait: under 5 min',
          color: AppColors.warning,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen())),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Business hours ─────────────────────
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Business Hours', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.md),
              ...[
                ['Monday – Friday', '9:00 AM – 6:00 PM EST'],
                ['Saturday', '10:00 AM – 4:00 PM EST'],
                ['Sunday', 'Closed'],
              ].map((row) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(row[0],
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textPrimary)),
                        Text(row[1], style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final String detail;
  final Color color;
  final VoidCallback onTap;
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  Text(sub,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: color, fontWeight: FontWeight.w600)),
                  Text(detail, style: AppTextStyles.caption),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
