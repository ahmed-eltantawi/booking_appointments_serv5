import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/services/services_locator.dart';
import 'package:booking_appointments/features/booking/presentation/manager/booking_cubit.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/animated_drawer_button.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/app_drawer_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/booking_view_body.dart';

//==============================================================================
/// Top-level route widget for the booking feature.
/// Provides [BookingCubit] to the subtree and delegates layout to [BookingViewBody].
//==============================================================================
class BookingView extends StatelessWidget {
  const BookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    
    // 1. we inject the BookingCubit at the root of the screen
    return BlocProvider(
      // we get the instance from GetIt and initialize it immediately
      create: (_) => getIt<BookingCubit>()..initialize(),
      
      // 2. build the scaffold
      child: Scaffold(
        appBar: AppBar(
          leading: const AnimatedDrawerButton(),
          title: Text(l10n.bookAppointment),
          centerTitle: true,
        ),
        
        // 3. setup the side drawer for navigation/settings
        drawer: const AppDrawerWidget(),
        
        // 4. render the main body inside a SafeArea to avoid notches
        body: const SafeArea(
          child: BookingViewBody(),
        ),
      ),
    );
  }
}
