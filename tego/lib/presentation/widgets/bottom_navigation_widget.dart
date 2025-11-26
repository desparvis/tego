import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_localizations_helper.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/navigation_helper.dart';
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

    NavigationHelper.navigateAndReplace(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          minHeight: kBottomNavigationBarHeight,
          maxHeight: isSmallScreen ? 60 : kBottomNavigationBarHeight,
        ),
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
          selectedLabelStyle: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 10 : 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: isSmallScreen ? 10 : 12,
          ),
          selectedFontSize: isSmallScreen ? 10 : 12,
          unselectedFontSize: isSmallScreen ? 10 : 12,
          iconSize: isSmallScreen ? 20 : 24,
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
              icon: Icon(Icons.add_circle, size: isSmallScreen ? 28 : 32),
              label: AppLocalizationsHelper.of(context).addSale,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: AppLocalizationsHelper.of(context).settings,
            ),
          ],
        ),
      ),
    );
  }
}