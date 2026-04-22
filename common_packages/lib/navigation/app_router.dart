import 'package:go_router/go_router.dart';

import '../presentation/home_screen.dart';
import '../presentation/pages/setting/setting_screen.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() => _instance;
  AppRouter._internal();


  final  GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/setting',
        name: 'setting',
        builder: (context, state) => const SettingScreen(),
      ),
    ]

  );

}