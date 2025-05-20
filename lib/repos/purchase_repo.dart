import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_model.dart';

class PurchaseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'purchases';

  /// 구매 저장 (Firestore 문서 ID 자동 생성)
  Future<void> save(PurchaseModel model) async {
    final doc = _db.collection(_collection).doc(); // Firebase ID 자동 생성
    final modelWithId = model.copyWith(id: doc.id);
    await doc.set(modelWithId.toJson());
  }

  Future<List<PurchaseModel>> fetchByUser(String uid) async {
    final snapshot =
        await _db
            .collection(_collection)
            .where('userId', isEqualTo: uid)
            .orderBy('purchasedAt', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => PurchaseModel.fromJson(doc.data(), doc.id))
        .toList();
  }
}

final purchaseRepo = Provider((ref) => PurchaseRepository());
