import 'package:flutter_dotenv/flutter_dotenv.dart';

String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
String get supabaseKey => dotenv.env['SUPABASE_KEY']!;
String get photoBucket => dotenv.env['SUPABASE_BUCKET'] ?? 'report-photos';
