import '../repos/authentication_repo.dart';
import '../utils.dart';
import '../view_models/schedule_view_model.dart';
import '../views/widgets/daily_medication_schedule.dart';
import '../views/widgets/week_date_selector.dart';
import '../constants/sizes.dart';
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

  List<DateTime> get currentWeek {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _onScaffoldTap() {
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko');

    selectedDate = ValueNotifier(DateTime.now());
    weekStartDate = ValueNotifier(getStartOfWeek(DateTime.now()));
  }

  @override
  void dispose() {
    selectedDate.dispose();
    weekStartDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionStream = ref.watch(prescriptionStreamProvider);

    return GestureDetector(
      onTap: _onScaffoldTap,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CommonAppBar(),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Sizes.size16),
          child: Column(
            children: [
              ValueListenableBuilder<DateTime>(
                valueListenable: weekStartDate,
                builder: (context, weekStart, _) {
                  return ValueListenableBuilder<DateTime>(
                    valueListenable: selectedDate,
                    builder: (context, selected, _) {
                      return WeekDateSelector(
                        weekStartDate: weekStart,
                        selectedDate: selected,
                        onDateSelected: (date) {
                          selectedDate.value = date;
                          final uid = ref.read(authRepo).user?.uid;
                          if (uid != null) {
                            ref
                                .read(scheduleViewModelProvider.notifier)
                                .loadSchedules(uid, date);
                          }
                        },
                        onPreviousWeek:
                            () =>
                                weekStartDate.value = weekStart.subtract(
                                  const Duration(days: 7),
                                ),
                        onNextWeek:
                            () =>
                                weekStartDate.value = weekStart.add(
                                  const Duration(days: 7),
                                ),
                      );
                    },
                  );
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: DailyMedicationSchedule(date: selectedDate.value),
              ),
              const Divider(height: 1),
              Expanded(
                child: prescriptionStream.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text("오류 발생: $error")),
                  data: (prescriptionList) {
                    if (prescriptionList.isEmpty) {
                      return const Center(child: Text("등록된 처방전이 없어요."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(Sizes.size16),
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

                        return PrescriptionCard(
                          date: dateText,
                          prescription: prescription,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
