import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/schedule_view_model.dart';
import '../utils.dart';
import '../notification/notification_service.dart';
import '../models/schedule_model.dart';
import '../models/prescription_model.dart';
import '../repos/authentication_repo.dart';
import '../repos/prescription_repo.dart';
import '../repos/schedule_repo.dart';

class PrescriptionViewModel extends AsyncNotifier<void> {
  late final PrescriptionRepository _repo;
  late final ScheduleRepository _scheduleRepo;

  @override
  Future<void> build() async {
    _repo = ref.read(prescriptionRepoProvider);
    _scheduleRepo = ref.read(scheduleRepositoryProvider);
  }

  Future<bool> checkExistPrescription(String originalPrescriptionId) async {
    return _repo.prescriptionExists(originalPrescriptionId);
  }

  Future<void> savePrescriptionAndSchedule(PrescriptionModel model) async {
    // 0. 알람 설정 유도 (미리 유도)
    final confirm = await confirmExactAlarmPermission();
    if (!confirm) {
      throw Exception("정확한 알람 권한이 없어 저장을 중단합니다.");
    }

    // 1. 처방 저장
    final id = await _repo.savePrescription(model);
    final updated = model.copyWith(prescriptionId: id);

    // 2. 복약스케쥴 생성 + 저장
    final schedules = _generateSchedules(updated);
    final insertedSchedules = await _scheduleRepo.bulkInsert(schedules);

    try {
      // 3. 알림 예약
      final notificationService = ref.read(notificationServiceProvider);
      for (final s in insertedSchedules) {
        await notificationService.scheduleNotification(s, updated.diagnosis);
        print("⏰ 알림 예약됨: ${s.date} ${s.time} for ${s.prescriptionId}");
      }
    } catch (e) {
      // 4. 중간 실패 시 처방 삭제 (보상)
      await _scheduleRepo.deleteByPrescription(updated.prescriptionId);
      await _repo.deletePrescription(updated.prescriptionId);
      rethrow; // 에러는 그대로 throw
    }
  }

  List<ScheduleModel> _generateSchedules(PrescriptionModel prescription) {
    final schedules = <ScheduleModel>[];
    for (
      DateTime date = prescription.startDate.toLocal();
      !date.isAfter(prescription.endDate.toLocal());
      date = date.add(const Duration(days: 1))
    ) {
      final localDate = DateTime(date.year, date.month, date.day); // 강제 local

      prescription.times.forEach((time, medicineIds) {
        schedules.add(
          ScheduleModel(
            scheduleId: '',
            prescriptionId: prescription.prescriptionId,
            uid: prescription.uid,
            date: localDate,
            time: time,
            medicineIds: medicineIds,
            isTaken: false,
            takenAt: null,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      });
    }
    return schedules;
  }

  Future<void> deletePrescriptionAndSchedules(String prescriptionId) async {
    state = const AsyncValue.loading(); // 🔄 로딩 시작

    state = await AsyncValue.guard(() async {
      // 1. 관련 스케쥴 조회
      final schedules = await _scheduleRepo.fetchByPrescriptionId(
        prescriptionId,
      );

      // 2. 알림 먼저 취소
      final notificationService = ref.read(notificationServiceProvider);
      for (final s in schedules) {
        await notificationService.cancelNotification(s);
      }

      // 3. 스케쥴 삭제
      await _scheduleRepo.deleteByPrescription(prescriptionId);

      // 4. 처방전 삭제
      await _repo.deletePrescription(prescriptionId);

      // 5. 복약스케쥴 reload
      await ref.read(scheduleViewModelProvider.notifier).reload();
    });
  }
}

final prescriptionProvider = AsyncNotifierProvider<PrescriptionViewModel, void>(
  PrescriptionViewModel.new,
);

final prescriptionStreamProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.read(prescriptionRepoProvider);
  final uid = ref.read(authRepo).user?.uid;
  if (uid == null) return const Stream.empty();
  return repo.watchPrescriptionsByUser(uid);
});
