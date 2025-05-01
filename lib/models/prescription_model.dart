import '../models/medi_model.dart';

class PrescriptionModel {
  final String prescriptionId;
  final String diagnosis; // 병명
  final List<MediModel> medicines; // 약 리스트
  final DateTime startDate; // 복약 기간 시작
  final DateTime endDate; // 복약 기간 종료
  final String timingDescription; // 복약타이밍
  final List<String> times; // 복약 시간 (예: ["09:00", "13:00"])
  final String uid; // 사용자의 Firebase UID
  final int createdAt; // 입력 시점 (timestamp: millisecondsSinceEpoch)

  PrescriptionModel({
    required this.prescriptionId,
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
      diagnosis = json['diagnosis'],
      medicines =
          (json['medicines'] as List)
              .map((e) => MediModel.fromJson(e))
              .toList(),
      startDate = DateTime.parse(json['startDate']),
      endDate = DateTime.parse(json['endDate']),
      times = List<String>.from(json['times']),
      timingDescription = json['timing_description'],
      uid = json['uid'] ?? '', // fallback for QR에서 누락된 경우
      createdAt = json['createdAt'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
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
    String? diagnosis,
    List<MediModel>? medicines,
    DateTime? startDate,
    DateTime? endDate,
    String? timingDescription,
    List<String>? times,
    String? uid,
    int? createdAt,
  }) {
    return PrescriptionModel(
      prescriptionId: prescriptionId ?? this.prescriptionId,
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
