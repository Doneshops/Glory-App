import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/extensions/extensions.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/models/content_args.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles_extension.dart';
import '../../../../core/widgets/app_button.dart';

/// Shown in place of the Sandy chat until the member agrees that messages
/// and attachments go to a third-party AI provider. Nothing is sent before
/// [onAgree]; declining is simply leaving the tab.
final class SandyConsentGate extends StatefulWidget {
  const SandyConsentGate({super.key, required this.onAgree});

  final Future<void> Function() onAgree;

  @override
  State<SandyConsentGate> createState() => _SandyConsentGateState();
}

final class _SandyConsentGateState extends State<SandyConsentGate> {
  var _submitting = false;

  Future<void> _agree() async {
    setState(() => _submitting = true);
    await widget.onAgree();
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              children: [
                const _SandyBadge(),
                16.vertical,
                Text(
                  l10n.sandyConsentTitle,
                  textAlign: TextAlign.center,
                  style: context.heading5.copyWith(
                    color: AppColors.neutral1000,
                  ),
                ),
                8.vertical,
                Text(
                  l10n.sandyConsentIntro,
                  textAlign: TextAlign.center,
                  style: context.captionRegular.copyWith(
                    color: AppColors.neutral600,
                    height: 1.6,
                  ),
                ),
                24.vertical,
                _ConsentPoint(
                  icon: Iconsax.export_1,
                  title: l10n.sandyConsentDataTitle,
                  body: l10n.sandyConsentDataBody,
                ),
                _ConsentPoint(
                  icon: Iconsax.health,
                  title: l10n.sandyConsentMedicalTitle,
                  body: l10n.sandyConsentMedicalBody,
                ),
                _ConsentPoint(
                  icon: Iconsax.shield_tick,
                  title: l10n.sandyConsentChoiceTitle,
                  body: l10n.sandyConsentChoiceBody,
                ),
                4.vertical,
                TextButton.icon(
                  onPressed: () => context.push(
                    AppRoutes.simpleContent,
                    extra: const SimpleContentArgs(pageKey: 'PRIVACY'),
                  ),
                  icon: const Icon(Iconsax.document_text, size: 18),
                  label: Text(l10n.sandyConsentPrivacyLink),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary800,
                    textStyle: context.captionBold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: AppButton(
              label: l10n.sandyConsentAgree,
              isLoading: _submitting,
              onPressed: _agree,
            ),
          ),
        ),
      ],
    );
  }
}

final class _SandyBadge extends StatelessWidget {
  const _SandyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary100,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/svgs/ai_icon.svg',
          width: 36,
          height: 36,
          colorFilter: const ColorFilter.mode(
            AppColors.primary800,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

final class _ConsentPoint extends StatelessWidget {
  const _ConsentPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.contentBold.copyWith(
                    color: AppColors.neutral1000,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: context.captionRegular.copyWith(
                    color: AppColors.neutral600,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
