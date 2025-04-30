class MediModel {
  final String medicineId;
  final String name;
  final String type;
  final String link;

  MediModel({
    required this.medicineId,
    required this.name,
    required this.type,
    required this.link,
  });

  MediModel.fromJson(Map<String, dynamic> json, String docId)
    : medicineId = json["medicineId"] ?? "",
      name = json["name"] ?? "",
      type = json["type"] ?? "",
      link = json["link"] ?? "";

  Map<String, dynamic> toJson() {
    return {"medicineId": medicineId, "name": name, "type": type, "link": link};
  }
}
