import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prescription_model.dart';

class PrescriptionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _collection = 'prescriptions';

  /// 처방전 ID 존재 여부 확인
  Future<bool> prescriptionExists({
    required String originalPrescriptionId,
    required String uid,
  }) async {
    final query =
        await _db
            .collection(_collection)
            .where(
              'original_prescription_id',
              isEqualTo: originalPrescriptionId,
            )
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
    return query.docs.isNotEmpty;
  }

  /// 처방전 저장
  Future<String> savePrescription(PrescriptionModel model) async {
    // Firestore에 먼저 저장하고 docRef 받아옴
    final docRef = await _db.collection(_collection).add(model.toJson());

    // doc.id로 prescriptionId를 업데이트
    await docRef.update({'prescription_id': docRef.id});

    // 복약 스케쥴의 prescription_id도 docRef.id 값으로 하기 위해 return
    return docRef.id;
  }

  /// 처방전 삭제
  Future<void> deletePrescription(String id) async {
    final docRef = _db.collection(_collection).doc(id);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      // 존재하지 않으면 무시
    }
  }

  /// 처방전 Stream
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
