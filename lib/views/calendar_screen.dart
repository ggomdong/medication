import '../view_models/prescription_view_model.dart';
import '../views/widgets/stat_item.dart';
import '../models/schedule_model.dart';
import '../view_models/schedule_view_model.dart';
import '../constants/gaps.dart';
import '../constants/sizes.dart';
import '../views/widgets/common_app_bar.dart';
import '../utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  final ValueNotifier<DateTime> _selectedDay = ValueNotifier(DateTime.now());
  final ValueNotifier<List<ScheduleModel>> _selectedSchedules = ValueNotifier(
    [],
  );
  Map<int, List<ScheduleModel>> scheduleMap = {};
  bool _isFirstLoading = true;

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(ref);
    final scheduleStream = ref.watch(scheduleStreamProvider);
    final prescriptionStream = ref.watch(prescriptionStreamProvider);

    return Scaffold(
      appBar: CommonAppBar(),
      body: scheduleStream.when(
        loading:
            () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) => Center(child: Text("오류 발생: $err")),
        data: (schedules) {
          scheduleMap.clear();
          int total = 0;
          int taken = 0;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final focusedMonth = DateTime(_focusedDay.year, _focusedDay.month);
          final isCurrentMonth =
              focusedMonth.year == today.year &&
              focusedMonth.month == today.month;
          final isFutureMonth = focusedMonth.isAfter(today);

          if (!isFutureMonth) {
            for (var schedule in schedules) {
              final scheduleMonth = DateTime(
                schedule.date.year,
                schedule.date.month,
              );
              if (scheduleMonth != focusedMonth) continue;
              if (isCurrentMonth && schedule.date.isAfter(today)) continue;

              final key =
                  DateTime(
                    schedule.date.year,
                    schedule.date.month,
                    schedule.date.day,
                  ).millisecondsSinceEpoch;
              scheduleMap.putIfAbsent(key, () => []).add(schedule);

              total++;
              if (schedule.isTaken) taken++;
            }
          }

          if (_isFirstLoading) {
            final todayMillis =
                DateTime(
                  _selectedDay.value.year,
                  _selectedDay.value.month,
                  _selectedDay.value.day,
                ).millisecondsSinceEpoch;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectedSchedules.value = scheduleMap[todayMillis] ?? [];
            });

            _isFirstLoading = false;
          }

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatItem(
                    icon: Icons.check_circle,
                    title: "복약 완료",
                    value: "$taken 건",
                    color: Colors.green,
                  ),
                  StatItem(
                    icon: Icons.cancel,
                    title: "복약 누락",
                    value: "${total - taken} 건",
                    color: Colors.redAccent,
                  ),
                  StatItemAnimated(
                    icon: Icons.percent,
                    title: "복약률",
                    rate:
                        (total > 0 && !isFutureMonth)
                            ? (taken / total * 100)
                            : null,
                    color: Colors.blue,
                  ),
                ],
              ),
              Gaps.v16,
              SizedBox(
                height: 400,
                child: ValueListenableBuilder<DateTime>(
                  valueListenable: _selectedDay,
                  builder: (context, selectedDay, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size16,
                      ),
                      child: TableCalendar(
                        locale: 'ko_KR',
                        daysOfWeekHeight: 20,
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2050, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate:
                            (day) => isSameDay(selectedDay, day),
                        calendarFormat: CalendarFormat.month,
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          final normalizedDay =
                              DateTime(
                                selectedDay.year,
                                selectedDay.month,
                                selectedDay.day,
                              ).millisecondsSinceEpoch;

                          _selectedDay.value = selectedDay;
                          _selectedSchedules.value =
                              scheduleMap[normalizedDay] ?? [];
                        },
                        onPageChanged: (newFocusedDay) {
                          final newMonth = DateTime(
                            newFocusedDay.year,
                            newFocusedDay.month,
                          );

                          // ✅ 캘린더 UI 반영을 위해 반드시 setState로 감쌈
                          setState(() {
                            _focusedDay = newMonth;
                            _selectedDay.value = newMonth;
                          });

                          final firstDayMillis =
                              newMonth.millisecondsSinceEpoch;

                          // ✅ UI 빌드 이후에 _selectedSchedules 업데이트 (바로 하면 race condition 가능성 있음)
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _selectedSchedules.value =
                                scheduleMap[firstDayMillis] ?? [];
                          });
                        },

                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: Sizes.size14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: Sizes.size14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.red.shade300 : Colors.red,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          headerTitleBuilder: (context, date) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat.yMMMM('ko_KR').format(date),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Gaps.h8,
                                TextButton(
                                  onPressed: () {
                                    final today = DateTime.now();
                                    final todayMillis =
                                        DateTime(
                                          today.year,
                                          today.month,
                                          today.day,
                                        ).millisecondsSinceEpoch;

                                    _focusedDay = today;
                                    _selectedDay.value = today;
                                    _selectedSchedules.value =
                                        scheduleMap[todayMillis] ?? [];
                                  },
                                  child: const Text(
                                    "오늘",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          defaultBuilder: (context, day, _) {
                            final millis =
                                DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                ).millisecondsSinceEpoch;
                            final daySchedules = scheduleMap[millis] ?? [];

                            final total = daySchedules.length;
                            final taken =
                                daySchedules.where((s) => s.isTaken).length;

                            double? rate;
                            if (total > 0) rate = taken / total;

                            Color? bgColor;
                            if (rate == null) {
                              bgColor = null;
                            } else if (rate >= 0.8) {
                              bgColor = Colors.green[200];
                            } else if (rate >= 0.5) {
                              bgColor = Colors.orange[200];
                            } else {
                              bgColor = Colors.red[200];
                            }

                            return Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: bgColor,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ), // 테두리 있으면 예쁨
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('${day.day}'),
                            );
                          },

                          todayBuilder: (context, day, _) {
                            final millis =
                                DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                ).millisecondsSinceEpoch;
                            final daySchedules = scheduleMap[millis] ?? [];

                            final total = daySchedules.length;
                            final taken =
                                daySchedules.where((s) => s.isTaken).length;

                            double? rate;
                            if (total > 0) rate = taken / total;

                            Color? bgColor;
                            if (rate == null) {
                              bgColor = Colors.blue[300]; // 기본 fallback
                            } else if (rate >= 0.8) {
                              bgColor = Colors.green[300];
                            } else if (rate >= 0.5) {
                              bgColor = Colors.orange[300];
                            } else {
                              bgColor = Colors.red[300];
                            }

                            return Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },

                          selectedBuilder: (context, day, _) {
                            final millis =
                                DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                ).millisecondsSinceEpoch;
                            final daySchedules = scheduleMap[millis] ?? [];

                            final total = daySchedules.length;
                            final taken =
                                daySchedules.where((s) => s.isTaken).length;

                            double? rate;
                            if (total > 0) rate = taken / total;

                            Color? bgColor;
                            if (rate == null) {
                              bgColor = null;
                            } else if (rate >= 0.8) {
                              bgColor = Colors.green[200];
                            } else if (rate >= 0.5) {
                              bgColor = Colors.orange[200];
                            } else {
                              bgColor = Colors.red[200];
                            }

                            return Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: bgColor,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<List<ScheduleModel>>(
                  valueListenable: _selectedSchedules,
                  builder: (context, schedules, _) {
                    if (schedules.isEmpty) {
                      return const Center(child: Text("복약 기록이 없습니다."));
                    }

                    final Map<String, String> idToDiagnosis = {
                      for (final p in prescriptionStream.asData?.value ?? [])
                        p.prescriptionId: p.diagnosis,
                    };

                    final Map<String, List<ScheduleModel>> grouped = {};
                    // 병명으로 그룹핑
                    for (final s in schedules) {
                      final diagnosis =
                          idToDiagnosis[s.prescriptionId] ?? s.prescriptionId;
                      grouped.putIfAbsent(diagnosis, () => []).add(s);
                    }

                    // 1. 그룹 이름 정렬 (병명 기준 오름차순)
                    final sortedKeys = grouped.keys.toList()..sort();

                    // 2. 각 그룹 내 시간 정렬
                    for (final key in sortedKeys) {
                      grouped[key]!.sort((a, b) => a.time.compareTo(b.time));
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children:
                          sortedKeys.map((diagnosis) {
                            final items = grouped[diagnosis]!;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      diagnosis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children:
                                            items.map((s) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                child: Chip(
                                                  label: Text(s.time),
                                                  avatar: Icon(
                                                    s.isTaken
                                                        ? Icons.check_circle
                                                        : Icons.cancel_outlined,
                                                    color:
                                                        s.isTaken
                                                            ? Colors.green
                                                            : Colors.redAccent,
                                                    size: 18,
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
