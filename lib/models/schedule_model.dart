import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String scheduleId; // Firestore 문서 ID
  final String prescriptionId;
  final String uid; // 사용자 Firebase UID
  final DateTime date; // 복약 날짜 (yyyy-MM-dd 기준)
  final String time; // 복약 시간 문자열 ("09:00")
  final List<String> medicineIds; // 복약할 약 ID 목록
  final bool isTaken; // 복약 완료 여부
  final int? takenAt; // 복약 완료 시간 (선택, ms 단위)
  final int createdAt; // 생성 시점 (millisecondsSinceEpoch)

  ScheduleModel({
    required this.scheduleId,
    required this.prescriptionId,
    required this.uid,
    required this.date,
    required this.time,
    required this.medicineIds,
    this.isTaken = false,
    this.takenAt,
    required this.createdAt,
  });

  ScheduleModel.fromJson(Map<String, dynamic> json, {String? docId})
    : scheduleId = docId ?? json['schedule_id'],
      prescriptionId = json['prescription_id'],
      uid = json['uid'],
      date = (json['date'] as Timestamp).toDate(), // Firestore 저장 방식 고려
      time = json['time'],
      medicineIds = List<String>.from(json['medicine_ids']),
      isTaken = json['is_taken'] ?? false,
      takenAt = json['taken_at'],
      createdAt = json['created_at'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'time': time,
      'medicine_ids': medicineIds,
      'is_taken': isTaken,
      'taken_at': takenAt,
      'created_at': createdAt,
    };
  }

  ScheduleModel copyWith({
    String? scheduleId,
    String? prescriptionId,
    String? uid,
    DateTime? date,
    String? time,
    List<String>? medicineIds,
    bool? isTaken,
    int? takenAt,
    int? createdAt,
  }) {
    return ScheduleModel(
      scheduleId: scheduleId ?? this.scheduleId,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      uid: uid ?? this.uid,
      date: date ?? this.date,
      time: time ?? this.time,
      medicineIds: medicineIds ?? this.medicineIds,
      isTaken: isTaken ?? this.isTaken,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
