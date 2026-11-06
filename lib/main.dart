import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env.dart';
import 'features/auth/auth.dart';
import 'features/notifications/notifications.dart';
import 'features/reports/reports.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final options = DefaultFirebaseOptions.currentPlatform;
  // The default app stays the first slot, so an existing session survives.
  final apps = [
    await Firebase.initializeApp(options: options),
    for (var slot = 1; slot < DeviceAccount.maxPerDevice; slot++)
      await Firebase.initializeApp(name: 'account$slot', options: options),
  ];
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  final photoStorage = SupabasePhotoStorage(
    client: Supabase.instance.client,
    bucket: photoBucket,
  );
  final accountSessions = FirebaseAccountSessions(
    apps: apps,
    preferences: await SharedPreferences.getInstance(),
  );
  runApp(
    HeroRoot(
      accountSessions: accountSessions,
      appForSlot: (slot) {
        final app = apps.firstWhere((app) => app.name == slot);
        final firestore = FirebaseFirestore.instanceFor(app: app);
        return HeroApp(
          accountSessions: accountSessions,
          authRepository: FirebaseAuthRepository(
            FirebaseAuth.instanceFor(app: app),
          ),
          userRepository: FirestoreUserRepository(firestore),
          reportRepository: FirestoreReportRepository(
            firestore: firestore,
            photos: photoStorage,
          ),
          voteRepository: FirestoreVoteRepository(firestore),
          notificationRepository: FirestoreNotificationRepository(firestore),
          photoUrls: photoStorage,
          photoPicker: DevicePhotoPicker(ImagePicker()),
        );
      },
    ),
  );
}
