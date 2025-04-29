import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoodRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> postMood(MoodModel data, String uid) async {
    final moodData = data.toJson();

    await _db.collection("moods").add(moodData);
  }

  Future<void> updateMood(String moodId, String mood, String story) async {
    await _db.collection("moods").doc(moodId).update({
      "mood": mood,
      "story": story,
      "updatedAt": DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteMood(String moodId) async {
    await _db.collection("moods").doc(moodId).delete();
  }

  Stream<List<MoodModel>> watchMoods(String userId) {
    return _db
        .collection("moods")
        .where("creatorUid", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<MoodModel> moods = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final creatorUid = data["creatorUid"] ?? "";
            String creator = "";

            if (creatorUid.isNotEmpty) {
              final userDoc =
                  await _db.collection("users").doc(creatorUid).get();
              final userData = userDoc.data();
              if (userDoc.exists &&
                  userData != null &&
                  userData.containsKey("name")) {
                creator = userData["name"] as String? ?? "anonymous";
              }
            }

            moods.add(
              MoodModel.fromJson({
                ...data,
                "moodId": doc.id,
                "creator": creator,
              }, doc.id),
            );
          }
          return moods;
        });
  }
}

final moodRepo = Provider((ref) => MoodRepository());
