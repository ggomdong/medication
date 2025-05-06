import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prescription_model.dart';

class PrescriptionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _collection = 'prescriptions';

  Future<String> savePrescription(PrescriptionModel model) async {
    // Firestore에 먼저 저장하고 docRef 받아옴
    final docRef = await _db.collection(_collection).add(model.toJson());

    // doc.id로 prescriptionId를 업데이트
    await docRef.update({'prescription_id': docRef.id});

    // 복약 스케쥴의 prescription_id도 docRef.id 값으로 하기 위해 return
    return docRef.id;
  }

  Future<void> deletePrescription(String id) async {
    final docRef = _db.collection(_collection).doc(id);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      // 존재하지 않으면 무시
    }
  }

  Stream<List<PrescriptionModel>> watchPrescriptionsByUser(String uid) {
    final snapshots =
        _db
            .collection(_collection)
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
