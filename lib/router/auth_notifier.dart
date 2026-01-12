import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/datasources/local/session_local.dart';

class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth;
  final SessionLocal _sessionLocal;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthNotifier(this._auth, this._sessionLocal) {
    _init();
  }

  Future<void> _init() async {
    // Start with a safe default: not logged in until we decide.
    _isLoggedIn = false;

    final remember = _sessionLocal.getRememberMe();
    if (!remember) {
      // User opted out of remember: ensure Firebase session is cleared before listening.
      await _auth.signOut();
      _isLoggedIn = false;
      notifyListeners();
    } else {
      _isLoggedIn = _auth.currentUser != null;
      notifyListeners();
    }

    _auth.authStateChanges().listen((user) {
      final next = user != null;
      if (next != _isLoggedIn) {
        _isLoggedIn = next;
        notifyListeners(); // notify GoRouter redirect
      }
    });
  }
}
