import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialization timezone
  await _configureLocalTimeZone();

  //android settings
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('appicon');

  // ios settings
  const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  // initialization
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // create local notification
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();

    _scheduleNotification();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _showNotification();
                        },
                        child: const Text("Показать уведомление"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _scheduleNotification();
                        },
                        child: const Text("Запланированное уведомление"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: ElevatedButton(
                        onPressed: () async {
                          await _cancelAllNotifications();
                        },
                        child: const Text("Отменить все уведомления"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  // простое уведомление по кнопке
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('ID', 'Название уведомления',
            channelDescription: 'Контент уведомления',
            importance: Importance.max, //Importance.high,
            priority: Priority.high);
    const IOSNotificationDetails iosDetails = IOSNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosDetails);
    await flutterLocalNotificationsPlugin.show(
        0,
        "Уведомление",
        "Простое уведомление", platformChannelSpecifics);
  }

  // ежедневное напоминание в заданное время
  Future<void> _scheduleNotification() async {
    // задаем время напоминания в 24х-часовом формате
    int hour = 15;
    int minutes = 35;

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Ежедневное напоминание',
        'Выделить полчаса на занятия программированием',
        _nextInstanceOfTenAM(hour, minutes),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTenAM(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  //отменить все напоминания
  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

}
