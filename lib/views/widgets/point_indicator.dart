// widgets/point_indicator.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../router.dart';
import '../../view_models/user_view_model.dart';
import '../../constants/sizes.dart';

class PointIndicator extends ConsumerWidget {
  const PointIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(usersProvider);
    final currentLocation = GoRouterState.of(context).uri.toString();

    return userState.when(
      data:
          (user) => GestureDetector(
            onTap: () {
              if (currentLocation != RouteURL.pointStats) {
                context.push(RouteURL.pointStats);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "🅟 ${user.point}",
                style: const TextStyle(
                  fontSize: Sizes.size18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      loading:
          () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: Sizes.size18,
              width: Sizes.size18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      error: (e, _) => const Text("🅟 -"),
    );
  }
}
