import 'dart:convert';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import '../../firebase_options.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/notifications/register_device_token.dart';
import '../../domain/usecases/order/get_order_by_id.dart';
import '../../router/app_router.dart';
import '../../data/datasources/local/session_local.dart';

const String kDefaultNotificationChannelId = 'order_updates';
const String kDefaultNotificationChannelName = 'Order updates';
const String kDefaultNotificationChannelDescription = 'Notifications for new orders and order status changes';
const String kNotificationSound = 'notification_sound';
const String kNotificationTypeChat = 'CHAT';

const AndroidNotificationChannel kDefaultNotificationChannel = AndroidNotificationChannel(
  kDefaultNotificationChannelId,
  kDefaultNotificationChannelName,
  description: kDefaultNotificationChannelDescription,
  importance: Importance.high,
  playSound: true,
  sound: RawResourceAndroidNotificationSound(kNotificationSound),
);

final FlutterLocalNotificationsPlugin _backgroundNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await _backgroundNotifications.initialize(initializationSettings);
  await _backgroundNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(kDefaultNotificationChannel);

  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] ?? 'Order update';
  final body = notification?.body ?? message.data['body'] ?? 'You have a new order notification';

  await _backgroundNotifications.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        kDefaultNotificationChannelId,
        kDefaultNotificationChannelName,
        channelDescription: kDefaultNotificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(kNotificationSound),
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: jsonEncode(message.data),
  );
}

/// Top-level background tap handler required by flutter_local_notifications.
@pragma('vm:entry-point')
Future<void> onNotificationTapBackground(NotificationResponse response) async {
  final service = GetIt.I<PushNotificationService>();
  await service.handleNotificationResponse(response);
}

class NotificationPayload {
  final String? notificationType;
  final String? type;
  final String? orderId;
  final String? orderStatus;
  final String? role;
  final String? conversationId;
  final String? messageId;
  final String? senderId;

  NotificationPayload({
    this.notificationType,
    this.type,
    this.orderId,
    this.orderStatus,
    this.role,
    this.conversationId,
    this.messageId,
    this.senderId,
  });

  factory NotificationPayload.from(Map<String, dynamic> data) {
    return NotificationPayload(
      notificationType: data['notificationType']?.toString() ?? data['type']?.toString(),
      type: data['type']?.toString(),
      orderId: data['orderId']?.toString() ?? data['order_id']?.toString(),
      orderStatus: data['orderStatus']?.toString() ?? data['order_status']?.toString(),
      role: data['role']?.toString(),
      conversationId: data['conversationId']?.toString() ?? data['conversation_id']?.toString(),
      messageId: data['messageId']?.toString() ?? data['message_id']?.toString(),
      senderId: data['senderId']?.toString() ?? data['sender_id']?.toString(),
    );
  }

  bool get isSeller => (role ?? '').toUpperCase().contains('SELLER');
  String get normalizedType => (notificationType ?? type ?? '').toUpperCase();
  bool get isChat => normalizedType == kNotificationTypeChat;
  int? get conversationIdValue => int.tryParse(conversationId ?? '');

  // static double? _parseDouble(dynamic value) {
  //   if (value == null) return null;
  //   if (value is num) return value.toDouble();
  //   return double.tryParse(value.toString());
  // }
}

class PushNotificationService {
  PushNotificationService(
    this._messaging,
    this._auth,
    this._registerDeviceToken,
    this._sessionLocal,
    this._getOrderById,
    this._localNotifications,
  );

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final RegisterDeviceToken _registerDeviceToken;
  final SessionLocal _sessionLocal;
  final GetOrderById _getOrderById;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<User?>? _authSub;
  RemoteMessage? _pendingInitialMessage;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _configureLocalNotifications();

    await _messaging.setAutoInitEnabled(true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _requestPermission();
    _listenAuth();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
    _pendingInitialMessage = await _messaging.getInitialMessage();

    _messaging.onTokenRefresh.listen(_handleTokenRefresh);
    await _syncTokenForCachedUser();
    await _syncTokenForCurrentUser();
  }

  Future<void> handleInitialMessageIfAny() async {
    final message = _pendingInitialMessage;
    if (message == null) return;
    _pendingInitialMessage = null;
    await _handleMessageOpened(message);
  }

