import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// Arka plan bildirim dinleyicisi (En üst seviyede olmalıdır)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Arka planda bildirim geldiğinde yapılacak ek işlemler buraya gelebilir
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Android 13+ bildirim izni iste
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Arka plan dinleyicisini kaydet
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // FCM Token (İsteğe bağlı - Backend için)
      if (kDebugMode) {
        final token = await messaging.getToken();
        print('FCM Token: $token');
      }

      // Yerel bildirim ayarları
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Bildirime tıklandığında yapılacaklar buraya eklenebilir
        },
      );

      // Ön plandayken bildirim geldiğinde gösterim
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          showLocalNotification(
            title: message.notification!.title ?? '',
            body: message.notification!.body ?? '',
          );
        }
      });
    } catch (e) {
      debugPrint('NotificationService init hatası: $e');
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'norodakika_channel',
      'NöroDakika Bildirimleri',
      channelDescription: 'Bu kanal uygulama bildirimleri için kullanılır.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
