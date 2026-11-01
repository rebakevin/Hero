import 'package:flutter_dotenv/flutter_dotenv.dart';

String get supabaseUrl => _required('SUPABASE_URL');
String get supabaseKey => _required('SUPABASE_KEY');
String get photoBucket => dotenv.env['SUPABASE_BUCKET'] ?? 'report-photos';

String _required(String key) {
  final value = dotenv.env[key];
  if (value == null || value.isEmpty) {
    throw StateError(
      'Missing $key in .env. Copy .env.example to .env and fill it in.',
    );
  }
  return value;
}
