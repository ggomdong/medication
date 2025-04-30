import 'package:medication/models/prescription_model.dart';
import 'package:medication/views/prescription_screen.dart';
import 'package:medication/views/splash_screen.dart';

import '../repos/authentication_repo.dart';
import '../views/login_screen.dart';
import 'views/main_navigation_screen.dart';
import '../views/sign_up_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteURL {
  static const splash = "/splash";
  static const login = "/login";
  static const signup = "/signup";
  static const home = "/home";
  static const prescription = "/prescription";
}

class RouteName {
  static const splash = "splash";
  static const login = "login";
  static const signup = "signup";
  static const home = "home";
  static const prescription = "prescription";
}

final routerProvider = Provider((ref) {
  return GoRouter(
    initialLocation: "/splash",
    // redirect: (context, state) {
    //   final isLoggedIn = ref.read(authRepo).isLoggedIn;
    //   if (!isLoggedIn) {
    //     if (state.matchedLocation != SignUpScreen.routeUrl &&
    //         state.matchedLocation != LoginScreen.routeUrl) {
    //       return LoginScreen.routeUrl;
    //     }
    //   }
    //   return null;
    // },
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
        path: "/:tab(home|post|calendar|shop|mypage)",
        builder: (context, state) {
          final tab = state.pathParameters["tab"] ?? "";
          return MainNavigationScreen(tab: tab);
        },
      ),
      GoRoute(
        name: RouteName.prescription,
        path: RouteURL.prescription,
        builder: (context, state) {
          final prescription = state.extra as PrescriptionModel?;
          return PrescriptionScreen(prescription: prescription);
        },
      ),
    ],
  );
});
