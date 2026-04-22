import 'package:production/firebase_options.dart' as prod;
final firebaseOptions = prod.DefaultFirebaseOptions.currentPlatform;

class AppConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
