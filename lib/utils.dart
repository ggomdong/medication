import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication/models/schedule_model.dart';
import '../view_models/settings_view_model.dart';

bool isDarkMode(WidgetRef ref) => ref.watch(settingsProvider).darkMode;

List<String> moodEmojiList = ["😀", "😍", "🥳", "😱", "😭", "🤯", "😡"];

const String logo = 'assets/images/logo.png';
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
