// prescription_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/prescription_model.dart';
import '../view_models/prescription_view_model.dart';
import '../views/widgets/common_app_bar.dart';
import '../views/widgets/form_button.dart';
import '../constants/gaps.dart';
import '../constants/sizes.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  final PrescriptionModel? prescription;

  const PrescriptionScreen({super.key, this.prescription});

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  final List<String> _times = [];

  @override
  void initState() {
    super.initState();
    final p = widget.prescription;
    if (p != null) {
      _times.addAll(p.times);
    }
  }

  void _addTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final timeStr =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      if (!_times.contains(timeStr)) {
        setState(() => _times.add(timeStr));
      }
    }
  }

  void _onSubmit() async {
    if (_times.isEmpty || widget.prescription == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final updated = PrescriptionModel(
        prescriptionId: widget.prescription!.prescriptionId,
        medicineIds: widget.prescription!.medicineIds,
        startDate: widget.prescription!.startDate,
        endDate: widget.prescription!.endDate,
        timingDescription: widget.prescription!.timingDescription,
        times: _times,
      );

      await ref.read(prescriptionProvider.notifier).savePrescription(updated);
      if (mounted) context.go("/home");
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prescription;
    if (p == null) {
      return const Scaffold(body: Center(child: Text("처방전 정보가 없습니다.")));
    }

    return Scaffold(
      appBar: CommonAppBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.v20,
              const Text(
                "처방된 약 목록",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Gaps.v10,
              Wrap(
                spacing: 8,
                children:
                    p.medicineIds.map((id) => Chip(label: Text(id))).toList(),
              ),
              Gaps.v20,
              Text(
                "복약 기간: ${p.startDate.toLocal().toString().split(' ')[0]} ~ ${p.endDate.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(fontSize: 16),
              ),
              Gaps.v10,
              Text(
                "복약 시점 설명: ${p.timingDescription}",
                style: const TextStyle(fontSize: 16),
              ),
              Gaps.v20,
              const Text(
                "복약 시간을 입력하세요",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Gaps.v10,
              Wrap(
                spacing: 8,
                children:
                    _times
                        .map(
                          (t) => Chip(
                            label: Text(t),
                            onDeleted: () => setState(() => _times.remove(t)),
                          ),
                        )
                        .toList(),
              ),
              Gaps.v10,
              ElevatedButton.icon(
                onPressed: () => _addTime(context),
                icon: const Icon(Icons.access_time),
                label: const Text("시간 추가"),
              ),
              Gaps.v40,
              Center(
                child: FormButton(
                  disabled: false,
                  text: "처방전 저장",
                  onTap: _onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
