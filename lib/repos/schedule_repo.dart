import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'schedules';

  /// 단일 스케쥴 저장
  Future<void> save(ScheduleModel schedule) async {
    final docRef = _db.collection(_collection).doc(schedule.scheduleId);
    await docRef.set(schedule.toJson());
  }

  /// 스케쥴 다건 생성 (처방 등록 시 사용)
  Future<List<ScheduleModel>> bulkInsert(List<ScheduleModel> schedules) async {
    final batch = _db.batch();
    // scheduleId 별로 알림을 등록하기 위한 return 값용 변수
    final insertedSchedules = <ScheduleModel>[];

    for (final schedule in schedules) {
      final docRef = _db.collection(_collection).doc();
      final scheduleWithId = schedule.copyWith(scheduleId: docRef.id);
      batch.set(docRef, scheduleWithId.toJson());
      insertedSchedules.add(scheduleWithId);
    }
    await batch.commit();
    return insertedSchedules;
  }

  /// 사용자 ID + 날짜로 복약 스케쥴 조회
  Future<List<ScheduleModel>> getSchedulesByDate({
    required String uid,
    required DateTime date,
  }) async {
    final String targetDate = _dateOnlyString(date);
    print("🔍 Firestore 쿼리 준비: uid=$uid, date=$targetDate");

    try {
      final snapshot =
          await _db
              .collection(_collection)
              .where('uid', isEqualTo: uid)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime.parse(targetDate),
                ),
              )
              .where(
                'date',
                isLessThan: Timestamp.fromDate(
                  DateTime.parse(targetDate).add(Duration(days: 1)),
                ),
              )
              .orderBy('date')
              .orderBy('time')
              .get();

      print("📦 Firestore 결과: ${snapshot.docs.length}건");

      return snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      print("❌ Firestore 쿼리 에러: $e");
      rethrow;
    }
  }

  /// 복약 완료 처리
  Future<void> markAsTaken({
    required String scheduleId,
    required bool isTaken,
    required DateTime? takenAt,
  }) async {
    await _db.collection(_collection).doc(scheduleId).update({
      'is_taken': isTaken,
      'taken_at':
          isTaken && takenAt != null ? takenAt.millisecondsSinceEpoch : null,
    });
  }

  /// 처방전 ID로 전체 스케쥴 삭제 (처방 수정/삭제 시 사용)
  Future<void> deleteByPrescription(String prescriptionId) async {
    final snapshot =
        await _db
            .collection(_collection)
            .where('prescription_id', isEqualTo: prescriptionId)
            .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<List<ScheduleModel>> fetchByPrescriptionId(
    String prescriptionId,
  ) async {
    final snapshot =
        await _db
            .collection(_collection)
            .where('prescription_id', isEqualTo: prescriptionId)
            .get();

    return snapshot.docs
        .map((doc) => ScheduleModel.fromJson(doc.data(), docId: doc.id))
        .toList();
  }

  /// 내부 날짜 포맷 도우미 (yyyy-MM-dd)
  String _dateOnlyString(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.toIso8601String().split('T').first;
  }

  Stream<List<ScheduleModel>> watchSchedules(String uid) {
    return _db
        .collection(_collection)
        .where("uid", isEqualTo: uid)
        .orderBy("date", descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => ScheduleModel.fromJson(doc.data(), docId: doc.id),
                  )
                  .toList(),
        );
  }
}

final scheduleRepo = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});
