import 'package:flutter/material.dart';
import '../../presentation/pages/splash_screen.dart';
import '../../presentation/pages/landing_screen.dart';
import '../../presentation/pages/sales_list_screen.dart';
import '../../presentation/pages/sales_recording_screen.dart';
import '../../presentation/pages/expense_list_screen.dart';
import '../../presentation/pages/expense_recording_screen.dart';
import '../../presentation/pages/sign_in_screen.dart';
import '../../presentation/pages/sign_up_screen.dart';
import '../../presentation/pages/settings_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String salesList = '/sales-list';
  static const String salesRecording = '/sales-recording';
  static const String expenseList = '/expense-list';
  static const String expenseRecording = '/expense-recording';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case signIn:
        return _buildRoute(const SignInScreen(), settings);
      case signUp:
        return _buildRoute(const SignUpScreen(), settings);
      case home:
        return _buildRoute(const LandingScreen(), settings);
      case salesList:
        return _buildRoute(const SalesListScreen(), settings);
      case salesRecording:
        return _buildRoute(const SalesRecordingScreen(), settings);
      case expenseList:
        return _buildRoute(const ExpenseListScreen(), settings);
      case expenseRecording:
        return _buildRoute(const ExpenseRecordingScreen(), settings);
      case AppRouter.settings:
        return _buildRoute(const SettingsScreen(), settings);
      default:
        return _buildRoute(
          const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static void pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static void pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  static void pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}