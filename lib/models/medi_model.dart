class MediModel {
  final String mId;
  final String medicine_id;
  final String name;
  final String type;
  final String times_per_day;
  final String timing;
  final int createdAt;
  final String creatorUid;

  MediModel({
    required this.mId,
    required this.medicine_id,
    required this.name,
    required this.type,
    required this.times_per_day,
    required this.timing,
    required this.createdAt,
    required this.creatorUid,
  });

  MediModel.fromJson(Map<String, dynamic> json, String docId)
    : mId = docId,
      medicine_id = json["medicine_id"] ?? "",
      name = json["name"] ?? "",
      type = json["type"] ?? "",
      times_per_day = json["times_per_day"] ?? "",
      timing = json["timing"] ?? "",
      createdAt = json["createdAt"] ?? 0,
      creatorUid = json["creatorUid"] ?? "";

  Map<String, dynamic> toJson() {
    return {
      "medicine_id": medicine_id,
      "name": name,
      "type": type,
      "times_per_day": times_per_day,
      "timing": timing,
      "createdAt": createdAt,
      "creatorUid": creatorUid,
    };
  }
}
