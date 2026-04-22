import 'package:common_packages/di/injection.dart';
import 'package:common_packages/the_king_app.dart';
import 'package:development/config/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: firebaseOptions);
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  await init();
  runApp(const TheKingApp());
}
