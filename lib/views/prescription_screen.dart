import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../router.dart';
import '../models/medi_model.dart';
import '../models/prescription_model.dart';
import '../view_models/prescription_view_model.dart';
import '../views/widgets/form_button.dart';
import '../constants/gaps.dart';
import '../constants/sizes.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  final PrescriptionModel prescription;
  final bool isModal;

  const PrescriptionScreen({
    super.key,
    required this.prescription,
    this.isModal = false,
  });

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  final Map<String, List<String>> _times = {};

  @override
  void initState() {
    super.initState();
    if (widget.isModal) {
      // 수정 → 기존 값만 채운다
      _times.addAll(widget.prescription.times);
    } else {
      // 신규 모드 → 기본 시간 3개 + 전체 약 할당
      final allMeds =
          widget.prescription.medicines.map((m) => m.medicineId).toList();
      _times.addAll({
        "09:00": List.from(allMeds),
        "13:00": List.from(allMeds),
        "19:00": List.from(allMeds),
      });
    }
  }

  void _addTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    final timeStr =
        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    final selectedResult = await showDialog<List<String>>(
      context: context,
      builder: (_) {
        final selected = <String>[];
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("[$timeStr] 복약할 약 선택"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      widget.prescription.medicines.map((m) {
                        return CheckboxListTile(
                          title: Text(m.name),
                          value: selected.contains(m.medicineId),
                          onChanged: (checked) {
                            setStateDialog(() {
                              if (checked == true) {
                                selected.add(m.medicineId);
                              } else {
                                selected.remove(m.medicineId);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selected),
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedResult != null && selectedResult.isNotEmpty) {
      setState(() {
        _times[timeStr] = selectedResult;
      });
    }
  }

  void _addMedicineToTime(String time) async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (_) {
        final selected = List<String>.from(_times[time] ?? []);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("[$time] 복약할 약 선택"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      widget.prescription.medicines.map((m) {
                        return CheckboxListTile(
                          title: Text(m.name),
                          value: selected.contains(m.medicineId),
                          onChanged: (checked) {
                            setStateDialog(() {
                              if (checked == true) {
                                selected.add(m.medicineId);
                              } else {
                                selected.remove(m.medicineId);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selected),
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (selected.isEmpty) {
          _times.remove(time); // 아무것도 선택되지 않으면 시간도 삭제
        } else {
          _times[time] = selected; // 선택된 약만 반영
        }
      });
    }
  }

  void _changeTime(String oldTime) async {
    final parts = oldTime.split(":");
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(context: context, initialTime: initial);

    if (picked != null) {
      final newTime =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      if (newTime != oldTime && !_times.containsKey(newTime)) {
        setState(() {
          _times[newTime] = _times.remove(oldTime)!;
        });
      } else if (newTime != oldTime) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("이미 존재하는 시간입니다.")));
      }
    }
  }

  void _removeMedicineFromTime(String time, String id) {
    setState(() {
      _times[time]!.remove(id);
      if (_times[time]!.isEmpty) {
        _times.remove(time);
      }
    });
  }

  void _onSubmit() async {
    if (_times.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final original = widget.prescription;
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

      // 처방전 및 복약 스케쥴 저장
      await ref
          .read(prescriptionProvider.notifier)
          .savePrescriptionAndSchedule(updated);

      // 완료 처리
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
    final sortedEntries =
        _times.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: widget.isModal ? const Text("처방전 수정") : const Text("처방전 등록"),
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
                ...sortedEntries.map((entry) {
                  final time = entry.key;
                  final medIds = entry.value;
                  final meds =
                      medIds
                          .map(
                            (id) => widget.prescription.medicines.firstWhere(
                              (m) => m.medicineId == id,
                              orElse:
                                  () => MediModel(
                                    medicineId: id,
                                    name: '알 수 없음',
                                    ingredient: '',
                                    type: '',
                                    link: '',
                                  ),
                            ),
                          )
                          .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _changeTime(time),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                time,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addMedicineToTime(time),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed:
                                () => setState(() => _times.remove(time)),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children:
                            meds
                                .map(
                                  (m) => InputChip(
                                    label: Text(m.name),
                                    onDeleted:
                                        () => _removeMedicineFromTime(
                                          time,
                                          m.medicineId,
                                        ),
                                    onPressed: () => _showMedicineDetail(m),
                                  ),
                                )
                                .toList(),
                      ),
                      const Divider(),
                    ],
                  );
                }),
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
