import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationUtils {
  NotificationUtils._();

  static final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel
  _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description:
    'This channel is used for important notifications.',
    importance: Importance.max,
  );

  /// INIT
  static Future<void> init() async {
    /// Android
    const androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    /// iOS
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {
        debugPrint(
          "Notification payload: ${response.payload}",
        );
      }, settings: settings,
    );

    /// Create Android Channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    /// Foreground Notification
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        showNotification(message);
      },
    );

    /// Click when app in background
    FirebaseMessaging.onMessageOpenedApp.listen(
          (RemoteMessage message) {
        debugPrint(
          "Notification clicked: ${message.data}",
        );
      },
    );

    /// Background Handler
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    /// iOS permission
    await FirebaseMessaging.instance
        .requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    /// Get token
    final token =
    await FirebaseMessaging.instance.getToken();

    debugPrint("FCM TOKEN => $token");
  }


  static Future<String?>  getFCmToken() async{
    try {
      String? fcmToken =  await FirebaseMessaging.instance.getToken();
      return fcmToken;
    } on Exception catch (e) {
      // TODO
      return "";
    }
  }

  /// SHOW LOCAL NOTIFICATION
  static Future<void> showNotification(
      RemoteMessage message,
      ) async {
    final notification = message.notification;

    if (notification == null) return;

    await _localNotifications.show(
      id: 100,
      title:notification.title,
      body:notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription:
          _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

/// BACKGROUND HANDLER
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  debugPrint(
    "Background Message: ${message.messageId}",
  );

  await NotificationUtils.showNotification(
    message,
  );
}