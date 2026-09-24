import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:booking_appointments/l10n/app_localizations.dart';
import 'package:booking_appointments/core/services/settings_cubit.dart';
import 'package:booking_appointments/core/utils/app_text_styles.dart';

/// Drawer tile for selecting theme mode (System / Light / Dark) via a popup menu.
class ThemeSelectorTileWidget extends StatelessWidget {
  const ThemeSelectorTileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final settingsCubit = context.watch<SettingsCubit>();
    final currentThemeMode = settingsCubit.state.themeMode;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.palette_outlined,
            size: 22.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.theme,
              style: AppTextStyles.medium14.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
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
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                size: 20.r,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    style: AppTextStyles.regular14.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(
                    l10n.themeLight,
                    style: AppTextStyles.regular14.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(
                    l10n.themeDark,
                    style: AppTextStyles.regular14.copyWith(
                      color: Theme.of(context).colorScheme.primary,
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
