import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart' hide Priority;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleNotificationForTask(Task task) async {
    if (task.dueDate == null || task.isDone) {
      return;
    }

    if (task.dueDate!.isBefore(DateTime.now())) {
      return;
    }

    final notificationId = task.id.hashCode;

    // DEĞİŞİKLİK BURADA: TZDateTime.from yerine TZDateTime.local kullanıyoruz.
    // Bu, saat dilimi kaynaklı çökmeleri engeller.
    final scheduledDate = tz.TZDateTime.local(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
      task.dueDate!.hour,
      task.dueDate!.minute,
    );

      await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Görevinizin Zamanı Geldi!',
      task.title,
      scheduledDate, // Güncellenmiş tarih nesnesini kullanıyoruz
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Notifications',
          channelDescription: 'Channel for task notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotificationForTask(Task task) async {
    final notificationId = task.id.hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}