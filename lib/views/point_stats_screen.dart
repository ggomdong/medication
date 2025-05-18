import 'package:flutter/material.dart';
import '../constants/gaps.dart';
import '../views/widgets/point_indicator.dart';
import '../views/widgets/point_earning_tab.dart';
import '../views/widgets/point_ranking_tab.dart';
import '../views/widgets/point_spending_tab.dart';

class PointStatsScreen extends StatelessWidget {
  const PointStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("포인트 통계"),
          actions: const [PointIndicator(), Gaps.h20],
          bottom: const TabBar(
            tabs: [Tab(text: "랭킹"), Tab(text: "적립"), Tab(text: "사용")],
          ),
        ),
        body: const TabBarView(
          children: [PointRankingTab(), PointEarningTab(), PointSpendingTab()],
        ),
      ),
    );
  }
}
