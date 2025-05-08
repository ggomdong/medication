import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication/router.dart';
import '../models/schedule_model.dart';
import '../view_models/settings_view_model.dart';

bool isDarkMode(WidgetRef ref) => ref.watch(settingsProvider).darkMode;

List<String> moodEmojiList = ["😀", "😍", "🥳", "😱", "😭", "🤯", "😡"];

const String logo = 'assets/images/logo.png';
const String logoDarkmode = 'assets/images/logo_darkmode.png';
const String appIcon = 'assets/images/app_icon.png';

void showFirebaseErrorSnack(BuildContext context, Object? error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      content: Text(
        (error as FirebaseException).message ?? "Something went wrong.",
      ),
    ),
  );
}

int notificationIdFromSchedule(ScheduleModel s) {
  return (s.scheduleId + s.time).codeUnits.fold(0, (a, b) => a + b);
}

DateTime getStartOfWeek(DateTime date) {
  final weekday = date.weekday % 7; // 0 = 일요일
  return date.subtract(Duration(days: weekday));
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Android의 "정확한 알람(SCHEDULE_EXACT_ALARM)" 권한 설정 화면으로 이동
void openExactAlarmSettings() {
  if (Platform.isAndroid) {
    const intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }
}

Future<bool> confirmExactAlarmPermission() async {
  return await showDialog<bool>(
        context: navigatorKey.currentContext!,
        builder:
            (context) => AlertDialog(
              title: const Text("알람 권한 확인 필요"),
              content: const Text(
                "복약 알림을 예약하려면, 권한이 필요합니다.\n설정에서 알람 권한이 있는지 확인해주세요.",
              ),
              actions: [
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("취소"),
                    ),
                    TextButton(
                      onPressed: () {
                        openExactAlarmSettings();
                        Navigator.pop(context, false); // 설정 후 다시 시도하도록
                      },
                      child: const Text(
                        "설정으로 이동",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "계속 진행",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ) ??
      false;
}
