import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:glory_gym/core/core.dart';
import 'package:glory_gym/features/bookings/presentation/bookings_refresh_notifier.dart';
import 'package:glory_gym/features/bookings/presentation/cubits/bookings_list/bookings_list_cubit.dart';
import 'package:glory_gym/features/bookings/presentation/cubits/session_checkin_scan/session_checkin_scan_cubit.dart';
import 'package:glory_gym/features/bookings/presentation/utils/pt_session_scan_flow.dart';
import 'package:glory_gym/features/bookings/presentation/widgets/booking_card.dart';

/// Booking `type` values returned by `GET /mobile/bookings`.
abstract final class BookingTypes {
  /// Private (personal-training) session with a coach.
  static const pt = 'PT';

  /// Group class the member was booked into from the dashboard.
  static const groupClass = 'CLASS';
}

/// Lists the member's bookings of a single [type]
/// (`GET /mobile/bookings?type=...`, filtered server-side).
final class BookingsByTypeList extends StatelessWidget {
  const BookingsByTypeList({
    super.key,
    required this.type,
    required this.emptyTitle,
    required this.emptyDescription,
    this.showScanAction = false,
    this.padding = const EdgeInsets.all(18),
    this.actionPadding = const EdgeInsets.fromLTRB(18, 0, 18, 18),
  });

  final String type;
  final String emptyTitle;
  final String emptyDescription;

  /// Shows the "scan the coach's session QR" button (PT sessions only).
  final bool showScanAction;

  /// Padding around the list of booking cards.
  final EdgeInsetsGeometry padding;

  /// Padding around the bottom scan button.
  final EdgeInsetsGeometry actionPadding;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<BookingsListCubit>()..loadBookings(type: type),
        ),
        BlocProvider(create: (_) => sl<SessionCheckinScanCubit>()),
      ],
      child: _BookingsByTypeView(
        type: type,
        emptyTitle: emptyTitle,
        emptyDescription: emptyDescription,
        showScanAction: showScanAction,
        padding: padding,
        actionPadding: actionPadding,
      ),
    );
  }
}

final class _BookingsByTypeView extends StatefulWidget {
  const _BookingsByTypeView({
    required this.type,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.showScanAction,
    required this.padding,
    required this.actionPadding,
  });

  final String type;
  final String emptyTitle;
  final String emptyDescription;
  final bool showScanAction;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry actionPadding;

  @override
  State<_BookingsByTypeView> createState() => _BookingsByTypeViewState();
}

final class _BookingsByTypeViewState extends State<_BookingsByTypeView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= maxScroll - 200) {
      context.read<BookingsListCubit>().loadMore(type: widget.type);
    }
  }

  Future<void> _refresh() => context
      .read<BookingsListCubit>()
      .loadBookings(refresh: true, type: widget.type);

  void _openScan(BuildContext context) {
    PtSessionScanFlow.openScannerAndSubmit(
      context,
      onBookingUpdated: () {
        _refresh();
        BookingsRefreshNotifier.request();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;

    return BlocBuilder<BookingsListCubit, BookingsListState>(
      builder: (context, state) {
        if (state.isLoading && state.bookings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isEmpty) {
          return AppPlatformRefreshScroll(
            fillViewport: true,
            onRefresh: _refresh,
            child: AppEmptyState(
              icon: AppEmptyIcons.bookings,
              title: widget.emptyTitle,
              description: widget.emptyDescription,
              action: widget.showScanAction
                  ? AppButton(
                      label: context.l10n.ptScanSessionTitle,
                      onPressed: () => _openScan(context),
                    )
                  : null,
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: AppPlatformRefreshListView(
                controller: _scrollController,
                padding: widget.padding,
                onRefresh: _refresh,
                itemCount:
                    state.bookings.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index >= state.bookings.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final booking = state.bookings[index];
                  return BookingCard(
                    item: BookingUtils.toBookingItem(
                      booking,
                      l10n: context.l10n,
                      locale: locale,
                      onTap: () => context.push(
                        AppRoutes.bookingDetail.replaceFirst(':id', booking.id),
                      ),
                      onScanSessionQr: () => _openScan(context),
                      onCheckIn: booking.canCheckIn
                          ? () => context
                                .read<BookingsListCubit>()
                                .checkInBooking(booking.id)
                          : null,
                      onEvaluate: booking.canRate
                          ? () => context.push(
                              AppRoutes.classEvaluation,
                              extra: booking.id,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            if (widget.showScanAction)
              Padding(
                padding: widget.actionPadding,
                child: AppButton(
                  label: context.l10n.ptScanSessionTitle,
                  onPressed: () => _openScan(context),
                ),
              ),
          ],
        );
      },
    );
  }
}
