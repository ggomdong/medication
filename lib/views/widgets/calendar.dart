// import '../../constants/sizes.dart';
// import '../../models/mood_model.dart';
// import '../../utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:table_calendar/table_calendar.dart';

// class Calendar extends StatelessWidget {
//   const Calendar({
//     super.key,
//     required this.day,
//     required this.moods,
//     required this.selectedDay,
//     required this.ref,
//   });

//   final DateTime day;
//   final List<MoodModel> moods;
//   final DateTime? selectedDay;
//   final WidgetRef ref;

//   @override
//   Widget build(BuildContext context) {
//     final isDark = isDarkMode(ref);
//     // 배경색 설정
//     Color? bgColor;
//     if (isSameDay(day, selectedDay)) {
//       bgColor =
//           isDark ? Colors.amber.shade700 : Colors.amber.shade100; // 선택된 날짜
//     } else if (isSameDay(day, DateTime.now())) {
//       bgColor = isDark ? Colors.pink.shade800 : Colors.pink.shade100; // 오늘
//     } else if (moods.isNotEmpty) {
//       bgColor =
//           isDark ? Colors.indigo.shade400 : Colors.blue.shade100; // mood가 있는 날
//     } else {
//       bgColor = Colors.transparent; // 기본 배경
//     }

//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: bgColor,
//           border: Border.all(color: Colors.grey, width: 1),
//         ),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // 날짜 (왼쪽 상단, 작은 폰트)
//             Positioned(
//               top: moods.isNotEmpty ? 4 : null,
//               left: moods.isNotEmpty ? 4 : null,
//               child: Text(
//                 '${day.day}',
//                 style: TextStyle(
//                   fontSize: moods.isNotEmpty ? Sizes.size10 : Sizes.size14,
//                   color: isDark ? Colors.white70 : Colors.black,
//                 ),
//               ),
//             ),

//             // 중앙 Mood 이모지 (없으면 빈 문자열)
//             Center(
//               child: Text(
//                 moods.isNotEmpty ? moods.first.mood : '', // 첫 번째 Mood만 표시
//                 style: const TextStyle(fontSize: Sizes.size20),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
