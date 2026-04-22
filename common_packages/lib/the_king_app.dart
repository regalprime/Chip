import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/base/languages/bloc/app_language_bloc.dart';
import 'package:common_packages/base/languages/l10n/gen/app_localizations.dart';
import 'package:common_packages/base/theme/theme_bloc.dart';
import 'package:common_packages/base/theme/theme_event.dart';
import 'package:common_packages/constants/app_theme.dart';
import 'package:common_packages/presentation/blocs/auth/auth_bloc.dart';
import 'package:common_packages/presentation/blocs/counter_day/day_counter_bloc.dart';
import 'package:common_packages/presentation/blocs/delete_data/delete_data_bloc.dart';
import 'package:common_packages/presentation/home_screen.dart';
import 'package:common_packages/presentation/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class TheKingApp extends StatelessWidget {
  const TheKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()..add(InitialTheme())),
            BlocProvider<AppLanguageBloc>(create: (context) => AppLanguageBloc()..add(const LoadAppLanguage())),
            BlocProvider<DeleteDataBloc>(create: (context) => DeleteDataBloc()),
            BlocProvider<AuthBloc>(create: (context) => GetIt.instance<AuthBloc>()..add(AppStarted())),
            BlocProvider<DayCounterBloc>(create: (_) => GetIt.instance<DayCounterBloc>()),
          ],
          child: const TheKing(),
        );
      },
    );
  }
}

class TheKing extends StatelessWidget {
  const TheKing({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<AppLanguageBloc, AppLanguageState>(
          builder: (context, languageState) {
            return MaterialApp(
              title: 'My Chip',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              locale: languageState.selectedLanguage.value,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
              home: const RootScreen(),
            );
          },
        );
      },
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  Widget _buildLoadingScreen() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          DSErrorDialog.show(context, message: state.error);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthAuthenticated() => const HomeScreen(),
            AuthUnauthenticated() => const SignInScreen(),
            AuthFailureState() => const SignInScreen(),
            _ => _buildLoadingScreen(),
          };
        },
      ),
    );
  }
}
