import 'package:flutter/material.dart';
import '../models/medi_model.dart'; // MediModel import
import '../view_models/record_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordScreen extends ConsumerStatefulWidget {
  final MediModel mediModel;

  const RecordScreen({super.key, required this.mediModel});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  String? selectedMealTime; // 아침, 점심, 저녁, 자유 중 선택

  final List<String> mealTimes = ['아침', '점심', '저녁', '자유'];

  @override
  Widget build(BuildContext context) {
    final recordViewModel = ref.watch(recordViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('복약 기록 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('약 이름: ${widget.mediModel.name}'),
            Text('종류: ${widget.mediModel.type}'),
            Text('복약 횟수: ${widget.mediModel.times_per_day}회'),
            Text('복약 시간: ${widget.mediModel.timing}'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '식사시간 선택'),
              items:
                  mealTimes.map((meal) {
                    return DropdownMenuItem(value: meal, child: Text(meal));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMealTime = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  selectedMealTime == null
                      ? null
                      : () async {
                        await recordViewModel.saveRecord(
                          widget.mediModel,
                          selectedMealTime!,
                        );
                        Navigator.of(context).pop(); // 저장 후 이전 화면으로
                      },
              child: const Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