  Future<void> syncTokenForUser({
    required String userId,
    required String role,
    String? token,
  }) async {
    final currentToken = token ?? await _messaging.getToken();
    if (currentToken == null || currentToken.isEmpty) return;

    final platform = _platformName();
    final result = await _registerDeviceToken(
      userId: userId,
      token: currentToken,
      platform: platform,
    );

    result.when(
      ok: (_) async {
        await _sessionLocal.saveLastFcmToken(userId: userId, token: currentToken);
        await _sessionLocal.saveLastUser(userId: userId, role: role);
      },
      err: (message) {
        if (kDebugMode) {
          debugPrint('[PushNotificationService] register token failed: $message');
        }
      },
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showLocalNotification(message);
  }

  Future<void> _handleMessageOpened(RemoteMessage message) async {
    await _navigateFromPayload(NotificationPayload.from(message.data));
  }

  Future<void> handleNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        await _navigateFromPayload(NotificationPayload.from(data));
      }
    } catch (_) {}
  }

  Future<void> _navigateFromPayload(NotificationPayload payload) async {
    final isSeller = payload.isSeller ||
        ((_sessionLocal.getLastUserRole() ?? '').toUpperCase().contains('SELLER'));

    if (payload.isChat) {
      final conversationId = payload.conversationIdValue;
      if (conversationId == null) {
        if (isSeller) {
          final sellerId = _auth.currentUser?.uid ?? _sessionLocal.getLastUserId() ?? '';
          if (sellerId.isNotEmpty) {
            appRouter.go('/seller/home');
            await appRouter.push('/seller/messenger/$sellerId');
            return;
          }
        }
        appRouter.go('/mainscreen');
        await appRouter.push('/messenger');
        return;
      }

      if (isSeller) {
        appRouter.go('/seller/home');
        await appRouter.push(
          '/seller/chat',
          extra: {
            'conversationId': conversationId,
          },
        );
      } else {
        appRouter.go('/mainscreen');
        final sellerId = payload.senderId ?? '';
        if (sellerId.isNotEmpty) {
          await appRouter.push(
            '/messenger/chat',
            extra: {
              'sellerId': sellerId,
              'conversationId': conversationId,
            },
          );
        } else {
          await appRouter.push('/messenger');
        }
      }
      return;
    }

    Order? order;
    final orderId = payload.orderId;
    if (orderId != null && orderId.isNotEmpty) {
      final orderIdInt = int.tryParse(orderId);
      final result = orderIdInt != null ? await _getOrderById(orderIdInt) : null;
      result?.when(ok: (value) => order = value, err: (_) {});
    }

    if (orderId != null && orderId.isNotEmpty) {
      if (isSeller) {
        appRouter.go('/seller/home');
        await appRouter.push('/seller/orders/$orderId');
      } else {
        appRouter.go('/mainscreen');
        await appRouter.push('/orders/$orderId', extra: order);
      }
      return;
    }

    // Default: route to wallet for payment-related notifications.
    final type = payload.normalizedType;
    if (type == 'TOPUP' || type == 'REFUND' || type == 'REVENUE') {
      if (isSeller) {
        appRouter.go('/seller/wallet');
      } else {
        appRouter.go('/wallet');
      }
      return;
    }

    appRouter.go('/mainscreen');
  }

  Future<void> _configureLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onNotificationTapBackground,
    );

    final android = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(kDefaultNotificationChannel);
    }
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint('[PushNotificationService] permission status: ${settings.authorizationStatus}');
    }
  }

  Future<void> _syncTokenForCachedUser() async {
    final userId = _sessionLocal.getLastUserId();
    final role = _sessionLocal.getLastUserRole();
    if (userId == null || role == null) return;
    await syncTokenForUser(userId: userId, role: role);
  }

  Future<void> _syncTokenForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final role = _sessionLocal.getLastUserRole() ?? 'CUSTOMER';
    await syncTokenForUser(userId: user.uid, role: role);
  }

  void _listenAuth() {
    _authSub?.cancel();
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        final role = _sessionLocal.getLastUserRole() ?? 'CUSTOMER';
        syncTokenForUser(userId: user.uid, role: role);
      }
    });
  }

  Future<void> _handleTokenRefresh(String token) async {
    final userId = _sessionLocal.getLastUserId();
    final role = _sessionLocal.getLastUserRole();
    if (userId == null || role == null) return;
    await syncTokenForUser(userId: userId, role: role, token: token);
  }

  String _platformName() {
    if (kIsWeb) return 'WEB';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'IOS';
      case TargetPlatform.android:
        return 'ANDROID';
      default:
        return describeEnum(defaultTargetPlatform).toUpperCase();
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'Order update';
    final body = notification?.body ?? message.data['body'] ?? 'You have a new order notification';

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          kDefaultNotificationChannelId,
          kDefaultNotificationChannelName,
          channelDescription: kDefaultNotificationChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
