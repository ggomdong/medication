import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../repos/authentication_repo.dart';
import '../repos/user_repo.dart';

class UsersViewModel extends AsyncNotifier<UserProfileModel> {
  late final UserRepository _userRepository;
  late final AuthenticationRepository _authenticationRepository;

  @override
  FutureOr<UserProfileModel> build() async {
    _userRepository = ref.read(userRepo);
    _authenticationRepository = ref.read(authRepo);

    if (_authenticationRepository.isLoggedIn) {
      final profile = await _userRepository.findProfile(
        _authenticationRepository.user!.uid,
      );
      if (profile != null) {
        return UserProfileModel.fromJson(profile);
      }
    }

    return UserProfileModel.empty();
  }

  // 신규 profile 생성
  Future<void> createProfile(UserCredential credential) async {
    if (credential.user == null) {
      throw Exception("Account not created");
    }
    state = const AsyncValue.loading();
    final profile = UserProfileModel(
      uid: credential.user!.uid,
      email: credential.user!.email ?? "anon@anon.com",
      name: credential.user!.displayName ?? "Anon",
      bio: "undefined",
      link: "undefined",
      hasAvatar: false,
      followers: [],
      followerCount: 0,
      point: 0,
    );
    await _userRepository.createProfile(profile);
    state = AsyncValue.data(profile);
  }

  Future<void> updatePoint(int delta) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newPoint = (current.point + delta).clamp(0, 999999); // 음수 방지

    await _userRepository.updatePoint(current.uid, newPoint);

    state = AsyncValue.data(current.copyWith(point: newPoint));
  }

  Future<void> updateHealthInfo({
    required int? height,
    required int? weight,
    required int? age,
    required String? bloodPressure,
    required List<String>? mealTimes,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = const AsyncValue.loading();

    await _userRepository.updateHealthInfo(
      current.uid,
      height: height,
      weight: weight,
      age: age,
      bloodPressure: bloodPressure,
      mealTimes: mealTimes,
    );

    state = AsyncValue.data(
      current.copyWith(
        height: height,
        weight: weight,
        age: age,
        bloodPressure: bloodPressure,
        mealTimes: mealTimes,
      ),
    );
  }
}

final usersProvider = AsyncNotifierProvider<UsersViewModel, UserProfileModel>(
  () => UsersViewModel(),
);
