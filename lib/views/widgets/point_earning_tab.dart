import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/prescription_view_model.dart';
import '../../view_models/schedule_view_model.dart';
import '../../models/schedule_model.dart';
import '../../models/prescription_model.dart';
import '../../constants/gaps.dart';
import '../../repos/prescription_repo.dart';

class PointEarningTab extends ConsumerWidget {
  const PointEarningTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleViewModelProvider);
    final prescriptionsAsync = ref.watch(prescriptionStreamProvider);

    return schedulesAsync.when(
      data: (schedules) {
        return prescriptionsAsync.when(
          data: (prescriptions) {
            final idToDiagnosis = {
              for (final p in prescriptions) p.prescriptionId: p.diagnosis,
            };

            final earningHistory =
                schedules.where((s) => s.isTaken && s.takenAt != null).map((s) {
                    final diagnosis =
                        idToDiagnosis[s.prescriptionId] ?? "알 수 없음";
                    final takenAt = DateTime.fromMillisecondsSinceEpoch(
                      s.takenAt!,
                    );
                    final formattedDate =
                        "${takenAt.year}-${takenAt.month.toString().padLeft(2, '0')}-${takenAt.day.toString().padLeft(2, '0')} "
                        "${takenAt.hour.toString().padLeft(2, '0')}:${takenAt.minute.toString().padLeft(2, '0')}";
                    return {"reason": "$diagnosis 약 복용", "date": formattedDate};
                  }).toList()
                  ..sort((a, b) => b["date"]!.compareTo(a["date"]!));

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: earningHistory.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final e = earningHistory[index];
                return ListTile(
                  leading: const Icon(Icons.add_circle, color: Colors.green),
                  title: Text(e["reason"]!),
                  subtitle: Text(e["date"]!),
                  trailing: const Text(
                    "+10점",
                    style: TextStyle(color: Colors.green),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("처방전 정보를 불러오지 못했습니다: $e")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("스케쥴을 불러오지 못했습니다: $e")),
    );
  }
}
