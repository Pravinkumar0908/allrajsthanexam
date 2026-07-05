import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyA1StpRbv2qCmOzEczG5KPBXtXLb1Nhgb8",
          authDomain: "rajexamshubs.firebaseapp.com",
          projectId: "rajexamshubs",
          storageBucket: "rajexamshubs.firebasestorage.app",
          messagingSenderId: "990183339662",
          appId: "1:990183339662:web:0db8ddb890059a3d773bdf",
          measurementId: "G-3QB4D0ZH9Q",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(const RevisionApp());
}

class RevisionApp extends StatelessWidget {
  const RevisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revision - MCQ Mock Test',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
