import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';

/// Drawer tile for switching language between English and Arabic.
class LanguageSelectorTileWidget extends StatelessWidget {
  const LanguageSelectorTileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCubit = context.watch<SettingsCubit>();
    final currentLocale = settingsCubit.state.locale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        leading: Icon(Icons.language_rounded, size: 22.r),
        title: Text(
          'Language / اللغة',
          style: AppTextStyles.medium14.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<Locale>(
            value: currentLocale,
            icon: Icon(Icons.arrow_drop_down_rounded, size: 20.r),
            onChanged: (locale) {
              if (locale != null) {
                settingsCubit.setLocale(locale);
              }
            },
            items: [
              DropdownMenuItem(
                value: const Locale('en'),
                child: Text(
                  'English',
                  style: AppTextStyles.regular14.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: const Locale('ar'),
                child: Text(
                  'العربية',
                  style: AppTextStyles.regular14.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
