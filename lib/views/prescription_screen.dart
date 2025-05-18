import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils.dart';
import '../router.dart';
import '../models/medi_model.dart';
import '../models/prescription_model.dart';
import '../view_models/prescription_view_model.dart';
import '../view_models/schedule_view_model.dart';
import '../views/widgets/form_button.dart';
import '../constants/gaps.dart';
import '../constants/sizes.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  final PrescriptionModel prescription;
  final bool isModal; // 수정 시에 모달로 띄우므로, 수정 여부
  final bool isManual; // 직접 입력 여부

  const PrescriptionScreen({
    super.key,
    required this.prescription,
    this.isModal = false,
    this.isManual = false,
  });

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  List<MediModel> _selectedMedicines = [];

  final _diagnosisController = TextEditingController();

  late DateTime _startDate;
  late DateTime _endDate;

  final _timingDescController = TextEditingController();

  final Map<String, List<String>> _times = {};

  @override
  void initState() {
    super.initState();

    if (widget.isManual) {
      _diagnosisController.text = '';
      _selectedMedicines = [];
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
      _timingDescController.text = '';
    } else {
      _diagnosisController.text = widget.prescription.diagnosis;
      _selectedMedicines = widget.prescription.medicines;
      _startDate = widget.prescription.startDate;
      _endDate = widget.prescription.endDate;
      _timingDescController.text = widget.prescription.timingDescription;
    }

    if (widget.isModal) {
      // 수정 → 기존 값만 채운다
      _times.addAll(widget.prescription.times);
    } else {
      // 신규 모드 → 기본 시간 3개 + 전체 약 할당
      final allMeds =
          (widget.isManual ? _selectedMedicines : widget.prescription.medicines)
              .map((m) => m.medicineId)
              .toList();
      _times.addAll({
        "09:00": List.from(allMeds),
        "13:00": List.from(allMeds),
        "19:00": List.from(allMeds),
      });
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _timingDescController.dispose();
    super.dispose();
  }

  Future<void> _selectMedicines() async {
    final result = await showDialog<List<MediModel>>(
      context: context,
      builder: (_) {
        final selected = [..._selectedMedicines];
        final dummyMeds = [
          MediModel(
            medicineId: 'm00001',
            name: '오메가3',
            ingredient: 'EPA+DHA',
            type: '영양제',
            link: 'https://...',
          ),
          MediModel(
            medicineId: 'm00002',
            name: '타이레놀',
            ingredient: 'Acetaminophen',
            type: '해열진통제',
            link: 'https://...',
          ),
        ];

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("약 선택"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      dummyMeds.map((m) {
                        final checked = selected.any(
                          (s) => s.medicineId == m.medicineId,
                        );
                        return CheckboxListTile(
                          value: checked,
                          title: Text(m.name),
                          subtitle: Text(m.ingredient),
                          onChanged: (value) {
                            setStateDialog(() {
                              if (value == true) {
                                selected.add(m);
                              } else {
                                selected.removeWhere(
                                  (s) => s.medicineId == m.medicineId,
                                );
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

    if (result != null) {
      setState(() {
        _selectedMedicines = result;
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
        final medicineSource =
            widget.isManual
                ? _selectedMedicines
                : widget.prescription.medicines;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("[$timeStr] 복약할 약 선택"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      medicineSource.map((m) {
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
        final medicineSource =
            widget.isManual
                ? _selectedMedicines
                : widget.prescription.medicines;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("[$time] 복약할 약 선택"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      medicineSource.map((m) {
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

    if (widget.isManual) {
      if (_diagnosisController.text.trim().isEmpty) {
        showSingleSnackBar(context, "병명을 입력해주세요");
        return;
      }

      if (_selectedMedicines.isEmpty) {
        showSingleSnackBar(context, "약을 1개 이상 선택해주세요");
        return;
      }

      if (_startDate.isAfter(_endDate)) {
        showSingleSnackBar(context, "복약 종료일은 시작일 이후여야 합니다");
        return;
      }

      // 약이 매핑되어 있지 않은 복약시간은 삭제
      setState(() {
        _times.removeWhere((time, meds) => meds.isEmpty);
      });

      if (_times.isEmpty) {
        showSingleSnackBar(
          context,
          "복약 시간을 추가하고, 각 복약 시간에 복용할 약을 1개 이상 선택해주세요",
        );
        return;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final original = widget.prescription;
      final updated = PrescriptionModel(
        prescriptionId: original.prescriptionId,
        originalPrescriptionId: original.originalPrescriptionId,
        diagnosis:
            widget.isManual
                ? _diagnosisController.text.trim()
                : original.diagnosis,
        medicines: widget.isManual ? _selectedMedicines : original.medicines,
        startDate: widget.isManual ? _startDate : original.startDate,
        endDate: widget.isManual ? _endDate : original.endDate,
        timingDescription:
            widget.isManual
                ? _timingDescController.text.trim()
                : original.timingDescription,
        times: _times,
        uid: original.uid,
        createdAt: original.createdAt,
      );

      // 처방전 및 복약 스케쥴 저장
      await ref
          .read(prescriptionProvider.notifier)
          .savePrescriptionAndSchedule(updated);

      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        await ref.read(scheduleViewModelProvider.notifier).reload(); // ✅ 스케쥴 갱신

        // 완료 처리
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('처방전이 등록되었습니다.')));

        if (widget.isManual) Navigator.of(context).pop(); // 뒤로 가기
        if (widget.isModal) {
          Navigator.of(context).pop(); // 수정이면 모달 닫기
        } else {
          print("xx");
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
    final isManual = widget.isManual;
    final sortedEntries =
        _times.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    final medicineSource =
        widget.isManual ? _selectedMedicines : widget.prescription.medicines;

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
                    isManual ? context.pop() : context.go(RouteURL.home);
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
                isManual
                    ? TextFormField(
                      controller: _diagnosisController,
                      decoration: const InputDecoration(
                        hintText: "예: 고혈압, 당뇨 등",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                    )
                    : Text(p.diagnosis, style: const TextStyle(fontSize: 16)),
                Gaps.v20,
                const Text(
                  "처방된 약 목록",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Gaps.v10,
                isManual
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _selectedMedicines
                                  .map(
                                    (m) => InputChip(
                                      label: Text(m.name),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedMedicines.remove(m);
                                        });
                                      },
                                      onPressed: () => _showMedicineDetail(m),
                                    ),
                                  )
                                  .toList(),
                        ),
                        Gaps.v10,
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("약 추가"),
                          onPressed: _selectMedicines,
                        ),
                      ],
                    )
                    : Wrap(
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
                  "복약 기간",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Gaps.v8,
                isManual
                    ? Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${_startDate.toLocal()}".split(' ')[0],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Gaps.h12,
                        const Text("~", style: TextStyle(fontSize: 18)),
                        Gaps.h12,
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: _startDate,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _endDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${_endDate.toLocal()}".split(' ')[0],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Text(
                      "복약 기간: ${p.startDate.toLocal().toString().split(' ')[0]} ~ ${p.endDate.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 16),
                    ),

                Gaps.v10,
                const Text(
                  "복약 시점 설명",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Gaps.v10,
                isManual
                    ? TextFormField(
                      controller: _timingDescController,
                      decoration: const InputDecoration(
                        hintText: "예: 식후 30분, 자기 전 등",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                    )
                    : Text(
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
                            (id) => medicineSource.firstWhere(
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
