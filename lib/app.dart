// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'router/app_router.dart';
import 'services/notifications/push_notification_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _handledInitialMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledInitialMessage) return;
    _handledInitialMessage = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetIt.I<PushNotificationService>().handleInitialMessageIfAny();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'QTI Food',
      theme: ThemeData(useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}
