import 'package:flutter/material.dart';

class PointSpendingTab extends StatefulWidget {
  const PointSpendingTab({super.key});

  @override
  State<PointSpendingTab> createState() => PointSpendingTabState();
}

class PointSpendingTabState extends State<PointSpendingTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder:
          (context, index) => ListTile(
            leading: const Icon(Icons.remove_circle, color: Colors.red),
            title: const Text("건강보조식품 구매"),
            subtitle: const Text("2025-05-12 15:00"),
            trailing: const Text("-300점", style: TextStyle(color: Colors.red)),
          ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
