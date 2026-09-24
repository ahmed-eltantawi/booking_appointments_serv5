import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/about_tile_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/drawer_header_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/language_selector_tile_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/theme_selector_tile_widget.dart';

/// Navigation drawer for application settings and information.
class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeaderWidget(),
            SizedBox(height: 8.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 6.h),
                    child: Text(
                      l10n.settings.toUpperCase(),
                      style: AppTextStyles.bold12.copyWith(
                        color: colorScheme.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const LanguageSelectorTileWidget(),
                  const ThemeSelectorTileWidget(),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 6.h),
                    child: Text(
                      l10n.about.toUpperCase(),
                      style: AppTextStyles.bold12.copyWith(
                        color: colorScheme.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const AboutTileWidget(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                l10n.copyright,
                style: AppTextStyles.regular12.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

