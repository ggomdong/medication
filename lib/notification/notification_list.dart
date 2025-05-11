import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notification/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationList extends ConsumerWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationService = ref.watch(notificationServiceProvider);

    return FutureBuilder<List<PendingNotificationRequest>>(
      future: notificationService.pendingNotificationRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text("예약된 알림이 없습니다."));
        }

        return ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final req = requests[index];
            final payload = req.payload ?? "";
            final parts = payload.split('|');

            final diagnosis = parts.isNotEmpty ? parts[0] : "-";
            // final prescriptionId = parts.length > 1 ? parts[1] : "-";
            final scheduledTime =
                parts.length > 2 ? DateTime.tryParse(parts[2]) : null;

            return ListTile(
              leading: const Icon(Icons.notifications_active),
              title: Text(diagnosis),
              // subtitle: Text("처방전 ID: $prescriptionId"),
              trailing:
                  scheduledTime != null
                      ? Text(
                        DateFormat(
                          'yyyy년 MM월 dd일 HH:mm',
                        ).format(scheduledTime.toLocal()),
                      )
                      : const Text("-"),
            );
          },
        );
      },
    );
  }
}
