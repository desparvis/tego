import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'preferences_service.dart';

class AppLocalizationsHelper {
  static AppLocalizations of(BuildContext context) {
    final savedLanguage = PreferencesService.getLanguage();
    
    if (savedLanguage == 'rw') {
      return lookupAppLocalizations(const Locale('rw'));
    }
    
    return AppLocalizations.of(context)!;
  }
}