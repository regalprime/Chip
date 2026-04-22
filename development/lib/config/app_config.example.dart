import 'package:development/firebase_options.dart' as dev;
final firebaseOptions = dev.DefaultFirebaseOptions.currentPlatform;

class AppConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
