import 'package:permission_handler/permission_handler.dart';

Future<bool> requestNotificationPermission() async {
  final status = await Permission.notification.status;

  if (status.isDenied || status.isPermanentlyDenied) {
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  return status.isGranted;
}
