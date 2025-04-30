import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication/models/prescription_model.dart';

class PrescriptionRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> savePrescription(PrescriptionModel model) async {
    await _db
        .collection('prescriptions')
        .doc(model.prescriptionId)
        .set(model.toJson());
  }
}

final prescriptionRepoProvider = Provider((ref) => PrescriptionRepository());
