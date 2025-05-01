import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prescription_model.dart';

class PrescriptionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> savePrescription(PrescriptionModel model) async {
    // Firestore에 먼저 저장하고 docRef 받아옴
    final docRef = await _db.collection('prescriptions').add(model.toJson());

    // doc.id로 prescriptionId를 업데이트
    await docRef.update({'prescription_id': docRef.id});
  }

  Future<void> deletePrescription(String id) async {
    await _db.collection('prescriptions').doc(id).delete();
  }

  Stream<List<PrescriptionModel>> watchPrescriptionsByUser(String uid) {
    final snapshots =
        _db
            .collection('prescriptions')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots();

    return snapshots.map(
      (query) =>
          query.docs
              .map(
                (doc) => PrescriptionModel.fromJson(doc.data(), docId: doc.id),
              )
              .toList(),
    );
  }
}

final prescriptionRepoProvider = Provider((ref) => PrescriptionRepository());
