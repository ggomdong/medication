import '../notification/notification_permission.dart';
import '../notification/notification_service.dart';
import '../repos/settings_repo.dart';
import '../view_models/settings_view_model.dart';
import '../constants/sizes.dart';
import '../firebase_options.dart';
import '../router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final preferences = await SharedPreferences.getInstance();
  final repository = SettingsRepository(preferences);

  final notificationService = NotificationService();
  await notificationService.initialize();

  // 알림 권한 확인 및 설정 유도
  final granted = await requestNotificationPermission();

  runApp(
    ProviderScope(
      overrides: [
        settingsProvider.overrideWith(() => SettingsViewModel(repository)),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(settingsProvider).darkMode;
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      title: 'Medication',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFE0F0FD),
        primaryColor: const Color(0xFF8CBCE6),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Color(0xFF1A1A1A),
          displayColor: Color(0xFF1A1A1A),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF5098E9),
        ),
        splashColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.black,
          backgroundColor: Color(0xFFE0F0FD),
          surfaceTintColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: Sizes.size18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        textTheme: Typography.whiteMountainView,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF2C2C2C),
        primaryColor: const Color(0xFF8CBCE6),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF5098E9),
        ),
        appBarTheme: AppBarTheme(
          surfaceTintColor: Colors.grey.shade900,
          backgroundColor: Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: Sizes.size16 + Sizes.size2,
            fontWeight: FontWeight.w600,
          ),
          actionsIconTheme: IconThemeData(color: Colors.grey.shade100),
          iconTheme: IconThemeData(color: Colors.grey.shade100),
        ),
      ),
    );
  }
}
