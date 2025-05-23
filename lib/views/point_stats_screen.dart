import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/sizes.dart';
import '../utils.dart';
import '../constants/gaps.dart';
import '../views/widgets/point_indicator.dart';
import '../views/widgets/point_earning_tab.dart';
import '../views/widgets/point_ranking_tab.dart';
import '../views/widgets/point_spending_tab.dart';

class PointStatsScreen extends ConsumerWidget {
  const PointStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode(ref);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("포인트 통계"),
          actions: const [PointIndicator(), Gaps.h20],
          bottom: TabBar(
            splashFactory: NoSplash.splashFactory,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 2,
            indicatorColor: isDark ? Colors.white : Colors.black,
            labelColor: isDark ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey.shade500,
            labelPadding: const EdgeInsets.symmetric(vertical: Sizes.size10),
            tabs: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
                child: Text(
                  "랭킹",
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
                child: Text(
                  "적립",
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
                child: Text(
                  "사용",
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
          children: [PointRankingTab(), PointEarningTab(), PointSpendingTab()],
        ),
      ),
    );
  }
}
