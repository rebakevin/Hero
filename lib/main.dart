import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env.dart';
import 'features/auth/auth.dart';
import 'features/reports/reports.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  final photoStorage = SupabasePhotoStorage(
    client: Supabase.instance.client,
    bucket: photoBucket,
  );
  runApp(
    HeroApp(
      authRepository: FirebaseAuthRepository(FirebaseAuth.instance),
      userRepository: FirestoreUserRepository(FirebaseFirestore.instance),
      reportRepository: FirestoreReportRepository(
        firestore: FirebaseFirestore.instance,
        photos: photoStorage,
      ),
      photoUrls: photoStorage,
      photoPicker: DevicePhotoPicker(ImagePicker()),
    ),
  );
}
