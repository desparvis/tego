import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/screen_utils.dart';
import '../../core/constants/app_constants.dart';

class LayoutWrapper extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const LayoutWrapper({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.title,
    this.actions,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtils.init(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: showAppBar
            ? AppBar(
                title: title != null
                    ? Text(
                        title!,
                        style: TextStyle(
                          fontSize: ScreenUtils.sp(18),
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.fontFamily,
                        ),
                      )
                    : null,
                actions: actions,
                backgroundColor: AppConstants.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
              )
            : null,
        body: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: orientation == Orientation.portrait
                        ? ScreenUtils.screenHeight - ScreenUtils.statusBarHeight - ScreenUtils.bottomPadding
                        : ScreenUtils.screenHeight - ScreenUtils.statusBarHeight,
                  ),
                  child: IntrinsicHeight(
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}