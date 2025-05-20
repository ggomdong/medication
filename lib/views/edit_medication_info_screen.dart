import 'package:flutter/material.dart';
import '../constants/gaps.dart';

class EditMedicationInfoScreen extends StatefulWidget {
  const EditMedicationInfoScreen({super.key});

  @override
  State<EditMedicationInfoScreen> createState() =>
      _EditMedicationInfoScreenState();
}

class _EditMedicationInfoScreenState extends State<EditMedicationInfoScreen> {
  final _heightCtrl = TextEditingController(text: '170');
  final _weightCtrl = TextEditingController(text: '65');
  final _ageCtrl = TextEditingController(text: '43');
  final _bloodPressureCtrl = TextEditingController(text: '120/80');
  final _mealTimesCtrl = TextEditingController(text: '08:00, 12:00, 18:00');
  // final List<String> _medicineList = ['오메가3 (하루 1회 식후복용)', '혈압약 (아침 식전)'];

  // void _addMedicine() async {
  //   final result = await showDialog<String>(
  //     context: context,
  //     builder: (context) {
  //       final mediCtrl = TextEditingController();
  //       return AlertDialog(
  //         title: Text("약 추가"),
  //         content: TextField(
  //           controller: mediCtrl,
  //           decoration: InputDecoration(labelText: "약 이름"),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text("취소"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (mediCtrl.text.trim().isNotEmpty) {
  //                 Navigator.pop(context, mediCtrl.text.trim());
  //               }
  //             },
  //             child: Text("추가"),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (result != null && !_medicineList.contains(result)) {
  //     setState(() {
  //       _medicineList.add(result);
  //     });
  //   }
  // }

  // Widget _buildSectionTitle(IconData icon, String title) {
  //   return Row(
  //     children: [
  //       Icon(icon, color: Theme.of(context).primaryColor),
  //       Gaps.h8,
  //       Text(title, style: Theme.of(context).textTheme.titleMedium),
  //     ],
  //   );
  // }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("건강정보 입력")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // _buildSectionTitle(Icons.health_and_safety, "건강정보"),
          _buildTextField("키 (cm)", _heightCtrl),
          _buildTextField("몸무게 (kg)", _weightCtrl),
          _buildTextField("나이", _ageCtrl),
          _buildTextField("혈압", _bloodPressureCtrl),
          _buildTextField("식사 시간 (쉼표로 구분)", _mealTimesCtrl),
          Gaps.v24,
          // _buildSectionTitle(Icons.medical_services, "복용중인 약"),
          // if (_medicineList.isEmpty) Text("등록된 약이 없습니다."),
          // ..._medicineList.map(
          //   (m) => ListTile(
          //     title: Text(m),
          //     trailing: IconButton(
          //       icon: Icon(Icons.delete),
          //       onPressed: () {
          //         setState(() {
          //           _medicineList.remove(m);
          //         });
          //       },
          //     ),
          //   ),
          // ),
          // Gaps.v12,
          // ElevatedButton.icon(
          //   onPressed: _addMedicine,
          //   icon: Icon(Icons.add),
          //   label: Text("약 추가"),
          // ),
          // Gaps.v32,
          ElevatedButton(
            onPressed: () {
              // TODO: 실제 저장 로직
              Navigator.pop(context);
            },
            child: Text("저장하기"),
          ),
        ],
      ),
    );
  }
}
