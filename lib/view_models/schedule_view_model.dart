import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repos/authentication_repo.dart';
import '../models/schedule_model.dart';
import '../repos/schedule_repo.dart';

class ScheduleViewModel extends AsyncNotifier<List<ScheduleModel>> {
  late final ScheduleRepository _repo;

  @override
  Future<List<ScheduleModel>> build() async {
    // 최초 build 시 로드할 내용 없으면 빈 리스트 반환
    _repo = ref.read(scheduleRepositoryProvider);
    return [];
  }

  /// 외부에서 직접 호출: 특정 날짜 스케쥴 로드
  Future<void> loadSchedules(String uid, DateTime date) async {
    print("🔵 [복약앱] 스케쥴 불러오기 시작 - $uid / $date");

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _repo.getSchedulesByDate(uid: uid, date: date);
      print("🟢 불러온 스케쥴 ${result.length}건");
      for (final s in result) {
        print("⏰ ${s.time} / ${s.medicineIds.join(', ')} / ${s.isTaken}");
      }
      return result;
    });
  }

  /// 복약 완료 처리
  Future<void> markAsTaken({
    required String scheduleId,
    required bool isTaken,
    required DateTime? takenAt,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // 서버 반영
    await _repo.markAsTaken(
      scheduleId: scheduleId,
      isTaken: isTaken,
      takenAt: takenAt,
    );

    // 로컬 상태 반영
    state = AsyncValue.data([
      for (final s in current)
        if (s.scheduleId == scheduleId)
          s.copyWith(isTaken: isTaken, takenAt: takenAt?.millisecondsSinceEpoch)
        else
          s,
    ]);
  }
}

final scheduleViewModelProvider =
    AsyncNotifierProvider<ScheduleViewModel, List<ScheduleModel>>(
      ScheduleViewModel.new,
    );

final scheduleStreamProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.read(scheduleRepositoryProvider);
  final uid = ref.read(authRepo).user?.uid;
  if (uid == null) return const Stream.empty();
  return repo.watchSchedules(uid);
});
