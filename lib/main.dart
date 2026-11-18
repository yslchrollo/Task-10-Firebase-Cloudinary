
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/auth/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('FIREBASE INITIALIZED SUCCESSFULLY');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('FIREBASE INITIALIZATION ERROR: $e');
    debugPrint('$stackTrace');

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Firebase initialization failed:\n$e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: false,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            );
          }

          final user = snapshot.data;

          if (user != null) {
            final isGoogleUser = user.providerData
                .any((p) => p.providerId == 'google.com');

            if (user.emailVerified || isGoogleUser) {
              return const HomePage();
            }
          }

          return const LoginPage();
        },
      ),
    );
  }
}
