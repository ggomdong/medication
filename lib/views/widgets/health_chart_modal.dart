import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medication/constants/gaps.dart';

class HealthChartModal extends StatefulWidget {
  const HealthChartModal({super.key});

  @override
  State<HealthChartModal> createState() => _HealthChartModalState();
}

class _HealthChartModalState extends State<HealthChartModal> {
  bool isDaily = true;
  DateTime selectedDate = DateTime.now();

  void _selectDate() async {
    if (isDaily) {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023),
        lastDate: DateTime.now(),
      );
      if (picked != null) setState(() => selectedDate = picked);
    } else {
      final picked = await showMonthPicker(
        context: context,
        initialDate: selectedDate,
      );
      if (picked != null) setState(() => selectedDate = picked);
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
            TextButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                isDaily
                    ? "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일"
                    : "${selectedDate.year}년 ${selectedDate.month}월",
              ),
            ),
            Gaps.v16,
            Expanded(child: _BloodPressureChart(isDaily: isDaily)),
            Gaps.v24,
            Expanded(child: _WeightChart(isDaily: isDaily)),
          ],
        ),
      ),
    );
  }
}

class _BloodPressureChart extends StatelessWidget {
  final bool isDaily;

  const _BloodPressureChart({required this.isDaily});

  @override
  Widget build(BuildContext context) {
    final random = Random();

    double generateInRange(double min, double max) {
      return min + random.nextDouble() * (max - min);
    }

    // 수축기
    final systolicSpots =
        isDaily
            ? List.generate(31, (i) {
              double y = generateInRange(110, 130);
              return FlSpot(i.toDouble(), y);
            })
            : List.generate(12, (i) {
              double y = generateInRange(110, 130);
              return FlSpot(i.toDouble(), y);
            });

    // 이완기
    final diastolicSpots =
        isDaily
            ? List.generate(31, (i) {
              double y = generateInRange(70, 85);
              return FlSpot(i.toDouble(), y);
            })
            : List.generate(12, (i) {
              double y = generateInRange(70, 85);
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
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
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

  const _WeightChart({required this.isDaily});

  @override
  Widget build(BuildContext context) {
    final random = Random();

    double generateInRange(double min, double max) {
      return min + random.nextDouble() * (max - min);
    }

    final spots =
        isDaily
            ? List.generate(31, (i) {
              double y = generateInRange(64, 66); // 몸무게
              return FlSpot(i.toDouble(), y);
            })
            : List.generate(12, (i) {
              double y = generateInRange(64, 66); // 몸무게
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
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  dotData: FlDotData(show: false),
                  color: Colors.green,
                ),
              ],
              titlesData: FlTitlesData(
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
  DateTime selected = initialDate;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      int year = selected.year;
      int month = selected.month;

      return AlertDialog(
        title: const Text("월 선택"),
        content: SizedBox(
          height: 250,
          child: Column(
            children: [
              DropdownButton<int>(
                value: year,
                items:
                    [2023, 2024, 2025]
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text('$y년')),
                        )
                        .toList(),
                onChanged:
                    (y) => y != null ? selected = DateTime(y, month) : null,
              ),
              Wrap(
                children: List.generate(12, (i) {
                  final m = i + 1;
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.pop(context, DateTime(year, m)),
                      child: Text('$m월'),
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
}
