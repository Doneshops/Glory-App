import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glory_gym/core/core.dart';
import 'package:glory_gym/features/bookings/presentation/cubits/bookings_list/bookings_list_cubit.dart';

/// Confirm-then-cancel flow for a booking card. Uses the nearest
/// [BookingsListCubit] above [context].
abstract final class BookingCancelUi {
  static Future<void> confirmAndCancel(
    BuildContext context,
    String bookingId,
  ) async {
    final shouldCancel = await AppConfirmDialog.show(
      context,
      title: context.l10n.cancelClass,
      message: context.l10n.confirmCancelClass,
      confirmLabel: context.l10n.cancelClass,
    );

    if (shouldCancel != true || !context.mounted) return;

    final success =
        await context.read<BookingsListCubit>().cancelBooking(bookingId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.classCancelledSuccess)),
      );
      return;
    }

    final error = context.read<BookingsListCubit>().state.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }
}
