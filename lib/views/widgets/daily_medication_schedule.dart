import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../views/widgets/survey_dialog.dart';
import '../../view_models/user_view_model.dart';
import '../../constants/gaps.dart';
import '../../models/schedule_model.dart';
import '../../utils.dart';
import '../../view_models/prescription_view_model.dart';
import '../../view_models/schedule_view_model.dart';

class DailyMedicationSchedule extends ConsumerWidget {
  final DateTime date;
  const DailyMedicationSchedule({super.key, required this.date});

  // 복약시간 도래 여부 확인
  bool isEligibleForTaken({
    required DateTime scheduledDate,
    required String scheduledTimeStr,
  }) {
    final now = DateTime.now();

    final parts = scheduledTimeStr.split(":");
    final scheduled = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    return now.isAfter(scheduled);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleViewModelProvider);
    final prescriptionState = ref.watch(prescriptionStreamProvider);

    if (scheduleState.isLoading || prescriptionState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final schedules = scheduleState.asData?.value ?? [];
    final prescriptions = prescriptionState.asData?.value ?? [];

    if (schedules.isEmpty) {
      return const Center(child: Text("오늘 복약 예정이 없습니다."));
    }

    final Map<String, String> idToDiagnosis = {
      for (final p in prescriptions) p.prescriptionId: p.diagnosis,
    };

    final sorted = [...schedules]..sort((a, b) => a.time.compareTo(b.time));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children:
            sorted.map((sched) {
              final diagnosis = idToDiagnosis[sched.prescriptionId] ?? '정보 없음';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _PillScheduleItem(
                  schedule: sched,
                  diagnosis: diagnosis ?? '정보 없음',
                  onToggle: () async {
                    final newTaken = !sched.isTaken;
                    DateTime? takenAt;

                    if (newTaken) {
                      // 1. 복약시 복약시간 도래 여부 체크
                      final isAllowed = isEligibleForTaken(
                        scheduledDate: sched.date,
                        scheduledTimeStr: sched.time,
                      );

                      if (!isAllowed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("아직 복약 시간이 되지 않았습니다."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return; // ❗조기 종료
                      }

                      final parts = sched.time.split(":");
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(parts[0]),
                          minute: int.parse(parts[1]),
                        ),
                      );

                      if (picked == null) return; // 사용자가 취소한 경우

                      takenAt = DateTime(
                        sched.date.year,
                        sched.date.month,
                        sched.date.day,
                        picked.hour,
                        picked.minute,
                      );
                    }

                    // 복약기록 입력
                    await ref
                        .read(scheduleViewModelProvider.notifier)
                        .markAsTaken(
                          scheduleId: sched.scheduleId,
                          isTaken: newTaken,
                          takenAt: takenAt,
                        );

                    // 포인트 적립 / 차감 처리
                    await ref
                        .read(usersProvider.notifier)
                        .updatePoint(newTaken ? 10 : -10);

                    // ✅ 설문조사 팝업 위치 (복약 완료한 경우에만)
                    if (newTaken) {
                      await showSurveyDialog(context);
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    final message =
                        newTaken ? "포인트 10점이 적립되었습니다." : "포인트 10점이 차감되었습니다.";
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _PillScheduleItem extends StatelessWidget {
  final ScheduleModel schedule;
  final String diagnosis;
  final VoidCallback onToggle;

  const _PillScheduleItem({
    required this.schedule,
    required this.diagnosis,
    required this.onToggle,
  });

  Color getTakenColor({
    required DateTime scheduledDate, // yyyy-MM-dd
    required String scheduledTimeStr, // "HH:mm"
    required int? takenAtMillis,
  }) {
    final now = DateTime.now();

    // 예정 시간: 날짜 + 시간 조합
    final parts = scheduledTimeStr.split(":");
    final scheduled = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // ⏳ 복약 안함
    if (takenAtMillis == null) {
      final diff = now.difference(scheduled).inMinutes;

      if (diff < 0) {
        return Colors.black; // 아직 복약 전
      } else if (diff <= 30) {
        return Colors.black; // 허용 범위 내
      } else {
        return Colors.red; // 복약 시간이 지났고 아직 안 먹음
      }
    }

    // ✅ 복약 완료
    final taken = DateTime.fromMillisecondsSinceEpoch(takenAtMillis);
    final diffMinutes = taken.difference(scheduled).inMinutes.abs();

    if (diffMinutes <= 30) return Colors.green;
    if (diffMinutes <= 60) return Colors.orange;
    return Colors.red;
  }

  String? getTakenEmoji(String scheduledTimeStr, int? takenAtMillis) {
    final now = DateTime.now();

    // 예정 시간 파싱 ("HH:mm" → DateTime)
    final parts = scheduledTimeStr.split(":");
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // 아직 복약 전
    if (takenAtMillis == null) {
      final diff = now.difference(scheduled).inMinutes;
      if (diff < 0) return null; // ✅ 이미지 유지 (기본 상태)
      if (diff <= 30) return null; // 아직은 기다리는 중 (기본 상태)
      return "😡"; // 복약 놓침
    }

    // 복약 완료 → 시간 차이로 이모지 결정
    final taken = DateTime.fromMillisecondsSinceEpoch(takenAtMillis);
    final diffMinutes = taken.difference(scheduled).inMinutes.abs();

    if (diffMinutes <= 30) return "😊";
    if (diffMinutes <= 60) return "😐";
    return "😞";
  }

  @override
  Widget build(BuildContext context) {
    final isTaken = schedule.isTaken;
    final scheduledTime = schedule.time;
    final takenAt = schedule.takenAt;
    final takenTimeStr =
        takenAt != null
            ? DateFormat(
              'HH:mm',
            ).format(DateTime.fromMillisecondsSinceEpoch(takenAt))
            : "미복약";

    final pillColor = getTakenColor(
      scheduledDate: schedule.date,
      scheduledTimeStr: schedule.time,
      takenAtMillis: schedule.takenAt,
    );
    // final pillEmoji = getTakenEmoji(schedule.time, schedule.takenAt);

    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTaken ? pillColor : Colors.white,
              border: Border.all(color: Colors.grey, width: 2),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              appIcon,
              width: 64,
              height: 64,
              color: isTaken ? pillColor : null,
              colorBlendMode: BlendMode.modulate,
            ),
          ),
        ),
        Gaps.v8,
        Text(
          '$scheduledTime / $takenTimeStr',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: pillColor),
        ),
        Text(
          diagnosis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
