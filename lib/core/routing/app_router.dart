import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:booking_appointments/core/routing/app_routes.dart';
import 'package:booking_appointments/features/booking/presentation/views/booking_view.dart';

///* AppRouter — centralized GoRouter configuration.
///* All screen transitions use FadeTransition via _buildTransitionPage.

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.kBookingView,
    routes: [
      GoRoute(
        path: AppRoutes.kBookingView,
        pageBuilder: (context, state) => _buildTransitionPage(
          child: const BookingView(),
          state: state,
        ),
      ),
    ],
  );

  static CustomTransitionPage<void> _buildTransitionPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
