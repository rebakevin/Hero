import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/account_sessions.dart';
import '../domain/device_account.dart';

/// One slot per named [FirebaseApp]: each app persists its own Auth session and
/// Firestore cache, so switching needs no stored password.
class FirebaseAccountSessions implements AccountSessions {
  FirebaseAccountSessions({
    required List<FirebaseApp> apps,
    required SharedPreferences preferences,
  }) : _apps = apps,
       _preferences = preferences,
       _activeSlot = _restoreSlot(apps, preferences) {
    for (final app in apps) {
      _authOf(app)
          .authStateChanges()
          .listen((user) => _signOutDuplicates(app, user));
    }
  }

  static const _activeSlotKey = 'activeAccountSlot';

  final List<FirebaseApp> _apps;
  final SharedPreferences _preferences;
  final _changes = StreamController<String>.broadcast();
  String _activeSlot;

  static String _restoreSlot(
    List<FirebaseApp> apps,
    SharedPreferences preferences,
  ) {
    final saved = preferences.getString(_activeSlotKey);
    return apps.any((app) => app.name == saved) ? saved! : apps.first.name;
  }

  @override
  String get activeSlot => _activeSlot;

  @override
  Stream<String> activeSlotChanges() => _changes.stream;

  @override
  Future<List<DeviceAccount>> accounts() async => [
    for (final app in _apps)
      if (_authOf(app).currentUser case final user?)
        DeviceAccount(
          slot: app.name,
          email: (user.email ?? '').toLowerCase(),
          displayName: await _displayNameOf(app, user),
          isActive: app.name == _activeSlot,
        ),
  ];

  @override
  bool get canAddAccount =>
      _isOccupied(_activeSlot) && _apps.any((app) => !_isOccupied(app.name));

  @override
  Future<void> switchTo(String slot) => _activate(slot);

  @override
  Future<void> addAccount() async {
    if (!canAddAccount) return;
    final empty = _apps.firstWhere((app) => !_isOccupied(app.name));
    await _activate(empty.name);
  }

  Future<void> _activate(String slot) async {
    if (slot == _activeSlot) return;
    await _preferences.setString(_activeSlotKey, slot);
    _activeSlot = slot;
    _changes.add(slot);
  }

  FirebaseAuth _authOf(FirebaseApp app) => FirebaseAuth.instanceFor(app: app);

  bool _isOccupied(String slot) =>
      _apps.any((app) => app.name == slot && _authOf(app).currentUser != null);

  /// Logging in to an account already held by another slot moves it here.
  void _signOutDuplicates(FirebaseApp signedIn, User? user) {
    if (user == null || signedIn.name != _activeSlot) return;
    for (final app in _apps) {
      final auth = _authOf(app);
      if (app.name != signedIn.name && auth.currentUser?.uid == user.uid) {
        unawaited(auth.signOut());
      }
    }
  }

  /// The profile name is the current one, since a rename only updates Firestore.
  /// It is read from the cache so the list opens instantly and works offline.
  Future<String?> _displayNameOf(FirebaseApp app, User user) async {
    try {
      final profile = await FirebaseFirestore.instanceFor(app: app)
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.cache));
      final name = profile.data()?['displayName'];
      if (name is String) return name;
    } on FirebaseException {
      // Not cached yet, for example an account still waiting for verification.
    }
    return user.displayName;
  }
}
