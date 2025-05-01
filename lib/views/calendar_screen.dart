import '../constants/gaps.dart';
import '../constants/sizes.dart';
import '../models/prescription_model.dart';
import '../view_models/prescription_view_model.dart';
import '../views/widgets/prescription_card.dart';
import '../views/widgets/common_app_bar.dart';
import '../views/widgets/calendar.dart';
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
  final ValueNotifier<List<PrescriptionModel>> _selectedPrescriptions =
      ValueNotifier([]);
  Map<int, List<PrescriptionModel>> prescriptionMap = {};
  bool _isFirstLoading = true;

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(ref);
    final prescriptionStream = ref.watch(prescriptionStreamProvider);

    return Scaffold(
      appBar: CommonAppBar(),
      body: prescriptionStream.when(
        loading:
            () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) => Center(child: Text("오류 발생: $err")),
        data: (prescriptionList) {
          prescriptionMap.clear();

          for (var prescription in prescriptionList) {
            final prescriptionDate =
                DateTime(
                  DateTime.fromMillisecondsSinceEpoch(
                    prescription.createdAt,
                  ).year,
                  DateTime.fromMillisecondsSinceEpoch(
                    prescription.createdAt,
                  ).month,
                  DateTime.fromMillisecondsSinceEpoch(
                    prescription.createdAt,
                  ).day,
                ).millisecondsSinceEpoch;

            prescriptionMap
                .putIfAbsent(prescriptionDate, () => [])
                .add(prescription);
          }

          // 최초 로딩시 오늘날짜의 mood를 가져오기 위한 작업
          if (_isFirstLoading) {
            final todayMillis =
                DateTime(
                  _selectedDay.value.year,
                  _selectedDay.value.month,
                  _selectedDay.value.day,
                ).millisecondsSinceEpoch;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectedPrescriptions.value = prescriptionMap[todayMillis] ?? [];
            });

            _isFirstLoading = false;
          }

          return Column(
            children: [
              SizedBox(
                height: 400,
                child: ValueListenableBuilder<DateTime>(
                  valueListenable: _selectedDay,
                  builder: (context, selectedDay, _) {
                    return TableCalendar(
                      locale: 'ko_KR',
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
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
                            ).millisecondsSinceEpoch; // 시간 정보 제거

                        _selectedDay.value = selectedDay;
                        _selectedPrescriptions.value =
                            prescriptionMap[normalizedDay] ?? [];
                      },
                      onPageChanged: (newFocusedDay) {
                        // 오늘 버튼을 눌렀을 때는 월 변경 로직을 실행하지 않도록 예외 처리
                        if (isSameDay(newFocusedDay, DateTime.now())) return;

                        final newFirstDay = DateTime(
                          newFocusedDay.year,
                          newFocusedDay.month,
                          1,
                        ); // 변경된 월의 정확한 1일

                        // 달력에서 focusedDay를 바꿔줌 (중요)
                        _focusedDay = newFirstDay;

                        // ValueNotifier를 사용하여 상태 변경
                        _selectedDay.value = newFirstDay;
                        final firstDayMillis =
                            newFirstDay.millisecondsSinceEpoch;
                        _selectedPrescriptions.value =
                            prescriptionMap[firstDayMillis] ??
                            []; // 해당 월의 1일 Mood 불러오기
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
                                DateFormat.yMMMM(
                                  'ko_KR',
                                ).format(date), // "2024년 3월" 형식으로 표시
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8), // 년월과 버튼 사이 간격
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
                                  _selectedPrescriptions.value =
                                      prescriptionMap[todayMillis] ?? [];
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
                        defaultBuilder: (context, day, focusedDay) {
                          final dayMillis =
                              DateTime(
                                day.year,
                                day.month,
                                day.day,
                              ).millisecondsSinceEpoch;
                          final moods = prescriptionMap[dayMillis] ?? [];
                          return null;

                          // return Calendar(
                          //   day: day,
                          //   moods: moods,
                          //   selectedDay: selectedDay,
                          //   ref: ref,
                          // );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          final dayMillis =
                              DateTime(
                                day.year,
                                day.month,
                                day.day,
                              ).millisecondsSinceEpoch;
                          final moods = prescriptionMap[dayMillis] ?? [];
                          return null;

                          // return Calendar(
                          //   day: day,
                          //   moods: moods,
                          //   selectedDay: selectedDay,
                          //   ref: ref,
                          // );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          final dayMillis =
                              DateTime(
                                day.year,
                                day.month,
                                day.day,
                              ).millisecondsSinceEpoch;
                          final moods = prescriptionMap[dayMillis] ?? [];
                          return null;

                          // return Calendar(
                          //   day: day,
                          //   moods: moods,
                          //   selectedDay: selectedDay,
                          //   ref: ref,
                          // );
                        },
                      ),
                    );
                  },
                ),
              ),
              Gaps.v20,
              Expanded(
                child: ValueListenableBuilder<List<PrescriptionModel>>(
                  valueListenable: _selectedPrescriptions,
                  builder: (context, moods, _) {
                    return moods.isNotEmpty
                        ? ListView.builder(
                          itemCount: moods.length,
                          itemBuilder: (context, index) {
                            final mood = moods[index];
                            final date = DateFormat(
                              'yyyy-MM-dd (E) HH:mm',
                              'ko',
                            ).format(
                              DateTime.fromMillisecondsSinceEpoch(
                                mood.createdAt,
                              ),
                            );
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Sizes.size32,
                              ),
                              child: PrescriptionCard(
                                date: date,
                                prescription: mood,
                              ),
                            );
                          },
                        )
                        : const Padding(
                          padding: EdgeInsets.all(Sizes.size16),
                          child: Text(
                            '복약 기록이 없어요.',
                            style: TextStyle(fontSize: Sizes.size16),
                          ),
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
