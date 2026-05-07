import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/bk_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BKAdminApp());
}

class BKAdminApp extends StatelessWidget {
  const BKAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BK Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: BKTheme.theme,
      home: StreamBuilder(
        stream: FirebaseService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _SplashScreen();
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

/// Pantalla de carga mientras Firebase verifica el estado de auth
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BKColors.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFE000), Color(0xFFF5A623)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: BKColors.yellow.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'BK',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: BKColors.red,
                    letterSpacing: -2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: BKColors.yellow),
            const SizedBox(height: 16),
            const Text(
              'Cargando BK Admin...',
              style: TextStyle(
                color: BKColors.textSecondary,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
