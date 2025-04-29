class MoodModel {
  final String moodId;
  final String mood;
  final String story;
  final int createdAt;
  final String creatorUid;

  MoodModel({
    required this.moodId,
    required this.mood,
    required this.story,
    required this.createdAt,
    required this.creatorUid,
  });

  MoodModel.fromJson(Map<String, dynamic> json, String docId)
      : moodId = docId,
        mood = json["mood"] ?? "",
        story = json["story"] ?? "",
        createdAt = json["createdAt"] ?? 0,
        creatorUid = json["creatorUid"] ?? "";

  Map<String, dynamic> toJson() {
    return {
      "mood": mood,
      "story": story,
      "createdAt": createdAt,
      "creatorUid": creatorUid,
    };
  }
}
