import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_localizations_helper.dart';
import '../pages/landing_screen.dart';
import '../pages/sales_list_screen.dart';
import '../pages/sales_recording_screen.dart';
import '../pages/settings_screen.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
  });

  void _navigateToScreen(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const LandingScreen();
        break;
      case 1:
        screen = const SalesListScreen();
        break;
      case 2:
        screen = const SalesRecordingScreen();
        break;
      case 3:
        screen = const SettingsScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppConstants.primaryPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppConstants.fontFamily,
        ),
        onTap: (index) => _navigateToScreen(context, index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizationsHelper.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            label: AppLocalizationsHelper.of(context).sales,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle, size: 32),
            label: AppLocalizationsHelper.of(context).addSale,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizationsHelper.of(context).settings,
          ),
        ],
      ),
    );
  }
}