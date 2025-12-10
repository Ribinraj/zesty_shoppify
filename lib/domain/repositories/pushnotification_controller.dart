

import 'dart:convert';
import 'dart:developer';



import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level background notification tap handler for flutter_local_notifications.
/// Must be a top-level or static function and annotated as entry point if used for background.
/// This will be called for "background notification responses" (action taps when app not in foreground).
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // This runs in the background isolate for notification action taps.
  // Keep it minimal (logging / lightweight work).
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

/// PushNotifications helper (singleton).
/// Usage:
/// 1) In main() register Firebase background handler:
///    FirebaseMessaging.onBackgroundMessage(PushNotifications.backgroundMessageHandler);
/// 2) Optionally register the local notifications background response handler:
///    (flutter_local_notifications will call notificationTapBackground if provided to initialize()).
/// 3) Then initialize:
///    await PushNotifications.instance.init();
class PushNotifications {
  // Singleton
  static final PushNotifications _instance = PushNotifications._internal();
  static PushNotifications get instance => _instance;
  factory PushNotifications() => _instance;
  PushNotifications._internal();

  // Firebase Messaging and local notifications plugin instances
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Android channel (idempotent to create)
  static const AndroidNotificationChannel _androidNotificationChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  /// Initialize push notifications.
  /// Call this after Firebase.initializeApp() and after registering the Firebase background handler.
  Future<void> init() async {
    try {
      // Request platform permissions
      final settings = await _requestPermissions();

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // iOS: ensure foreground presentation (so notifications are shown while app in foreground)
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // Get and store token
        await _getDeviceToken();

        // Init local notifications plugin (channels + initialize)
        await _initLocalNotifications();

        // Setup listeners for messages and taps
        _setupNotificationListeners();
      } else {
        debugPrint('Notification permission not granted: ${settings.authorizationStatus}');
      }
    } catch (e, st) {
      debugPrint('PushNotifications.init error: $e\n$st');
    }
  }

  Future<NotificationSettings> _requestPermissions() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true, // requires iOS entitlement if used
      announcement: false,
      carPlay: false,
    );
  }

  // Get and persist device FCM token, and listen to refreshes.
  Future<String?> _getDeviceToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Device Token: $token');

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('FCM_TOKEN', token);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _storeTokenLocally(newToken);
        _updateTokenIfLoggedIn(newToken);
      });

      return token;
    } catch (e) {
      debugPrint('Error fetching FCM token: $e');
      return null;
    }
  }

  Future<void> _storeTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('FCM_TOKEN', token);
  }

  Future<void> _updateTokenIfLoggedIn(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.containsKey('USER_TOKEN') &&
        prefs.getString('USER_TOKEN')?.isNotEmpty == true;

    if (isLoggedIn) {
    //  final loginRepo = Loginrepo();
      try {
       // await loginRepo.updatetoken(token: token);
      } catch (e) {
        debugPrint('Failed to update token on server: $e');
      }
    }
  }
  /// Call after user logs in to send the stored token to server
Future<void> sendTokenToServer() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('FCM_TOKEN');

  // 1️⃣ Log what we got from prefs
  log('sendservertoken (from prefs): $token');

  // 2️⃣ If FCM_TOKEN is null, fetch it from Firebase now
  if (token == null) {
    token = await FirebaseMessaging.instance.getToken();
    log('sendservertoken (fetched from Firebase): $token');

    if (token != null) {
      await prefs.setString('FCM_TOKEN', token);
      log('FCM_TOKEN saved to SharedPreferences');
    }
  }

  // 3️⃣ If still null, we can’t proceed
  if (token == null) {
    log('sendservertoken: still null, skipping server update');
    return;
  }

  // 4️⃣ Now call API to update token
  try {
    //final loginRepo = Loginrepo();
    //await loginRepo.updatetoken(token: token);
  } catch (e) {
    debugPrint('Failed to send token to server: $e');
  }
}
  // /// Call after user logs in to send the stored token to server
  // Future<void> sendTokenToServer() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('FCM_TOKEN');
  //   log('sendservertoken: $token');
  //   if (token != null) {
  //     final loginRepo = Loginrepo();
  //     try {
  //       await loginRepo.updatetoken(token: token);
  //     } catch (e) {
  //       debugPrint('Failed to send token to server: $e');
  //     }
  //   }
  // }

  /// Delete device token (logout flow). Cancels local notifications and deletes Android channel.
  Future<void> deleteDeviceToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNs token not available; skipping deleteToken.');
        } else {
          await _firebaseMessaging.deleteToken();
          debugPrint('iOS: FCM token deleted.');
        }
      } else {
        await _firebaseMessaging.deleteToken();
        debugPrint('Android: FCM token deleted.');
      }

      // Cancel local notifications and delete Android channel if present
      await _flutterLocalNotificationsPlugin.cancelAll();
      final androidImpl = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.deleteNotificationChannel(_androidNotificationChannel.id);
      }
    } catch (e) {
      debugPrint('Error deleting device token: $e');
    }
  }

  // Initialize flutter_local_notifications and create Android channel.
  Future<void> _initLocalNotifications() async {
    // Android settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Darwin (iOS/macOS) settings — do NOT include onDidReceiveLocalNotification (deprecated/old)
    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // Add notificationCategories if you need actions or text input
      // notificationCategories: <DarwinNotificationCategory>[ ... ],
    );

    // IMPORTANT: using iOS: and macOS: named params (matches current example APIs)
    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
      macOS: darwinInitializationSettings,
    );

    // Create the Android channel (idempotent)
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidNotificationChannel);

    // Initialize plugin (modern callbacks)
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  // Setup message listeners for FCM (foreground messages, taps, initial message)
  void _setupNotificationListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground FCM message received');
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User tapped notification (app opened from background)');
      _handleTerminatedStateNotification(message);
    });

    // If app was launched from terminated state via notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App launched from terminated state by notification');
        _handleTerminatedStateNotification(message);
      }
    });
  }

  // Show a local notification for foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notif = message.notification;
    if (notif != null) {
      _showLocalNotification(
        title: notif.title ?? 'Notification',
        body: notif.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _androidNotificationChannel.id,
      _androidNotificationChannel.name,
      channelDescription: _androidNotificationChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      // Add darwin: DarwinNotificationDetails(...) if you want iOS-specific details
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // id
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Modern notification tap handler (when app is in foreground or background)
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped (response.payload=${response.payload})');
    // TODO: implement navigation. Use a GlobalKey<NavigatorState> if you need to navigate here.
    // Example:
    // final payload = response.payload;
    // navigatorKey.currentState?.pushNamed('/detail', arguments: payload);
  }

  /// Firebase background message handler. Must be top-level or static. Register with:
  /// FirebaseMessaging.onBackgroundMessage(PushNotifications.backgroundMessageHandler);
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    // If you need firebase in background, ensure Firebase.initializeApp() was called in main() as needed.
    debugPrint('Handling background FCM message in PushNotifications.backgroundMessageHandler');
    try {
      // Minimal background processing e.g., log data or update a lightweight storage
      debugPrint('Background message data: ${message.data}');
    } catch (e) {
      debugPrint('Error in backgroundMessageHandler: $e');
    }
  }

  // Handle notification that opened the app from background/terminated
  void _handleTerminatedStateNotification(RemoteMessage message) {
    final notif = message.notification;
    final data = message.data;
    if (notif != null) {
      debugPrint('Notification opened app - title: ${notif.title}, body: ${notif.body}');
    }
    debugPrint('Notification opened app - data: $data');
    // TODO: route to a screen via navigatorKey if needed
  }
}
