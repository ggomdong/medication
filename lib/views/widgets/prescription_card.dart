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

                  await container
                      .read(prescriptionProvider.notifier)
                      .deletePrescription(prescriptionId);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("삭제되었습니다.")));
                },
                child: const Text("삭제"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: Sizes.size16),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.size16),
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
            Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                Gaps.h8,
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children:
                        widget.prescription.times
                            .map(
                              (t) => Chip(
                                label: Text(t),
                                backgroundColor: Colors.blue.shade50,
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
            Gaps.v8,
            Row(
              children: [
                Icon(Icons.medication, size: 18, color: Colors.grey),
                Gaps.h8,
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          widget.prescription.medicines
                              .map(
                                (m) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => _showMedicineDetailDialog(m),
                                    child: Tooltip(
                                      message: m.ingredient,
                                      child: Chip(label: Text(m.name)),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
