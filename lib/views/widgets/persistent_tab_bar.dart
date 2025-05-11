import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/sizes.dart';
import '../../utils.dart';

class PersistentTabBar extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final isDark = isDarkMode(ref);
        return Container(
          // 탭바가 하단의 리스트와 겹치게 보이는걸 방지하기 위해 컬러 속성 지정
          color:
              isDark ? Colors.black : Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
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
                  "내 정보",
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.size20),
                child: Text(
                  "알림 내역",
                  style: TextStyle(
                    fontSize: Sizes.size18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  double get maxExtent => 47;

  @override
  double get minExtent => 47;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
