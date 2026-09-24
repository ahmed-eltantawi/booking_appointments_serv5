import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_appointments/core/services/services_locator.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_view_body.dart';

/// Top-level route widget for the booking feature.
/// Provides [BookingCubit] to the subtree and delegates layout to [BookingViewBody].
class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingCubit>()..initialize(),
      child: const Scaffold(
        body: SafeArea(child: BookingViewBody()),
      ),
    );
  }
}
