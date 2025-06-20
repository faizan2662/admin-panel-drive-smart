import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/users_provider.dart';
import 'providers/community_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DriveSmartAdminApp());
}

class DriveSmartAdminApp extends StatelessWidget {
  const DriveSmartAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Drive Smart Admin',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return authProvider.isAuthenticated
                ? const MainScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
