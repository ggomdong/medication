import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/purchase_view_model.dart';

class PointSpendingTab extends ConsumerWidget {
  const PointSpendingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchaseProvider);

    return purchasesAsync.when(
      data: (purchases) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: purchases.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final p = purchases[index];
            final formattedDate =
                "${p.purchasedAt.year}-${p.purchasedAt.month.toString().padLeft(2, '0')}-${p.purchasedAt.day.toString().padLeft(2, '0')} "
                "${p.purchasedAt.hour.toString().padLeft(2, '0')}:${p.purchasedAt.minute.toString().padLeft(2, '0')}";

            return ListTile(
              leading: const Icon(Icons.remove_circle, color: Colors.red),
              title: Text(p.itemName),
              subtitle: Text(formattedDate),
              trailing: Text(
                "-${p.price} 🅟",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("사용 내역을 불러오지 못했습니다: $e")),
    );
  }
}
