import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medi_model.dart';

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(),
);

class RecordRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveRecord(MediModel model) async {
    await _db.collection('medications').doc(model.mId).set(model.toJson());
  }
}
