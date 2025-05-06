import 'package:flutter/material.dart';
import 'package:medication/constants/gaps.dart';
import 'package:medication/constants/sizes.dart';

class NextMedicationCard extends StatelessWidget {
  const NextMedicationCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ViewModel이나 Provider에서 가장 가까운 복약 스케쥴 가져오기

    return Container(
      padding: const EdgeInsets.all(Sizes.size16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(Sizes.size16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "다음 복약 예정",
            style: TextStyle(color: Colors.white70, fontSize: Sizes.size16),
          ),
          Gaps.v8,
          Text(
            "13:00 복약 예정", // 실제 데이터 반영 필요
            style: const TextStyle(
              color: Colors.white,
              fontSize: Sizes.size20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gaps.v4,
          const Text(
            "오메가3, 철분 (내과 처방전)",
            style: TextStyle(color: Colors.white60, fontSize: Sizes.size14),
          ),
          Gaps.v14,
          ElevatedButton.icon(
            onPressed: () {
              // TODO: 복용 완료 처리
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text("복용 완료"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(
                vertical: Sizes.size12,
                horizontal: Sizes.size20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
