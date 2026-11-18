import 'package:flutter/material.dart';
import 'package:glory_gym/core/core.dart';
import 'package:glory_gym/features/bookings/domain/entities/booking_entity.dart';
import 'package:glory_gym/features/bookings/presentation/widgets/booking_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:glory_gym/core/l10n/l10n.dart';

/// Gym registration tab: QR flow and regenerate action.
final class HomeGymRegistrationTabContent extends StatelessWidget {
  const HomeGymRegistrationTabContent({
    super.key,
    required this.hasQr,
    required this.qrData,
    required this.secondsLeft,
    required this.isGenerating,
    required this.canRegenerate,
    required this.isExpired,
    required this.isFirstGenerate,
    required this.onGenerateQr,
  });

  final bool hasQr;
  final String? qrData;
  final int secondsLeft;
  final bool isGenerating;
  final bool canRegenerate;
  final bool isExpired;
  final bool isFirstGenerate;
  final VoidCallback onGenerateQr;

  @override
  Widget build(BuildContext context) {
    final showQr = hasQr && qrData != null;
    final secondsLabel = secondsLeft.clamp(0, 99).toString().padLeft(2, '0');
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showQr)
          Expanded(
            child: Center(
              child: AppEntrance(
                delay: const Duration(milliseconds: 60),
                offset: const Offset(0, 0.08),
                duration: const Duration(milliseconds: 480),
                child: _HomeQrCard(qrData: qrData!),
              ),
            ),
          )
        else
          Expanded(
            child: AppEmptyState(
              icon: AppEmptyIcons.qr,
              title: isExpired ? l10n.emptyQrExpiredTitle : l10n.emptyQrTitle,
              description: isExpired
                  ? l10n.emptyQrExpiredDescription
                  : l10n.emptyQrDescription,
              compact: true,
            ),
          ),
        if (showQr) ...[
          AppEntrance(
            delay: const Duration(milliseconds: 140),
            child: Text(
              l10n.codeExpiresInSeconds(secondsLabel),
              textAlign: TextAlign.center,
              style: context.captionRegular.copyWith(
                color: AppColors.neutral1000,
              ),
            ),
          ),
          16.vertical,
        ],
        AppEntrance(
          delay: Duration(milliseconds: showQr ? 200 : 80),
          offset: const Offset(0, 0.1),
          child: AppButton(
            label: isFirstGenerate
                ? l10n.generateQrCode
                : l10n.generateNewQrCode,
            isLoading: isGenerating,
            onPressed: canRegenerate && !isGenerating ? onGenerateQr : null,
          ),
        ),
      ],
    );
  }
}

final class _HomeQrCard extends StatefulWidget {
  const _HomeQrCard({required this.qrData});

  final String qrData;

  @override
  State<_HomeQrCard> createState() => _HomeQrCardState();
}

final class _HomeQrCardState extends State<_HomeQrCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  static const _qrBg = Color(0xFFFFF9EB);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _HomeQrCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qrData != widget.qrData) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _qrBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: QrImageView(
          data: widget.qrData,
          version: QrVersions.auto,
          size: 200,
          backgroundColor: _qrBg,
        ),
      ),
    );
  }
}

/// Bookings preview (appointments / group classes tabs) with a "view all"
/// link. [title], [emptyTitle] and [emptyDescription] default to the
/// appointments copy.
final class HomeAppointmentsTabContent extends StatelessWidget {
  const HomeAppointmentsTabContent({
    super.key,
    required this.bookings,
    this.title,
    this.emptyTitle,
    this.emptyDescription,
    required this.locale,
    required this.isLoading,
    this.onViewAll,
    this.onCheckIn,
    this.onScanSessionQr,
    this.onOpenDetail,
    this.onCancel,
    this.onEvaluate,
  });

  final List<BookingEntity> bookings;
  final String? title;
  final String? emptyTitle;
  final String? emptyDescription;
  final String locale;
  final bool isLoading;
  final VoidCallback? onViewAll;
  final void Function(String id)? onCheckIn;
  final VoidCallback? onScanSessionQr;
  final void Function(String id)? onOpenDetail;
  final void Function(String id)? onCancel;
  final void Function(String id)? onEvaluate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppEntrance(
          delay: const Duration(milliseconds: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title ?? context.l10n.recentBookings,
                style: context.highlightBold.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  context.l10n.seeAll,
                  style: context.captionRegular.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading && bookings.isEmpty)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (bookings.isEmpty)
          Expanded(
            child: AppEmptyState(
              icon: AppEmptyIcons.bookings,
              title: emptyTitle ?? context.l10n.emptyBookingsTitle,
              description:
                  emptyDescription ?? context.l10n.emptyBookingsDescription,
              compact: true,
            ),
          )
        else
          ...bookings.asMap().entries.map(
            (entry) => AppEntrance(
              delay: Duration(milliseconds: 80 + (entry.key * 90)),
              offset: const Offset(0, 0.07),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: BookingCard(
                  item: BookingUtils.toBookingItem(
                    entry.value,
                    l10n: context.l10n,
                    locale: locale,
                    onTap: () => onOpenDetail?.call(entry.value.id),
                    onScanSessionQr: entry.value.isPrivateTraining &&
                            entry.value.canCheckIn
                        ? onScanSessionQr
                        : null,
                    onCheckIn: entry.value.canCheckIn
                        ? () => onCheckIn?.call(entry.value.id)
                        : null,
                    onCancel: entry.value.canCancel
                        ? () => onCancel?.call(entry.value.id)
                        : null,
                    onEvaluate: entry.value.canRate
                        ? () => onEvaluate?.call(entry.value.id)
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
