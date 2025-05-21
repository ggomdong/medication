import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../views/point_stats_screen.dart';
import '../views/chat_detail_screen.dart';
import '../views/health_info_write_screen.dart';
import '../models/prescription_model.dart';
import '../views/prescription_screen.dart';
import '../views/splash_screen.dart';
import '../views/login_screen.dart';
import '../views/main_navigation_screen.dart';
import '../views/sign_up_screen.dart';

class RouteURL {
  static const splash = "/splash";
  static const login = "/login";
  static const signup = "/signup";
  static const home = "/home";
  static const qr = "/qr";
  static const prescription = "/prescription";
  static const healthInfo = "/health-info";
  static const chat = "/chat";
  static const pointStats = "/point-stats";
  static const healthStats = "/health-stats";
}

class RouteName {
  static const splash = "splash";
  static const login = "login";
  static const signup = "signup";
  static const home = "home";
  static const qr = "qr";
  static const prescription = "prescription";
  static const healthInfo = "health-info";
  static const chat = "chat";
  static const pointStats = "pointStats";
  static const healthStats = "healthStats";
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider((ref) {
  return GoRouter(
    initialLocation: "/splash",
    navigatorKey: navigatorKey,

    routes: [
      GoRoute(
        name: RouteName.splash,
        path: RouteURL.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: RouteName.signup,
        path: RouteURL.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        name: RouteName.login,
        path: RouteURL.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: "/:tab(home|qr|calendar|shop|profile)",
        builder: (context, state) {
          final tab = state.pathParameters["tab"] ?? "";
          return MainNavigationScreen(tab: tab);
        },
      ),
      GoRoute(
        name: RouteName.prescription,
        path: RouteURL.prescription,
        builder: (context, state) {
          final prescription = state.extra as PrescriptionModel;
          return PrescriptionScreen(prescription: prescription);
        },
      ),
      GoRoute(
        name: RouteName.healthInfo,
        path: RouteURL.healthInfo,
        builder: (context, state) => const HealthInfoWriteScreen(),
      ),
      GoRoute(
        name: RouteName.chat,
        path: RouteURL.chat,
        builder: (context, state) => const ChatDetailScreen(),
      ),
      GoRoute(
        name: RouteName.pointStats,
        path: RouteURL.pointStats,
        builder: (context, state) => const PointStatsScreen(),
      ),
    ],
  );
});
