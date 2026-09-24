import 'package:flutter/material.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/about_tile_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/drawer_header_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/language_selector_tile_widget.dart';
import 'package:booking_appointments/features/booking/presentation/widgets/theme_selector_tile_widget.dart';

/// Navigation drawer for application settings and information.
class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeaderWidget(),
          LanguageSelectorTileWidget(),
          ThemeSelectorTileWidget(),
          AboutTileWidget(),
        ],
      ),
    );
  }
}
