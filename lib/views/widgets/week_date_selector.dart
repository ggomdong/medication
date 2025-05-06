import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medication/constants/gaps.dart';
import 'package:medication/utils.dart';

class WeekDateSelector extends StatelessWidget {
  final DateTime weekStartDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const WeekDateSelector({
    super.key,
    required this.weekStartDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('yyyy년 M월').format(weekStartDate);

    final weekDates = List.generate(
      7,
      (i) => weekStartDate.add(Duration(days: i)),
    );

    return Column(
      children: [
        Gaps.v12,
        Text(
          month,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Gaps.v8,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onPreviousWeek,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    weekDates.map((date) {
                      final isToday = DateUtils.isSameDay(date, DateTime.now());
                      final isSelected = DateUtils.isSameDay(
                        date,
                        selectedDate,
                      );
                      final weekdayLabel =
                          ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7];

                      return GestureDetector(
                        onTap: () => onDateSelected(date),
                        child: Column(
                          children: [
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? Colors.blue
                                        : isToday
                                        ? Colors.orange
                                        : Colors.grey,
                              ),
                            ),
                            Text(
                              weekdayLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? Colors.blue
                                        : isToday
                                        ? Colors.orange
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: onNextWeek,
            ),
          ],
        ),
        Gaps.v12,
      ],
    );
  }
}
