import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medication/models/prescription_model.dart';
import 'package:medication/view_models/prescription_view_model.dart';
import 'package:medication/view_models/schedule_view_model.dart';

class DailyMedicationSchedule extends ConsumerWidget {
  final DateTime date;
  const DailyMedicationSchedule({super.key, required this.date});

  String getMedicineNames(
    List<String> medicineIds,
    List<PrescriptionModel> prescriptions,
  ) {
    final names = <String>[];

    for (final pid in medicineIds) {
      for (final p in prescriptions) {
        for (final medi in p.medicines) {
          if (medi.medicineId == pid) {
            names.add(medi.name);
          }
        }
      }
    }

    return names.join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleViewModelProvider);
    final prescriptionState = ref.watch(prescriptionStreamProvider);

    if (scheduleState.isLoading || prescriptionState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final schedules = scheduleState.asData?.value ?? [];
    final prescriptions = prescriptionState.asData?.value ?? [];

    if (schedules.isEmpty) {
      return const Center(child: Text("복약 예정이 없습니다."));
    }

    final sorted = [...schedules]..sort((a, b) => a.time.compareTo(b.time));

    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final sched = sorted[index];
        final medicineText = getMedicineNames(sched.medicineIds, prescriptions);

        return ListTile(
          leading: Icon(
            sched.isTaken ? Icons.check_circle : Icons.access_time,
            color: sched.isTaken ? Colors.green : Colors.orange,
          ),
          title: Text("${sched.time} 복약"),
          subtitle: Text(medicineText),
          trailing:
              sched.isTaken
                  ? const Text("복용 완료", style: TextStyle(color: Colors.green))
                  : ElevatedButton(
                    onPressed: () {
                      ref
                          .read(scheduleViewModelProvider.notifier)
                          .markAsTaken(sched.scheduleId, DateTime.now());
                    },
                    child: const Text("복용 완료"),
                  ),
        );
      },
    );
  }
}

// class _ScheduleItem extends StatelessWidget {
//   final String time;
//   final List<(String, String)> meds;

//   const _ScheduleItem({required this.time, required this.meds});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           time,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         ...meds.map(
//           (med) => Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(med.$1, style: const TextStyle(fontSize: 16)),
//                       Text(
//                         med.$2,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (med == meds.first)
//                   ElevatedButton(onPressed: () {}, child: const Text("복용 완료")),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
