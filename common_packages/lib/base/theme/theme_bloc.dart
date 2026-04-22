import 'package:bloc/bloc.dart';
import 'package:common_packages/base/theme/theme_event.dart';
import 'package:common_packages/util/app_preferences.dart';
import 'package:flutter/material.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc() : super(ThemeMode.light) {
    on<InitialTheme>((event, emit) async {
      final isDark = await AppPreferences.isDarkMode();
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    });

    on<ChangeTheme>((event, emit) async {
      final isDark = await AppPreferences.isDarkMode();
      final newIsDark = !isDark;
      await AppPreferences.setDarkMode(newIsDark);
      emit(newIsDark ? ThemeMode.dark : ThemeMode.light);
    });
  }
}
