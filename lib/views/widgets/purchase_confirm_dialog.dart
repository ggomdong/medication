import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/purchase_model.dart';
import '../../view_models/purchase_view_model.dart';
import '../../view_models/user_view_model.dart';

class PurchaseConfirmDialog extends ConsumerWidget {
  final Map<String, String> item;
  const PurchaseConfirmDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(usersProvider).valueOrNull;
    final price = int.tryParse(item['price'] ?? '0') ?? 0;

    if (user == null) return const SizedBox.shrink();
    final canBuy = user.point >= price;

    return AlertDialog(
      title: Text(item['name']!),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("가격: ${price}P"),
          Text("보유 포인트: ${user.point}P"),
          if (!canBuy)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text("포인트가 부족합니다.", style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("취소"),
        ),
        TextButton(
          onPressed:
              !canBuy
                  ? null
                  : () async {
                    // 1. 포인트 차감
                    await ref.read(usersProvider.notifier).updatePoint(-price);

                    // 2. Firestore에 저장
                    final purchase = PurchaseModel(
                      id: '', // 임시, repo.save()에서 자동 ID 부여
                      userId: user.uid,
                      itemName: item['name']!,
                      price: price,
                      image: item['image']!,
                      purchasedAt: DateTime.now(),
                    );

                    await ref.read(purchaseProvider.notifier).save(purchase);

                    // 3. 피드백 후 종료
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${item['name']} 구매 완료!")),
                    );
                  },
          child: const Text("구매하기"),
        ),
      ],
    );
  }
}
