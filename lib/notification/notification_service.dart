import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils.dart';
import '../../models/schedule_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones(); // 필수!
    tz.setLocalLocation(tz.getLocation("Asia/Seoul"));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() {
    return _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  /// 복약 스케쥴 알림 예약
  Future<void> scheduleNotification(
    ScheduleModel schedule,
    String diagnosis,
  ) async {
    // 알림 테스트용(즉시 알림 발생)
    // await _flutterLocalNotificationsPlugin.show(
    //   999,
    //   '테스트 알림',
    //   '지금 알림이 울리면 정상입니다!',
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'medication_channel',
    //       '복약 알림',
    //       channelDescription: '약 복용 시간 알림입니다.',
    //       importance: Importance.max,
    //       priority: Priority.high,
    //     ),
    //   ),
    // );

    // final localDateTime2 = DateTime.now().add(Duration(seconds: 10));
    // final zonedTime2 = tz.TZDateTime.from(localDateTime2, tz.local);

    // await _flutterLocalNotificationsPlugin.zonedSchedule(
    //   1001,
    //   '테스트 알림',
    //   '이 알림이 10초 뒤에 울리면 zonedSchedule 정상',
    //   zonedTime2,
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'medication_channel',
    //       '복약 알림',
    //       channelDescription: '약 복용 시간 알림입니다.',
    //       importance: Importance.max,
    //       priority: Priority.high,
    //     ),
    //   ),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    // );

    // 1. 문자열 기반으로 로컬 시간 생성
    // 1. 문자열 기반 시각 → 로컬 DateTime 생성
    final parts = schedule.time.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // 로컬 기준 시각
    final localDateTime = DateTime(
      schedule.date.year,
      schedule.date.month,
      schedule.date.day,
      hour,
      minute,
    );

    final now = DateTime.now().subtract(const Duration(minutes: 1));
    if (localDateTime.isBefore(now)) {
      print("⏭️ 과거 시간 알림 건너뜀: $localDateTime");
      return;
    }

    // 2. ID 계산
    final id = notificationIdFromSchedule(schedule);
    final zonedTime = tz.TZDateTime.from(localDateTime, tz.local);

    print("⏰ 알림 예약: ID=$id | 시간=$zonedTime (${zonedTime.timeZoneName})");

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '복약 알림',
      '$diagnosis 약 드실 시간이에요.(${schedule.time})',
      zonedTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          '복약 알림',
          channelDescription: '약 복용 시간 알림입니다.',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      payload:
          '$diagnosis|${schedule.prescriptionId}|${zonedTime.toIso8601String()}',
      matchDateTimeComponents: null, // 매일 반복 시 사용
    );
  }

  /// 알림 취소
  Future<void> cancelNotification(ScheduleModel schedule) async {
    final id = notificationIdFromSchedule(schedule);
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// 전체 알림 취소
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError(); // main.dart에서 override 해야 함
});
