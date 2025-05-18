import 'package:flutter/material.dart';
import 'dart:math';
import 'package:faker/faker.dart';
import '../../constants/gaps.dart';

class PointRankingTab extends StatelessWidget {
  const PointRankingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final myPoints = 870;
    final myRank = 1000 ~/ 10 - myPoints ~/ 10 + 1;
    final myWeeklyGain = 120;

    final achievements = [
      {"title": "7일 연속 복약", "icon": Icons.calendar_today, "unlocked": true},
      {"title": "1000 🅟 돌파!", "icon": Icons.bolt, "unlocked": false},
      {"title": "3개 약 동시 복용", "icon": Icons.medication, "unlocked": true},
      {"title": "아침/저녁 모두 복약", "icon": Icons.sunny, "unlocked": true},
      {"title": "한 달간 복약 유지", "icon": Icons.date_range, "unlocked": false},
      {"title": "포인트 사용 첫 기록", "icon": Icons.shopping_cart, "unlocked": false},
    ];

    return Column(
      children: [
        // 🎖 내 랭킹 카드
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.amber.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/avatar.png"),
                    radius: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "LV.12",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
              Gaps.h16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "나의 랭킹: $myRank위",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v4,
                    TweenAnimationBuilder<int>(
                      duration: const Duration(seconds: 1),
                      tween: IntTween(begin: 0, end: myPoints),
                      builder: (context, value, child) {
                        final progressWidth =
                            (value % 1000) /
                            1000 *
                            MediaQuery.of(context).size.width *
                            0.6;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 6,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Container(
                                  height: 6,
                                  width: progressWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v4,
                            Text(
                              "$value 🅟 / 1000 🅟",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                    Gaps.v4,
                    Text(
                      "+$myWeeklyGain 🅟 (이번 주 증가량)",
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 🏅 업적 시스템
        Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🏅 업적 달성 현황",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Gaps.v8,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      achievements.map((ach) {
                        final unlocked = ach["unlocked"] as bool;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  unlocked
                                      ? Colors.orange
                                      : Colors.grey.shade300,
                              child: Icon(
                                ach["icon"] as IconData,
                                color: unlocked ? Colors.white : Colors.grey,
                              ),
                            ),
                            Gaps.v4,
                            SizedBox(
                              width: 90,
                              child: Text(
                                ach["title"] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: unlocked ? Colors.black : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // 🏆 전체 랭킹 리스트
        Expanded(
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              final faker = Faker();
              final rank = index + 1;
              final isTop3 = rank <= 3;
              final isMe = rank == myRank;
              final randomPoints =
                  isMe ? myPoints : 1000 - rank * 10 + Random().nextInt(5);
              final weeklyGain = Random().nextInt(50) + 10;

              IconData? medalIcon;
              MaterialColor? medalColor;
              if (rank == 1) {
                medalIcon = Icons.emoji_events;
                medalColor = Colors.amber;
              } else if (rank == 2) {
                medalIcon = Icons.emoji_events;
                medalColor = Colors.grey;
              } else if (rank == 3) {
                medalIcon = Icons.emoji_events;
                medalColor = Colors.brown;
              }

              return AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 300 + index * 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue.shade50 : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading:
                        isTop3
                            ? Icon(medalIcon, color: medalColor, size: 28)
                            : CircleAvatar(
                              backgroundColor:
                                  isMe ? Colors.blue : Colors.grey.shade300,
                              child: Text(
                                "$rank",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    title: Row(
                      children: [
                        Text(
                          isMe ? "나 (You)" : faker.internet.userName(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                isMe ? FontWeight.bold : FontWeight.normal,
                            color: isMe ? Colors.blue : null,
                          ),
                        ),
                        if (rank == 1)
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 16,
                          ),
                      ],
                    ),
                    subtitle: Text(
                      "이번 주 +$weeklyGain 🅟",
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                    trailing: Text(
                      "🅟 $randomPoints",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
