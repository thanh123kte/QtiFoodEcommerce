// lib/main.dart
import 'package:datn_foodecommerce_flutter_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';
import 'config/server_config.dart';
import 'di/injector.dart';
import 'services/notifications/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await initDependencies(baseUrl: kServerBaseUrl); 
  await GetIt.I<PushNotificationService>().init();
  runApp(const MyApp());
}
