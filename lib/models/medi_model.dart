class MediModel {
  final String medicineId;
  final String name; // 제품명
  final String ingredient; // 주성분명
  final String type; // 분류
  final String link; // 의약품 정보 링크

  MediModel({
    required this.medicineId,
    required this.name,
    required this.ingredient,
    required this.type,
    required this.link,
  });

  MediModel.fromJson(Map<String, dynamic> json)
    : medicineId = json["medicine_id"] ?? "",
      name = json["name"] ?? "",
      ingredient = json["ingredient"] ?? "",
      type = json["type"] ?? "",
      link = json["link"] ?? "";

  Map<String, dynamic> toJson() {
    return {
      "medicine_id": medicineId,
      "name": name,
      "ingredient": ingredient,
      "type": type,
      "link": link,
    };
  }
}
