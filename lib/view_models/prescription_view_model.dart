import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication/models/prescription_model.dart';
import 'package:medication/repos/prescription_repo.dart';

class PrescriptionViewModel extends StateNotifier<void> {
  final Ref ref;

  PrescriptionViewModel(this.ref) : super(null);

  Future<void> savePrescription(PrescriptionModel model) async {
    final repo = ref.read(prescriptionRepoProvider);
    await repo.savePrescription(model);
  }
}

final prescriptionProvider = StateNotifierProvider<PrescriptionViewModel, void>(
  (ref) => PrescriptionViewModel(ref),
);
