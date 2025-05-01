import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medication/models/medi_model.dart';
import 'package:medication/router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/prescription_model.dart';
import '../view_models/prescription_view_model.dart';
import '../views/widgets/form_button.dart';
import '../constants/gaps.dart';
import '../constants/sizes.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  final PrescriptionModel? prescription;
  final bool isModal;

  const PrescriptionScreen({
    super.key,
    this.prescription,
    this.isModal = false,
  });

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  final List<String> _times = [];

  @override
  void initState() {
    super.initState();
    if (widget.isModal) {
      // 수정 → 기존 값만 채운다
      _times.addAll(widget.prescription!.times);
    } else {
      // 신규 → 기본값
      _times.addAll(["09:00", "13:00", "19:00"]);
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
      final original = widget.prescription!;
      final updated = PrescriptionModel(
        prescriptionId: original.prescriptionId,
        diagnosis: original.diagnosis,
        medicines: original.medicines,
        startDate: original.startDate,
        endDate: original.endDate,
        timingDescription: original.timingDescription,
        times: _times,
        uid: original.uid,
        createdAt: original.createdAt,
      );
      await ref.read(prescriptionProvider.notifier).savePrescription(updated);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('처방전이 등록되었습니다.')));

      if (mounted) {
        if (widget.isModal) {
          Navigator.of(context).pop(); // 수정이면 모달 닫기
        } else {
          context.go(RouteURL.home); // 신규 등록 화면이면 QR로 이동
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('에러 발생: $e')));
    }
  }

  void _showMedicineDetail(MediModel m) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(m.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("주성분: ${m.ingredient}"),
                Text("약효군: ${m.type}"),
                TextButton.icon(
                  onPressed: () => launchUrl(Uri.parse(m.link)),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("의약품 정보 보기"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("닫기"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prescription;
    if (p == null) {
      return const Scaffold(body: Center(child: Text("처방전 정보가 없습니다.")));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("처방전 등록"),
        leading:
            widget.isModal
                ? Text("")
                : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.go(RouteURL.qr);
                  },
                ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.size20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.v20,
                const Text(
                  "병명",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Gaps.v10,
                Text(p.diagnosis, style: const TextStyle(fontSize: 16)),
                Gaps.v20,
                const Text(
                  "처방된 약 목록",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Gaps.v10,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      p.medicines
                          .map(
                            (m) => GestureDetector(
                              onTap: () => _showMedicineDetail(m),
                              child: Tooltip(
                                message: m.ingredient,
                                child: Chip(label: Text(m.name)),
                              ),
                            ),
                          )
                          .toList(),
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
                    disabled: _times.isEmpty ? true : false,
                    text: "처방전 저장",
                    onTap: _onSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
