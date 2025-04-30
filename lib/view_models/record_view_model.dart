import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medi_model.dart';
import '../repos/record_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

final recordViewModelProvider = StateNotifierProvider<RecordViewModel, void>(
  (ref) => RecordViewModel(),
);

class RecordViewModel extends StateNotifier<void> {
  // final Reader _read;

  RecordViewModel() : super(null);

  Future<void> saveRecord(MediModel model, String mealTime) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final newModel = MediModel(
      medicineId: model.medicineId,
      name: model.name,
      type: model.type,
      link: model.link,
    );

    // await _read(recordRepositoryProvider).saveRecord(newModel);
  }
}
