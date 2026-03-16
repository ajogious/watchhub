import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

enum _FeedbackType { general, bug, feature, other }

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  _FeedbackType _type = _FeedbackType.general;
  double _appRating = 0;
  bool _submitted = false;
  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    // Simulate sending
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted)
      setState(() {
        _sending = false;
        _submitted = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback')),
      body: _submitted
          ? _SuccessView()
          : _FormView(
              formKey: _formKey,
              subjectCtrl: _subjectCtrl,
              bodyCtrl: _bodyCtrl,
              type: _type,
              appRating: _appRating,
              sending: _sending,
              onTypeChange: (t) => setState(() => _type = t),
              onRating: (r) => setState(() => _appRating = r),
              onSubmit: _submit,
            ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController subjectCtrl;
  final TextEditingController bodyCtrl;
  final _FeedbackType type;
  final double appRating;
  final bool sending;
  final void Function(_FeedbackType) onTypeChange;
  final void Function(double) onRating;
  final VoidCallback onSubmit;

  const _FormView({
    required this.formKey,
    required this.subjectCtrl,
    required this.bodyCtrl,
    required this.type,
    required this.appRating,
    required this.sending,
    required this.onTypeChange,
    required this.onRating,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── App rating ───────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Text(
                    'Rate Your Experience',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'How would you rate WatchHub overall?',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RatingBar.builder(
                    minRating: 1,
                    itemSize: 42,
                    glow: false,
                    unratedColor: AppColors.divider,
                    itemBuilder: (_, i) => Icon(
                      i < 3
                          ? Icons.sentiment_satisfied_alt_rounded
                          : Icons.star_rounded,
                      color: AppColors.warning,
                    ),
                    onRatingUpdate: onRating,
                  ),
                  if (appRating > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _ratingText(appRating),
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Type selector ────────────────────
            const Text(
              'Feedback Type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _FeedbackType.values.map((t) {
                final selected = type == t;
                return GestureDetector(
                  onTap: () => onTypeChange(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.darkCard,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _typeIcon(t),
                          size: 14,
                          color: selected
                              ? AppColors.dark
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _typeLabel(t),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.dark
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Subject ──────────────────────────
            const Text(
              'Subject',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: subjectCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Brief description of your feedback',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) => AppHelpers.validateRequired(v, 'Subject'),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Message ──────────────────────────
            const Text(
              'Message',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: bodyCtrl,
              maxLines: 6,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText:
                    'Please share the details of your feedback or issue...',
                filled: true,
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().length < 20) {
                  return 'Please provide at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Submit ───────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: sending ? null : onSubmit,
                child: sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.dark,
                        ),
                      )
                    : const Text(
                        'SEND FEEDBACK',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: AppColors.dark,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  String _typeLabel(_FeedbackType t) {
    switch (t) {
      case _FeedbackType.general:
        return 'General';
      case _FeedbackType.bug:
        return 'Bug Report';
      case _FeedbackType.feature:
        return 'Feature Request';
      case _FeedbackType.other:
        return 'Other';
    }
  }

  IconData _typeIcon(_FeedbackType t) {
    switch (t) {
      case _FeedbackType.general:
        return Icons.comment_outlined;
      case _FeedbackType.bug:
        return Icons.bug_report_outlined;
      case _FeedbackType.feature:
        return Icons.lightbulb_outline_rounded;
      case _FeedbackType.other:
        return Icons.more_horiz_rounded;
    }
  }

  String _ratingText(double r) {
    if (r >= 5) return 'Amazing! We love hearing that!';
    if (r >= 4) return 'Great! Thanks for your kind words.';
    if (r >= 3) return 'Good to know! We\'re always improving.';
    if (r >= 2) return 'We\'re sorry to hear that. Please tell us more.';
    return 'We apologize for the experience. We\'ll make it right.';
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 52,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Feedback Received!', style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Thank you for taking the time to share your thoughts. '
              'Our team will review your feedback and get back to you within 24 hours.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BACK TO SUPPORT'),
            ),
          ],
        ),
      ),
    );
  }
}
