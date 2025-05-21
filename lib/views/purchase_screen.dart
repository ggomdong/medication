import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/purchase_view_model.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PurchaseScreen extends ConsumerWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchaseProvider);

    return purchasesAsync.when(
      data: (purchases) {
        if (purchases.isEmpty) {
          return const Center(child: Text("구매 내역이 없습니다."));
        }

        return ListView.builder(
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final item = purchases[index];
            return ListTile(
              // leading: Image.asset(
              //   item.image,
              //   width: 40,
              //   height: 40,
              //   fit: BoxFit.cover,
              // ),
              // leading: ClipRRect(
              //   borderRadius: BorderRadius.circular(20),
              //   child: Image.asset(
              //     item.image,
              //     width: 40,
              //     height: 40,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              leading: CircleAvatar(backgroundImage: AssetImage(item.image)),
              title: Text(item.itemName),
              subtitle: Text(
                DateFormat('yyyy.MM.dd hh:mm:ss').format(item.purchasedAt),
              ),
              trailing: Text(
                "🅟 ${item.price}",
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Center(child: Text("${item.itemName} 교환권")),
                        content: SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: QrImageView(
                              data:
                                  item.id.isNotEmpty
                                      ? item.id
                                      : 'no-id', // ✅ null/빈 문자열 방지
                              size: 200,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("닫기"),
                          ),
                        ],
                      ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("오류 발생: $err")),
    );
  }
}
