import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');

  const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

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

class PaddedElevatedButton extends StatelessWidget {
  const PaddedElevatedButton({
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      );
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
                    PaddedElevatedButton(
                      buttonText: 'Show plain notification with payload',
                      onPressed: () async {
                        await _showNotification();
                      },
                    ),

                    PaddedElevatedButton(
                      buttonText: 'Schedule notification to appear in 5 seconds '
                          'based on local time zone',
                      onPressed: () async {
                        await _zonedScheduleNotification();
                      },
                    ),

                    PaddedElevatedButton(
                      buttonText: 'Schedule daily 10:00:00 am notification in your '
                          'local time zone',
                      onPressed: () async {
                        await _scheduleDailyTenAMNotification();
                      },
                    ),

                    PaddedElevatedButton(
                      buttonText: 'Check pending notifications',
                      onPressed: () async {
                        await _checkPendingNotificationRequests();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Cancel notification',
                      onPressed: () async {
                        await _cancelNotification();
                      },
                    ),
                    PaddedElevatedButton(
                      buttonText: 'Cancel all notifications',
                      onPressed: () async {
                        await _cancelAllNotifications();
                      },
                    ),

                    // PaddedElevatedButton(
                    //   buttonText:
                    //   'Show notification that times out after 3 seconds',
                    //   onPressed: () async {
                    //     await _showTimeoutNotification();
                    //   },
                    // ),
                    // PaddedElevatedButton(
                    //   buttonText: 'Show grouped notifications',
                    //   onPressed: () async {
                    //     await _showGroupedNotifications();
                    //   },
                    // ),
                    // PaddedElevatedButton(
                    //   buttonText:
                    //   'Show progress notification - updates every second',
                    //   onPressed: () async {
                    //     await _showProgressNotification();
                    //   },
                    // ),
                    // PaddedElevatedButton(
                    //   buttonText: 'Show indeterminate progress notification',
                    //   onPressed: () async {
                    //     await _showIndeterminateProgressNotification();
                    //   },
                    // ),
                    // PaddedElevatedButton(
                    //   buttonText: 'Show full-screen notification',
                    //   onPressed: () async {
                    //     await _showFullScreenNotification();
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('ID', 'Название уведомления',
            channelDescription: 'Контент уведомления',
            importance: Importance.max, //Importance.high,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, "Привет", "Привет, мир!", platformChannelSpecifics);
  }

  Future<void> _showFullScreenNotification() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Turn off your screen'),
        content: const Text('to see the full-screen intent in 5 seconds, press OK and TURN '
            'OFF your screen'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await flutterLocalNotificationsPlugin.zonedSchedule(
                  0,
                  'scheduled title',
                  'scheduled body',
                  tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
                  const NotificationDetails(
                      android: AndroidNotificationDetails('full screen channel id', 'full screen channel name',
                          channelDescription: 'full screen channel description',
                          priority: Priority.high,
                          importance: Importance.high,
                          fullScreenIntent: true)),
                  androidAllowWhileIdle: true,
                  uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);

              Navigator.pop(context);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> _zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _showTimeoutNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'silent channel id', 'silent channel name',
        channelDescription: 'silent channel description',
        timeoutAfter: 3000,
        styleInformation: DefaultStyleInformation(true, true));
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'timeout notification', 'Times out after 3 seconds', platformChannelSpecifics);
  }

  Future<void> _showGroupedNotifications() async {
    const String groupKey = 'com.android.example.WORK_EMAIL';
    const String groupChannelId = 'grouped channel id';
    const String groupChannelName = 'grouped channel name';
    const String groupChannelDescription = 'grouped channel description';
    // example based on https://developer.android.com/training/notify-user/group.html
    const AndroidNotificationDetails firstNotificationAndroidSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName,
        channelDescription: groupChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        groupKey: groupKey);
    const NotificationDetails firstNotificationPlatformSpecifics =
        NotificationDetails(android: firstNotificationAndroidSpecifics);
    await flutterLocalNotificationsPlugin.show(
        1, 'Alex Faarborg', 'You will not believe...', firstNotificationPlatformSpecifics);
    const AndroidNotificationDetails secondNotificationAndroidSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName,
        channelDescription: groupChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        groupKey: groupKey);
    const NotificationDetails secondNotificationPlatformSpecifics =
        NotificationDetails(android: secondNotificationAndroidSpecifics);
    await flutterLocalNotificationsPlugin.show(
        2, 'Jeff Chang', 'Please join us to celebrate the...', secondNotificationPlatformSpecifics);

    // Create the summary notification to support older devices that pre-date
    /// Android 7.0 (API level 24).
    ///
    /// Recommended to create this regardless as the behaviour may vary as
    /// mentioned in https://developer.android.com/training/notify-user/group
    const List<String> lines = <String>['Alex Faarborg  Check this out', 'Jeff Chang    Launch Party'];
    const InboxStyleInformation inboxStyleInformation =
        InboxStyleInformation(lines, contentTitle: '2 messages', summaryText: 'janedoe@example.com');
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName,
        channelDescription: groupChannelDescription,
        styleInformation: inboxStyleInformation,
        groupKey: groupKey,
        setAsGroupSummary: true);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(3, 'Attention', 'Two messages', platformChannelSpecifics);
  }

  Future<void> _checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text('${pendingNotificationRequests.length} pending notification '
            'requests'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _scheduleDailyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'daily scheduled notification title',
        'daily scheduled notification body',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id', 'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  //
  // tz.TZDateTime _nextInstanceOfTenAMLastYear() {
  //   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  //   return tz.TZDateTime(tz.local, now.year - 1, now.month, now.day, 10);
  // }
  //
  // tz.TZDateTime _nextInstanceOfMondayTenAM() {
  //   tz.TZDateTime scheduledDate = _nextInstanceOfTenAM();
  //   while (scheduledDate.weekday != DateTime.monday) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 1));
  //   }
  //   return scheduledDate;
  // }

  Future<void> _showProgressNotification() async {
    const int maxProgress = 5;
    for (int i = 0; i <= maxProgress; i++) {
      await Future<void>.delayed(const Duration(seconds: 1), () async {
        final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'progress channel', 'progress channel',
            channelDescription: 'progress channel description',
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.high,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: i);
        final NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0, 'progress notification title', 'progress notification body', platformChannelSpecifics);
      });
    }
  }

  Future<void> _showIndeterminateProgressNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'indeterminate progress channel', 'indeterminate progress channel',
        channelDescription: 'indeterminate progress channel description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        indeterminate: true);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'indeterminate progress notification title',
        'indeterminate progress notification body', platformChannelSpecifics);
  }
}
