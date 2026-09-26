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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36.r,
            height: 36.r,
            child: Icon(
              Icons.language_rounded,
              size: 20.r,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Language / اللغة',
              style: AppTextStyles.medium14.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: currentLocale,
              isDense: true,
              dropdownColor: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22.r,
                color: colorScheme.onSurfaceVariant,
              ),
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
                    style: AppTextStyles.medium14.copyWith(
                      color: currentLocale.languageCode == 'en'
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: const Locale('ar'),
                  child: Text(
                    'العربية',
                    style: AppTextStyles.medium14.copyWith(
                      color: currentLocale.languageCode == 'ar'
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
