import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:orphansafe_management_app/main.dart';
import 'package:orphansafe_management_app/web_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

void handleMessage(RemoteMessage? message) {
  if (message == null) return;

  navigatorKey.currentState?.pushNamed(WebViewPage.route, arguments: message);
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel('high_importance_channel', 'High Importance Notifications',
      description: 'This channel is used for important notifications', importance: Importance.defaultImportance);

  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _localNotifications.initialize(settings, onDidReceiveNotificationResponse: (response) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      handleMessage(message);
    });

    final platform =
        _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(_androidChannel.id, _androidChannel.name,
                channelDescription: _androidChannel.description, icon: '@drawable/ic_launcher'),
          ),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('FCMToken', fCMToken!);
    // print('token: $fCMToken END');
    // patch token with server
    // await NotificationServiceApi.patchTokenWithServer(fCMToken);
    initPushNotifications();
    initLocalNotifications();
  }
}
