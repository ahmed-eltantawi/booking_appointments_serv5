import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';

/// Drawer tile for displaying app information dialog.
class AboutTileWidget extends StatelessWidget {
  const AboutTileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        leading: Icon(Icons.info_outline_rounded, size: 22.r),
        title: Text(
          'About',
          style: AppTextStyles.medium14.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onTap: () {
          showAboutDialog(
            context: context,
            applicationName: 'Appointment Booking',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2026 Serv5',
          );
        },
      ),
    );
  }
}
