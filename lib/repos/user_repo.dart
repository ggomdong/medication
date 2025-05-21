import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _collection = 'users';

  Future<void> createProfile(UserProfileModel profile) async {
    await _db.collection(_collection).doc(profile.uid).set(profile.toJson());
  }

  Future<Map<String, dynamic>?> findProfile(String uid) async {
    final doc = await _db.collection(_collection).doc(uid).get();
    return doc.data();
  }

  Future<void> updatePoint(String uid, int newPoint) async {
    await _db.collection(_collection).doc(uid).update({"point": newPoint});
  }

  Future<void> updateHealthInfo(
    String uid, {
    int? height,
    int? weight,
    int? age,
    String? bloodPressure,
    List<String>? mealTimes,
  }) async {
    final doc = _db.collection(_collection).doc(uid);
    await doc.update({
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (age != null) 'age': age,
      if (bloodPressure != null) 'bloodPressure': bloodPressure,
      if (mealTimes != null) 'mealTimes': mealTimes,
    });
  }
}

final userRepo = Provider((ref) => UserRepository());
