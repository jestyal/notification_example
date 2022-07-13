import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Notification Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text("Notifications"), centerTitle: true),
        body: const NotificationApp(),
      ),
    );
  }
}


class NotificationApp extends StatefulWidget {
  const NotificationApp({ Key? key }) : super(key: key);

  @override
  _NotificationAppState createState() => _NotificationAppState();
}

class _NotificationAppState extends State<NotificationApp> {

  late FlutterLocalNotificationsPlugin localNotifications;

  @override
  void initState() {
    super.initState();
    //объект для Android настроек
    var androidInitialize = const AndroidInitializationSettings('ic_launcher');
    //объект для IOS настроек
    var IOSInitialize = const IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,);
    // общая инициализация
    var initializationSettings = InitializationSettings(
        android: androidInitialize, iOS: IOSInitialize);

    //мы создаем локальное уведомление
    localNotifications = FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initializationSettings);
  }

  Future _showNotification() async {
    var androidDetails = const AndroidNotificationDetails(
      "ID",
      "Название уведомления",
      importance: Importance.high,
      channelDescription: "Контент уведомления",
    );

    var iosDetails = const IOSNotificationDetails();
    var generalNotificationDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotifications.show(
        0, "Название", "Тело уведомления", generalNotificationDetails);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: const Center(
        child: Text('Нажми на кнопку, чтобы получить уведомление'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNotification,
        child: const Icon(Icons.notifications),
      ),

    );
  }
}
