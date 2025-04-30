import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_model.dart';
import '../repos/authentication_repo.dart';
import '../repos/mood_repo.dart';

class MoodViewModel extends AsyncNotifier<void> {
  late final MoodRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.read(moodRepo);
  }

  Future<void> postMood(String mood, String story, BuildContext context) async {
    final user = ref.read(authRepo).user;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.postMood(
        MoodModel(
          moodId: "",
          mood: mood,
          story: story,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          creatorUid: user!.uid,
        ),
        user.uid,
      );
    });
  }

  Future<void> updateMood(String moodId, String mood, String story) async {
    await _repository.updateMood(moodId, mood, story);
  }

  Future<void> deleteMood(String moodId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteMood(moodId);
    });
  }
}

final moodProvider = AsyncNotifierProvider<MoodViewModel, void>(
  () => MoodViewModel(),
);

final moodStreamProvider = StreamProvider<List<MoodModel>>((ref) {
  final user = ref.read(authRepo).user;
  if (user == null) return const Stream.empty();
  return ref.read(moodRepo).watchMoods(user.uid);
});
