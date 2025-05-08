import '../../constants/sizes.dart';
import '../../constants/gaps.dart';
import '../../utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommonAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key});

  static const double customHeight = Sizes.size60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = isDarkMode(ref);
    return Padding(
      padding: const EdgeInsets.only(top: Sizes.size10),
      child: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Image.asset(isDark ? logoDarkmode : logo, height: 150),
        actions: [
          Text(
            "🅟 2,000",
            style: TextStyle(
              fontSize: 20,
              // color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          Gaps.h20,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(customHeight);
}
