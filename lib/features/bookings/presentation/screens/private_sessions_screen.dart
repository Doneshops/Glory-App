import 'package:flutter/material.dart';
import 'package:glory_gym/core/core.dart';
import 'package:glory_gym/features/bookings/presentation/widgets/bookings_by_type_list.dart';

final class PrivateSessionsScreen extends StatelessWidget {
  const PrivateSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppPrimaryHeader(
        title: context.l10n.myPrivateSessions,
        showBack: true,
        centerTitle: true,
      ),
      body: BookingsByTypeList(
        type: BookingTypes.pt,
        emptyTitle: context.l10n.emptyPrivateSessionsTitle,
        emptyDescription: context.l10n.emptyPrivateSessionsDescription,
        showScanAction: true,
      ),
    );
  }
}
