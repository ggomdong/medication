import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medication/constants/gaps.dart';
import 'package:medication/models/prescription_model.dart';
import 'package:medication/models/schedule_model.dart';
import 'package:medication/models/medi_model.dart';
import 'package:medication/utils.dart';
import 'package:medication/view_models/prescription_view_model.dart';
import 'package:medication/view_models/schedule_view_model.dart';

class DailyMedicationSchedule extends ConsumerWidget {
  final DateTime date;
  const DailyMedicationSchedule({super.key, required this.date});

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
      return const Center(child: Text("오늘 복약 예정이 없습니다."));
    }

    final sorted = [...schedules]..sort((a, b) => a.time.compareTo(b.time));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children:
            sorted.map((sched) {
              final diagnosis = _findDiagnosis(
                sched.medicineIds,
                prescriptions,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _PillScheduleItem(
                  schedule: sched,
                  diagnosis: diagnosis ?? '정보 없음',
                  onToggle: () {
                    final newTaken = !sched.isTaken;
                    ref
                        .read(scheduleViewModelProvider.notifier)
                        .markAsTaken(
                          scheduleId: sched.scheduleId,
                          isTaken: newTaken,
                          takenAt: newTaken ? DateTime.now() : null,
                        );
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  String? _findDiagnosis(
    List<String> medicineIds,
    List<PrescriptionModel> prescriptions,
  ) {
    for (final p in prescriptions) {
      if (p.medicines.any((m) => medicineIds.contains(m.medicineId))) {
        return p.diagnosis;
      }
    }
    return null;
  }
}

class _PillScheduleItem extends StatelessWidget {
  final ScheduleModel schedule;
  final String diagnosis;
  final VoidCallback onToggle;

  const _PillScheduleItem({
    required this.schedule,
    required this.diagnosis,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isTaken = schedule.isTaken;
    final formattedTime = schedule.time;

    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTaken ? Colors.green.shade100 : Colors.white,
              border: Border.all(
                color: isTaken ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              appIcon,
              width: 64,
              height: 64,
              color: isTaken ? Colors.green : null,
              colorBlendMode: BlendMode.modulate,
            ),
          ),
        ),
        Gaps.v8,
        Text(formattedTime, style: Theme.of(context).textTheme.titleSmall),
        Text(
          diagnosis,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:medication/constants/gaps.dart';
// import 'package:medication/models/prescription_model.dart';
// import 'package:medication/models/medi_model.dart';
// import 'package:medication/view_models/prescription_view_model.dart';

// class DailyMedicationSchedule extends ConsumerWidget {
//   final DateTime date;
//   const DailyMedicationSchedule({super.key, required this.date});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final prescriptionState = ref.watch(prescriptionStreamProvider);

//     if (prescriptionState.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final prescriptions = prescriptionState.asData?.value ?? [];
//     final todayStr = DateFormat('yyyy-MM-dd').format(date);

//     final List<_ScheduleCardData> allCards = [];

//     // 1. 처방전 순회
//     for (final p in prescriptions) {
//       if (date.isBefore(p.startDate) || date.isAfter(p.endDate)) continue;

//       // 2. times의 키(시간) 순회
//       final sortedTimes = _sortTimes(p.times.keys);

//       for (final timeStr in sortedTimes) {
//         final ids = p.times[timeStr] ?? [];

//         final meds =
//             (p.medicines as List<MediModel>)
//                 .where((m) => ids.contains(m.medicineId))
//                 .toList();

//         if (meds.isEmpty) continue;

//         allCards.add(
//           _ScheduleCardData(
//             timeStr: timeStr,
//             diagnosis: p.diagnosis,
//             medicines: meds,
//           ),
//         );
//       }
//     }

//     if (allCards.isEmpty) {
//       return const Center(child: Text("오늘 복약 예정이 없어요."));
//     }

//     // 3. 시간순 정렬
//     allCards.sort((a, b) => a.timeStr.compareTo(b.timeStr));

//     return ListView.builder(
//       itemCount: allCards.length,
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//       itemBuilder: (context, index) {
//         final data = allCards[index];
//         return _buildCard(context, data);
//       },
//     );
//   }

//   List<String> _sortTimes(Iterable<String> timeStrs) {
//     final times = timeStrs.toList();
//     times.sort((a, b) {
//       final t1 = DateFormat("HH:mm").parse(a);
//       final t2 = DateFormat("HH:mm").parse(b);
//       return t1.compareTo(t2);
//     });
//     return times;
//   }

//   Widget _buildCard(BuildContext context, _ScheduleCardData data) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 시간 및 병명
//             Row(
//               children: [
//                 Text(
//                   data.timeStr,
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 Gaps.h10,
//                 Text(
//                   data.diagnosis,
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // 복약 완료 처리 로직 추후 연동
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("${data.timeStr} 복약 완료!")),
//                       );
//                     },
//                     child: const Text("복약 완료"),
//                   ),
//                 ),
//               ],
//             ),
//             // 약 목록 (Chip)
//             Wrap(
//               spacing: 2,
//               runSpacing: 2,
//               children:
//                   data.medicines.map((m) => Chip(label: Text(m.name))).toList(),
//             ),

//             // 복약 완료 버튼 (추후 기능 확장 가능)
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 내부 전용 데이터 클래스
// class _ScheduleCardData {
//   final String timeStr;
//   final String diagnosis;
//   final List<MediModel> medicines;

//   _ScheduleCardData({
//     required this.timeStr,
//     required this.diagnosis,
//     required this.medicines,
//   });
// }





// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:medication/constants/gaps.dart';
// import 'package:medication/models/prescription_model.dart';
// import 'package:medication/view_models/prescription_view_model.dart';
// import 'package:medication/view_models/schedule_view_model.dart';

// class DailyMedicationSchedule extends ConsumerWidget {
//   final DateTime date;
//   const DailyMedicationSchedule({super.key, required this.date});

//   String getMedicineNames(
//     List<String> medicineIds,
//     List<PrescriptionModel> prescriptions,
//   ) {
//     final names = <String>[];

//     for (final pid in medicineIds) {
//       for (final p in prescriptions) {
//         for (final medi in p.medicines) {
//           if (medi.medicineId == pid) {
//             names.add(medi.name);
//           }
//         }
//       }
//     }

//     return names.join(', ');
//   }

//   String? findDiagnosis(
//     String medicineId,
//     List<PrescriptionModel> prescriptions,
//   ) {
//     for (final p in prescriptions) {
//       if (p.medicines.any((m) => m.medicineId == medicineId)) {
//         return p.diagnosis; // 또는 p.name, p.title 등
//       }
//     }
//     return null;
//   }

//   List<Widget> getMedicineChips(
//     List<String> ids,
//     List<PrescriptionModel> prescriptions,
//   ) {
//     final chips = <Widget>[];
//     for (final pid in ids) {
//       for (final p in prescriptions) {
//         for (final medi in p.medicines) {
//           if (medi.medicineId == pid) {
//             chips.add(
//               Chip(
//                 label: SizedBox(
//                   width: 50,
//                   height: 20,
//                   child: Center(child: Text(medi.name)),
//                 ),
//               ),
//             );
//           }
//         }
//       }
//     }
//     return chips;
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final scheduleState = ref.watch(scheduleViewModelProvider);
//     final prescriptionState = ref.watch(prescriptionStreamProvider);

//     if (scheduleState.isLoading || prescriptionState.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final schedules = scheduleState.asData?.value ?? [];
//     final prescriptions = prescriptionState.asData?.value ?? [];

//     if (schedules.isEmpty) {
//       return const Center(child: Text("복약 예정이 없습니다."));
//     }

//     final sorted = [...schedules]..sort((a, b) => a.time.compareTo(b.time));

//     return ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: sorted.length,
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//       itemBuilder: (context, index) {
//         final sched = sorted[index];
//         final medicineText = getMedicineNames(sched.medicineIds, prescriptions);

//         return Card(
//           elevation: 3,
//           margin: const EdgeInsets.symmetric(horizontal: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Container(
//             width: 260,
//             height: 100,
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 시간 + 병명
//                 Row(
//                   children: [
//                     Text(
//                       sched.time,
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       "병명: ${sched.isTaken ?? '정보 없음'}",
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     Gaps.h4,
//                     // 복약 완료 버튼 또는 텍스트
//                     sched.isTaken
//                         ? const Text(
//                           "복약 완료",
//                           style: TextStyle(color: Colors.green),
//                         )
//                         : Align(
//                           alignment: Alignment.centerRight,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               minimumSize: Size(30, 20),
//                             ),
//                             onPressed: () {
//                               ref
//                                   .read(scheduleViewModelProvider.notifier)
//                                   .markAsTaken(
//                                     sched.scheduleId,
//                                     DateTime.now(),
//                                   );
//                             },
//                             child: const Text("복약 완료"),
//                           ),
//                         ),
//                   ],
//                 ),
//                 // 약 목록 (Chip)
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: getMedicineChips(sched.medicineIds, prescriptions),
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//           ),
//         );



        //         // return ListTile(
        //         //   leading: Icon(
        //         //     sched.isTaken ? Icons.check_circle : Icons.access_time,
        //         //     color: sched.isTaken ? Colors.green : Colors.orange,
        //         //   ),
        //         //   title: Text("${sched.time} 복약"),
        //         //   subtitle: Text(medicineText),
        //         //   trailing:
        //         //       sched.isTaken
        //         //           ? const Text("복약 완료", style: TextStyle(color: Colors.green))
        //         //           : ElevatedButton(
        //         //             onPressed: () {
        //         //               ref
        //         //                   .read(scheduleViewModelProvider.notifier)
        //         //                   .markAsTaken(sched.scheduleId, DateTime.now());
        //         //             },
        //         //             child: const Text("복약 완료"),
        //         //           ),
        //         // );


//       },
//     );
//   }
// }
