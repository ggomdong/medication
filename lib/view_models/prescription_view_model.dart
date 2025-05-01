import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication/models/prescription_model.dart';
import 'package:medication/repos/authentication_repo.dart';
import 'package:medication/repos/prescription_repo.dart';

class PrescriptionViewModel extends StateNotifier<void> {
  final Ref ref;

  PrescriptionViewModel(this.ref) : super(null);

  Future<void> savePrescription(PrescriptionModel model) async {
    final repo = ref.read(prescriptionRepoProvider);
    await repo.savePrescription(model);
  }

  Future<void> deletePrescription(String id) async {
    final repo = ref.read(prescriptionRepoProvider);
    await repo.deletePrescription(id);
  }
}

final prescriptionProvider = StateNotifierProvider<PrescriptionViewModel, void>(
  (ref) => PrescriptionViewModel(ref),
);

final prescriptionStreamProvider = StreamProvider.autoDispose((ref) {
  final repo = ref.read(prescriptionRepoProvider);
  final uid = ref.read(authRepo).user?.uid;
  if (uid == null) return const Stream.empty();
  return repo.watchPrescriptionsByUser(uid);
});
