import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthStatsScreen extends StatelessWidget {
  const HealthStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('건강 통계')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '혈압 추이',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 120),
                        FlSpot(1, 130),
                        FlSpot(2, 125),
                        FlSpot(3, 140),
                      ],
                      isCurved: true,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 80),
                        FlSpot(1, 85),
                        FlSpot(2, 82),
                        FlSpot(3, 90),
                      ],
                      isCurved: true,
                      dotData: FlDotData(show: false),
                      color: Colors.blueGrey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '몸무게 추이',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 64),
                        FlSpot(1, 65),
                        FlSpot(2, 64.5),
                        FlSpot(3, 66),
                      ],
                      isCurved: true,
                      dotData: FlDotData(show: false),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
