import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/sizes.dart';
import '../utils.dart';
import '../views/widgets/common_app_bar.dart';
import '../views/purchase_screen.dart';
import '../views/shop_screen.dart';

class ShopRootScreen extends ConsumerWidget {
  const ShopRootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode(ref);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CommonAppBar(
          tabBar: TabBar(
            splashFactory: NoSplash.splashFactory,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 2,
            indicatorColor: isDark ? Colors.white : Colors.black,
            labelColor: isDark ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey.shade500,
            labelPadding: const EdgeInsets.symmetric(vertical: Sizes.size10),
            tabs: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
                child: Text(
                  "상품 교환",
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
                child: Text(
                  "교환 내역",
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ShopScreen(), // 상품 목록 탭
            PurchaseScreen(), // 구매 내역 탭
          ],
        ),
      ),
    );
  }
}
