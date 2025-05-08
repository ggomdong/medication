import '../../models/medi_model.dart';
import '../../models/prescription_model.dart';
import '../../view_models/prescription_view_model.dart';
import '../../views/prescription_screen.dart';
import '../../constants/gaps.dart';
import '../../constants/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class PrescriptionCard extends ConsumerStatefulWidget {
  const PrescriptionCard({
    super.key,
    required this.date,
    required this.prescription,
  });

  final String date;
  final PrescriptionModel prescription;

  @override
  ConsumerState<PrescriptionCard> createState() => _PrescriptionCardState();
}

class _PrescriptionCardState extends ConsumerState<PrescriptionCard> {
  void _showMedicineDetailDialog(MediModel m) {
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
                Gaps.v12,
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

  void _showUpdateBottomSheet(
    BuildContext context,
    PrescriptionModel prescription,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: true,
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom, // 키보드 올라올 때 패딩 조정
              ),
              child: PrescriptionScreen(
                prescription: prescription,
                isModal: true,
              ),
            ),
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, String prescriptionId) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => CupertinoActionSheet(
            title: const Text("삭제 확인"),
            message: const Text("정말로 삭제하시겠습니까?"),
            actions: [
              CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () => context.pop(),
                child: const Text("취소"),
              ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () async {
                  // Card가 dispose된 후에도 Provider에 접근
                  final container = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );

                  try {
                    await container
                        .read(prescriptionProvider.notifier)
                        .deletePrescriptionAndSchedules(prescriptionId);

                    // 다이얼로그 닫기
                    Navigator.pop(context);

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("처방전이 삭제되었습니다.")));
                  } catch (e) {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("삭제 실패: $e")));
                  }
                },
                child: const Text("삭제"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries =
        widget.prescription.times.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size4,
          horizontal: Sizes.size16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.prescription.diagnosis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "edit") {
                      _showUpdateBottomSheet(context, widget.prescription);
                    } else if (value == "delete") {
                      _showDeleteDialog(
                        context,
                        widget.prescription.prescriptionId,
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: "edit", child: Text("수정")),
                        const PopupMenuItem(value: "delete", child: Text("삭제")),
                      ],
                ),
              ],
            ),
            Gaps.v12,
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                Gaps.h8,
                Text(widget.date),
              ],
            ),
            Gaps.v8,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18, color: Colors.grey),
                    Gaps.h6,
                    Text(
                      '복약 스케줄',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Gaps.v8,
                ...sortedEntries.map((entry) {
                  final time = entry.key;
                  final meds =
                      entry.value.map((id) {
                        return widget.prescription.medicines.firstWhere(
                          (m) => m.medicineId == id,
                          orElse:
                              () => MediModel(
                                medicineId: id,
                                name: '알 수 없음',
                                ingredient: '',
                                type: '',
                                link: '',
                              ),
                        );
                      }).toList();

                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              time.replaceAll('"', ''),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Gaps.h8,
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    meds.map((m) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ActionChip(
                                          label: Text(m.name),
                                          avatar: const Icon(
                                            Icons.medication,
                                            size: 16,
                                          ),
                                          onPressed:
                                              () =>
                                                  _showMedicineDetailDialog(m),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gaps.v4,
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
