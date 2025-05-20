import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/prescription_view_model.dart';
import '../../view_models/schedule_view_model.dart';

class PointEarningTab extends ConsumerWidget {
  const PointEarningTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleStreamProvider);
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
                    return {
                      "reason": "$diagnosis 약 복용",
                      "date": formattedDate,
                      "takenAt": takenAt,
                    };
                  }).toList()
                  ..sort(
                    (a, b) => (b["takenAt"] as DateTime).compareTo(
                      a["takenAt"] as DateTime,
                    ),
                  );

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
                    "+10 🅟",
                    style: TextStyle(color: Colors.green, fontSize: 16),
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
