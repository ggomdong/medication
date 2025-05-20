import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/user_view_model.dart';
import '../models/purchase_model.dart';
import '../repos/purchase_repo.dart';

class PurchaseViewModel extends AsyncNotifier<List<PurchaseModel>> {
  PurchaseRepository get _repo => ref.read(purchaseRepo);

  @override
  Future<List<PurchaseModel>> build() async {
    final user = ref.watch(usersProvider).valueOrNull;
    if (user == null) return [];
    return await _repo.fetchByUser(user.uid);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await build());
  }

  Future<void> save(PurchaseModel model) async {
    await _repo.save(model);
    await refresh();
  }
}

final purchaseProvider =
    AsyncNotifierProvider<PurchaseViewModel, List<PurchaseModel>>(
      PurchaseViewModel.new,
    );
