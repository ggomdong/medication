import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/gaps.dart';
import '../../constants/sizes.dart';
import '../../router.dart';
import '../../view_models/user_view_model.dart';
import '../widgets/health_chart_modal.dart';

class HealthInfo extends ConsumerWidget {
  const HealthInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(usersProvider);

    return userState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("오류 발생: $err")),
      data:
          (user) => ListView(
            padding: const EdgeInsets.all(Sizes.size16),
            children: [
              Row(
                children: [
                  const Icon(Icons.health_and_safety, color: Colors.red),
                  Gaps.h8,
                  const Text(
                    "나의 건강정보",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Gaps.h8,
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        builder: (context) => const HealthChartModal(),
                      );
                    },
                    icon: const Icon(
                      Icons.insert_chart_outlined,
                      color: Colors.amber,
                    ),
                    tooltip: '건강 통계 보기',
                  ),
                ],
              ),
              Gaps.v10,
              _buildInfoRow(
                "키",
                user.height != null ? "${user.height}cm" : "미입력",
              ),
              _buildInfoRow(
                "몸무게",
                user.weight != null ? "${user.weight}kg" : "미입력",
              ),
              _buildInfoRow("나이", user.age != null ? "${user.age}세" : "미입력"),
              _buildInfoRow("혈압", user.bloodPressure ?? "미입력"),
              _buildInfoRow("식사 시간", user.mealTimes?.join(" / ") ?? "미입력"),
              Gaps.v16,
              ElevatedButton.icon(
                onPressed: () => context.push(RouteURL.healthInfo),
                icon: const Icon(Icons.edit),
                label: const Text("건강정보 입력"),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
