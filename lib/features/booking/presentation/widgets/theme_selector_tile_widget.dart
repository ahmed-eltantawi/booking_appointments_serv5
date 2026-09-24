import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';

/// Drawer tile for selecting theme mode (System / Light / Dark) via a popup dropdown.
class ThemeSelectorTileWidget extends StatelessWidget {
  const ThemeSelectorTileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final settingsCubit = context.watch<SettingsCubit>();
    final currentThemeMode = settingsCubit.state.themeMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.palette_outlined,
              size: 20.r,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.theme,
              style: AppTextStyles.medium14.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          DropdownButtonHideUnderline(
            child: DropdownButton<ThemeMode>(
              value: currentThemeMode,
              isDense: true,
              dropdownColor: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22.r,
                color: colorScheme.onSurfaceVariant,
              ),
              onChanged: (mode) {
                if (mode != null) {
                  settingsCubit.setThemeMode(mode);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(
                    l10n.themeSystem,
                    style: AppTextStyles.medium14.copyWith(
                      color: currentThemeMode == ThemeMode.system
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(
                    l10n.themeLight,
                    style: AppTextStyles.medium14.copyWith(
                      color: currentThemeMode == ThemeMode.light
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(
                    l10n.themeDark,
                    style: AppTextStyles.medium14.copyWith(
                      color: currentThemeMode == ThemeMode.dark
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

