import '../views/prescription_screen.dart';
import '../models/prescription_model.dart';
import '../views/widgets/month_date_selector.dart';
import '../repos/authentication_repo.dart';
import '../utils.dart';
import '../view_models/schedule_view_model.dart';
import '../views/widgets/daily_medication_schedule.dart';
import '../constants/sizes.dart';
import '../constants/gaps.dart';
import '../view_models/prescription_view_model.dart';
import '../views/widgets/common_app_bar.dart';
import '../views/widgets/prescription_card.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ValueNotifier<DateTime> selectedDate;
  late final ValueNotifier<DateTime> weekStartDate;
  late final PageController _pageController;
  int _currentPage = 0;

  // List<DateTime> get currentWeek {
  //   final today = DateTime.now();
  //   final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
  //   return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  // }

  void _moveMonth(int offset) {
    final base = selectedDate.value;
    final newDate = DateTime(base.year, base.month + offset, 1);
    selectedDate.value = newDate;

    final uid = ref.read(authRepo).user?.uid;
    if (uid != null) {
      ref.read(scheduleViewModelProvider.notifier).loadSchedules(uid, newDate);
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko');

    selectedDate = ValueNotifier(DateTime.now());
    weekStartDate = ValueNotifier(getStartOfWeek(DateTime.now()));
    _pageController = PageController(viewportFraction: 0.85);

    // 복약 스케쥴 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(authRepo).user?.uid;
      if (uid != null) {
        ref
            .read(scheduleViewModelProvider.notifier)
            .loadSchedules(uid, selectedDate.value);
      }
    });
  }

  void _onWriteManualPrescription() {
    final emptyPrescription = PrescriptionModel(
      prescriptionId: '',
      originalPrescriptionId: '',
      diagnosis: '',
      medicines: [],
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      timingDescription: '',
      times: {},
      uid: ref.read(authRepo).user?.uid ?? '',
      createdAt: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PrescriptionScreen(
              prescription: emptyPrescription,
              isManual: true,
            ),
      ),
    );
  }

  @override
  void dispose() {
    selectedDate.dispose();
    weekStartDate.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionStream = ref.watch(prescriptionStreamProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CommonAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.size16),
        child: Column(
          children: [
            ValueListenableBuilder<DateTime>(
              valueListenable: selectedDate,
              builder: (context, selected, _) {
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // WeekDateSelector(
                      //   weekStartDate: weekStart,
                      //   selectedDate: selected,
                      //   onDateSelected: (date) {
                      //     // ref
                      //     //     .read(scheduleViewModelProvider.notifier)
                      //     //     .setSelectedDate(date);
                      //     selectedDate.value = date;
                      //     final uid = ref.read(authRepo).user?.uid;
                      //     if (uid != null) {
                      //       ref
                      //           .read(scheduleViewModelProvider.notifier)
                      //           .loadSchedules(uid, date);
                      //     }
                      //   },
                      //   onPreviousWeek:
                      //       () =>
                      //           weekStartDate.value = weekStart.subtract(
                      //             const Duration(days: 7),
                      //           ),
                      //   onNextWeek:
                      //       () =>
                      //           weekStartDate.value = weekStart.add(
                      //             const Duration(days: 7),
                      //           ),
                      // ),
                      MonthDateSelector(
                        currentMonth: selected,
                        selectedDate: selectedDate.value,
                        onToday: () {
                          final today = DateTime.now();
                          selectedDate.value = today;
                          final uid = ref.read(authRepo).user?.uid;
                          if (uid != null) {
                            ref
                                .read(scheduleViewModelProvider.notifier)
                                .loadSchedules(uid, today);
                          }
                        },
                        onDateSelected: (date) {
                          selectedDate.value = date;
                          final uid = ref.read(authRepo).user?.uid;
                          if (uid != null) {
                            ref
                                .read(scheduleViewModelProvider.notifier)
                                .loadSchedules(uid, date);
                          }
                        },
                        onPreviousMonth: () => _moveMonth(-1),
                        onNextMonth: () => _moveMonth(1),
                      ),
                      const Divider(height: 1),
                      Gaps.v10,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: [
                            Icon(Icons.medication),
                            Gaps.h10,
                            Text(
                              "복약 스케쥴",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 복약스케쥴도 selectedDate가 바뀌면 리빌드됨
                      Expanded(child: DailyMedicationSchedule(date: selected)),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Icon(Icons.list_alt),
                  Gaps.h10,
                  Text(
                    "처방전 목록",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Gaps.h10,
                  TextButton.icon(
                    onPressed: _onWriteManualPrescription,
                    icon: const Icon(Icons.add),
                    label: const Text("직접 등록"),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: prescriptionStream.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text("오류 발생: $error")),
                data: (prescriptionList) {
                  if (prescriptionList.isEmpty) {
                    return const Center(child: Text("등록된 처방전이 없어요."));
                  }

                  return SizedBox(
                    height: 240, // 카드 높이에 맞게 조절
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: prescriptionList.length,
                          itemBuilder: (context, index) {
                            final prescription = prescriptionList[index];
                            final start = DateFormat(
                              "yyyy.MM.dd",
                            ).format(prescription.startDate);
                            final end = DateFormat(
                              "yyyy.MM.dd",
                            ).format(prescription.endDate);
                            final dateText = "$start ~ $end";

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: PrescriptionCard(
                                date: dateText,
                                prescription: prescription,
                              ),
                            );
                          },
                        ),
                        if (_currentPage > 0)
                          Positioned(
                            left: 0,
                            top: 90,
                            child: GestureDetector(
                              onTap: _goToPreviousPage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(left: 8),
                                child: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                        if (_currentPage < prescriptionList.length - 1)
                          Positioned(
                            right: 0,
                            top: 90,
                            child: GestureDetector(
                              onTap: _goToNextPage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(right: 8),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
