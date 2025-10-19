import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soely/core/constant/app_strings.dart';
import 'package:soely/core/services/language_service.dart';

mixin LanguageProviderMixin<T extends StatefulWidget> on State<T> {
  LanguageService get languageService => context.watch<LanguageService>();
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync AppStrings whenever language changes
    AppStrings.setLanguage(languageService.currentLanguage);
  }
}