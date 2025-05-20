import '../../views/widgets/point_indicator.dart';
import '../../constants/sizes.dart';
import '../../constants/gaps.dart';
import '../../utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final TabBar? tabBar;

  const CommonAppBar({super.key, this.tabBar});

  static const double baseHeight = Sizes.size60;
  static const double tabBarHeight = kTextTabBarHeight; // 48

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode(ref);
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: Sizes.size10),
        child: Image.asset(isDark ? logoDarkmode : logo, height: 150),
      ),
      actions: const [PointIndicator(), Gaps.h20],
      bottom: tabBar,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(tabBar == null ? baseHeight : baseHeight + tabBarHeight);
}
