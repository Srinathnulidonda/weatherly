import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationManager {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  static Future<void> scheduleWeatherAlert(Map<String, dynamic> weatherData) async {
    final weather = weatherData['weather']['main'].toLowerCase();
    
    if (_shouldAlert(weather)) {
      await _showWeatherAlert(weatherData);
    }
  }

  static bool _shouldAlert(String weather) {
    final alertConditions = [
      'thunderstorm',
      'snow',
      'fog',
      'mist',
    ];
    
    return alertConditions.any((condition) => weather.contains(condition));
  }

  static Future<void> _showWeatherAlert(Map<String, dynamic> weatherData) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_alerts',
      'Weather Alerts',
      channelDescription: 'Severe weather notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF3B82F6),
      ledColor: Color(0xFF3B82F6),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final weather = weatherData['weather'];
    final city = weatherData['city'];
    final title = 'Weather Alert: ${weather['main']}';
    final body = '${weather['description']} in $city. Stay safe!';

    await _notifications.show(
      0,
      title,
      body,
      details,
    );
  }

  static Future<void> scheduleDailyForecast() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_forecast',
      'Daily Forecast',
      channelDescription: 'Daily weather summary',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF3B82F6),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      1,
      'Good Morning!',
      'Check today\'s weather forecast',
      _nextInstanceOfTime(8, 0), // 8:00 AM
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens or perform actions here
  }
}