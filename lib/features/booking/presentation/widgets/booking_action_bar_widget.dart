import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';

/// Bottom action bar with Reset and Confirm Booking buttons.
///
/// [canConfirm] is pre-computed by [BookingViewBody] from the current state
/// to avoid subscribing to the bloc a second time.
class BookingActionBarWidget extends StatelessWidget {
  const BookingActionBarWidget({super.key, required this.canConfirm});

  /// True when a start time is selected and the booking is currently valid.
  final bool canConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final cubit = context.read<BookingCubit>();
    return Row(
      children: [
        // --- Reset ---
        Expanded(
          child: OutlinedButton(
            onPressed: cubit.reset,
            child: Text(l10n.reset),
          ),
        ),
        SizedBox(width: 12.w),

        // --- Confirm ---
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: canConfirm ? cubit.confirmBooking : null,
            child: Text(l10n.confirmBooking),
          ),
        ),
      ],
    );
  }
}
