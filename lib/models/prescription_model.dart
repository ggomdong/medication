class PrescriptionModel {
  final String prescriptionId;
  final List<String> medicineIds; // MediModel의 ID 목록
  final DateTime startDate; // 복약 기간 시작
  final DateTime endDate; // 복약 기간 종료
  final List<String> times; // 복약 시간 (예: ["09:00", "13:00"])
  final String timingDescription;

  PrescriptionModel({
    required this.prescriptionId,
    required this.medicineIds,
    required this.startDate,
    required this.endDate,
    required this.times,
    required this.timingDescription,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      prescriptionId: json['prescription_id'],
      medicineIds: List<String>.from(json['medicine_ids']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      times: List<String>.from(json['times']),
      timingDescription: json['timing_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'medicine_ids': medicineIds,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'times': times,
      'timing_description': timingDescription,
    };
  }
}
