import 'dart:convert';

import 'package:ba_technology/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage: $message");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onMessageOpenedApp: $message");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("Handling a background message: ${message.messageId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Get.to(() => const LoginScreen());
            },
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Dashboard!',
              style: TextStyle(fontSize: 24),
            ),
            const Text(
              'Click the button for Push Notification',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String? token = await _firebaseMessaging.getToken();
                sendNotification(msgTitle: 'Firebase', userToken: token!);
              },
              child: const Text('Press Me'),
            ),
          ],
        ),
      ),
    );
  }

  /// Notification API process
  Future<void> sendNotification({required String msgTitle, required String userToken}) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': msgTitle,
    };
    try {
      http.Response response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'Key=AAAAbTWhPms:APA91bFh3XS6F8fRsaJP1GaUK_36ORHYw6rZUK1L-yhplQi1JYDAz4OeimgPq4G1EjrntnTQv0Y7s6J246N3vPtVb6AOL2R3gGf4t8Mqe31fnGEYyY2lfYGc9mkj3O91NGc7ucv2bflP'
          },
          body: jsonEncode(<String, dynamic>{
            'notification': <String, dynamic>{'title': msgTitle, 'body': 'Push Notification Generated'},
            'priority': 'high',
            'data': data,
            'to': userToken,
          }));

      if (response.statusCode == 200) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          /* if (message.notification != null) {
            debugPrint('Notification title: ${message.notification!.title}');
            debugPrint('Notification body: ${message.notification!.body}');
          }*/
          if (message.data.isNotEmpty) {
            debugPrint('Data payload: ${message.data}');
            showNotification(message);
          }
        });
      } else {}
    } catch (e) {
      debugPrint('error : ${e.toString()}');
    }
  }

  /// Display notification
  Future<void> showNotification(RemoteMessage message) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
