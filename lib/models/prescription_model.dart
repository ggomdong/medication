import '../models/medi_model.dart';

class PrescriptionModel {
  final String prescriptionId;
  final String originalPrescriptionId; // QR에서 받은 일련번호, 처방전 중복 등록 방지를 위해 필요
  final String diagnosis; // 병명
  final List<MediModel> medicines; // 약 리스트
  final DateTime startDate; // 복약 기간 시작
  final DateTime endDate; // 복약 기간 종료
  final String timingDescription; // 복약타이밍
  final Map<String, List<String>> times; // 복약 시간 (예: ["09:00", "13:00"])
  final String uid; // 사용자의 Firebase UID
  final int createdAt; // 입력 시점 (timestamp: millisecondsSinceEpoch)

  PrescriptionModel({
    required this.prescriptionId,
    required this.originalPrescriptionId,
    required this.diagnosis,
    required this.medicines,
    required this.startDate,
    required this.endDate,
    required this.timingDescription,
    required this.times,
    required this.uid,
    required this.createdAt,
  });

  PrescriptionModel.fromJson(Map<String, dynamic> json, {String? docId})
    : prescriptionId = docId ?? json['prescription_id'],
      originalPrescriptionId = json['prescription_id'],
      diagnosis = json['diagnosis'],
      medicines =
          (json['medicines'] as List)
              .map((e) => MediModel.fromJson(e))
              .toList(),
      startDate = DateTime.parse(json['startDate']),
      endDate = DateTime.parse(json['endDate']),
      times =
          (json['times'] as Map<String, dynamic>?)?.map((key, value) {
            if (value is List) {
              return MapEntry(key, List<String>.from(value));
            } else {
              return MapEntry(key, []);
            }
          }) ??
          {},
      timingDescription = json['timing_description'],
      uid = json['uid'] ?? '', // fallback for QR에서 누락된 경우
      createdAt = json['createdAt'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'original_prescription_id': originalPrescriptionId,
      'diagnosis': diagnosis,
      'medicines': medicines.map((e) => e.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'times': times,
      'timing_description': timingDescription,
      'uid': uid,
      'createdAt': createdAt,
    };
  }

  PrescriptionModel copyWith({
    String? prescriptionId,
    String? originalPrescriptionId,
    String? diagnosis,
    List<MediModel>? medicines,
    DateTime? startDate,
    DateTime? endDate,
    String? timingDescription,
    Map<String, List<String>>? times,
    String? uid,
    int? createdAt,
  }) {
    return PrescriptionModel(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      originalPrescriptionId:
          originalPrescriptionId ?? this.originalPrescriptionId,
      diagnosis: diagnosis ?? this.diagnosis,
      medicines: medicines ?? this.medicines,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timingDescription: timingDescription ?? this.timingDescription,
      times: times ?? this.times,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
