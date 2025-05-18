import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../constants/gaps.dart';

class HealthChartModal extends StatefulWidget {
  const HealthChartModal({super.key});

  @override
  State<HealthChartModal> createState() => _HealthChartModalState();
}

class _HealthChartModalState extends State<HealthChartModal> {
  bool isDaily = true;
  DateTime selectedDate = DateTime.now();

  // void _selectDate() async {
  //   if (isDaily) {
  //     final picked = await showDatePicker(
  //       context: context,
  //       initialDate: selectedDate,
  //       firstDate: DateTime(2023),
  //       lastDate: DateTime.now(),
  //     );
  //     if (picked != null) setState(() => selectedDate = picked);
  //   } else {
  //     final picked = await showMonthPicker(
  //       context: context,
  //       initialDate: selectedDate,
  //     );
  //     if (picked != null) setState(() => selectedDate = picked);
  //   }
  // }

  void _selectMonth(BuildContext context) async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '건강 통계',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Gaps.v8,
            ToggleButtons(
              isSelected: [isDaily, !isDaily],
              onPressed: (i) {
                setState(() => isDaily = i == 0);
              },
              children: const [Text('일별'), Text('월별')],
            ),
            Gaps.v8,
            // TextButton.icon(
            //   onPressed: _selectDate,
            //   icon: const Icon(Icons.calendar_today),
            //   label: Text(
            //     isDaily
            //         ? "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일"
            //         : "${selectedDate.year}년 ${selectedDate.month}월",
            //   ),
            // ),
            TextButton.icon(
              onPressed: () => _selectMonth(context),
              icon: const Icon(Icons.calendar_today),
              label:
                  isDaily
                      ? Text("${selectedDate.year}년 ${selectedDate.month}월")
                      : Text("${selectedDate.year}년"),
            ),

            Gaps.v16,
            Expanded(
              child: _BloodPressureChart(
                isDaily: isDaily,
                selectedDate: selectedDate,
              ),
            ),
            Gaps.v24,
            Expanded(
              child: _WeightChart(isDaily: isDaily, selectedDate: selectedDate),
            ),
          ],
        ),
      ),
    );
  }
}

class _BloodPressureChart extends StatelessWidget {
  final bool isDaily;
  final DateTime selectedDate;

  const _BloodPressureChart({
    required this.isDaily,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();

    double generateInRange(double min, double max) {
      return min + random.nextDouble() * (max - min);
    }

    final today = DateTime.now();
    final maxIndex =
        isDaily
            ? (selectedDate.year == today.year &&
                    selectedDate.month == today.month
                ? today.day
                : DateUtils.getDaysInMonth(
                  selectedDate.year,
                  selectedDate.month,
                ))
            : (selectedDate.year == today.year ? today.month : 12);

    final systolicSpots = List.generate(maxIndex, (i) {
      final y = generateInRange(110, 130);
      return FlSpot(i.toDouble(), y);
    });

    final diastolicSpots = List.generate(maxIndex, (i) {
      final y = generateInRange(70, 85);
      return FlSpot(i.toDouble(), y);
    });

    final labels =
        isDaily
            ? List.generate(31, (i) => '${i + 1}일')
            : List.generate(12, (i) => '${i + 1}월');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '혈압 추이 (${isDaily ? "일별" : "월별"})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Gaps.v12,
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: isDaily ? 30 : 11,
                lineBarsData: [
                  LineChartBarData(
                    spots: systolicSpots,
                    isCurved: true,
                    dotData: FlDotData(show: false),
                    color: Colors.red,
                  ),
                  LineChartBarData(
                    spots: diastolicSpots,
                    isCurved: true,
                    dotData: FlDotData(show: false),
                    color: Colors.blueGrey,
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // 위쪽 라벨 제거!
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        // x축 라벨: 일별 또는 월별
                        final int index = value.toInt();

                        if (index >= 0 && index < labels.length) {
                          return Text(
                            labels[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          space: 6,
                          meta: meta,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // 또는 필요 시 true
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightChart extends StatelessWidget {
  final bool isDaily;
  final DateTime selectedDate;

  const _WeightChart({required this.isDaily, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final random = Random();

    double generateInRange(double min, double max) {
      return min + random.nextDouble() * (max - min);
    }

    final today = DateTime.now();
    final maxIndex =
        isDaily
            ? (selectedDate.year == today.year &&
                    selectedDate.month == today.month
                ? today.day
                : DateUtils.getDaysInMonth(
                  selectedDate.year,
                  selectedDate.month,
                ))
            : (selectedDate.year == today.year ? today.month : 12);

    final spots = List.generate(maxIndex, (i) {
      final y = generateInRange(64, 66);
      return FlSpot(i.toDouble(), y);
    });

    final labels =
        isDaily
            ? List.generate(31, (i) => '${i + 1}일')
            : List.generate(12, (i) => '${i + 1}월');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '몸무게 추이 (${isDaily ? "일별" : "월별"})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Gaps.v12,
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: isDaily ? 30 : 11,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    dotData: FlDotData(show: false),
                    color: Colors.green,
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false), // 위쪽 라벨 제거!
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        // x축 라벨: 일별 또는 월별
                        final int index = value.toInt();

                        if (index >= 0 && index < labels.length) {
                          return Text(
                            labels[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          space: 6,
                          meta: meta,
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // 또는 필요 시 true
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
}) async {
  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      int year = initialDate.year;
      final now = DateTime.now();

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("월 선택"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: year,
                    isExpanded: true,
                    items:
                        [2023, 2024, 2025]
                            .map(
                              (y) => DropdownMenuItem(
                                value: y,
                                child: Text('$y년'),
                              ),
                            )
                            .toList(),
                    onChanged: (y) {
                      if (y != null) {
                        setState(() {
                          year = y;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(12, (i) {
                      final m = i + 1;
                      final isFuture =
                          (year > now.year) ||
                          (year == now.year && m > now.month);

                      return SizedBox(
                        width: 80,
                        child: ElevatedButton(
                          onPressed:
                              isFuture
                                  ? null
                                  : () =>
                                      Navigator.pop(context, DateTime(year, m)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFuture ? Colors.grey[300] : null,
                          ),
                          child: Text(
                            '$m월',
                            style: TextStyle(
                              color: isFuture ? Colors.grey : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
