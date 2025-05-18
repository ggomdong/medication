import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router.dart';
import '../../views/widgets/health_chart_modal.dart';
import '../../constants/gaps.dart';
import '../../constants/sizes.dart';

class MedicationInfo extends StatelessWidget {
  const MedicationInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Sizes.size16),
      children: [
        Row(
          children: [
            Icon(Icons.health_and_safety, color: Colors.red),
            Gaps.h8,
            Text(
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
                  builder: (context) => HealthChartModal(),
                );
              },
              // onPressed: () => context.push(RouteURL.healthStats),
              icon: Icon(Icons.insert_chart_outlined, color: Colors.amber),
              tooltip: '건강 통계 보기',
            ),
          ],
        ),
        Gaps.v10,
        _buildInfoRow("키", "170cm"),
        _buildInfoRow("몸무게", "65kg"),
        _buildInfoRow("나이", "43세"),
        _buildInfoRow("혈압", "120/80"),
        _buildInfoRow("식사 시간", "08:00 / 12:00 / 18:00"),
        Gaps.v16,
        ElevatedButton.icon(
          onPressed: () => context.push(RouteURL.info),
          icon: Icon(Icons.edit),
          label: Text("건강정보 입력"),
        ),
        // Divider(thickness: 1),
        // Row(
        //   children: const [
        //     Icon(Icons.medical_services, color: Colors.blue),
        //     Gaps.h8,
        //     Text(
        //       "복용중인 약 정보",
        //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //     ),
        //   ],
        // ),
        // Gaps.v10,
        // _buildMedicineCard("오메가3", "하루 1회 식후 복용"),
        // _buildMedicineCard("혈압약", "아침 식전"),
        // Gaps.v20,
        // Center(child: ElevatedButton(onPressed: () {}, child: Text("약 정보 수정"))),
      ],
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

  Widget _buildMedicineCard(String name, String usage) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        title: Text(name),
        subtitle: Text(usage),
        trailing: Icon(Icons.chevron_right),
        onTap: () {}, // 약 상세 보기 예정
      ),
    );
  }
}
