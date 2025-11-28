import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'providers/auth_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final initialSession = Supabase.instance.client.auth.currentSession;

    if (initialSession != null) {
      print('User already logged in: ${initialSession.user.email}');
    } else {
      print('No user logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'MoraDecor POS',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: authState.when(
        data: (user) {
          print('Auth state changed. User: ${user?.email}');

          if (user != null) {
            // ✅ UNTUK DEVELOPMENT: LANGSUNG KE DASHBOARD TANPA CHECK EMAIL CONFIRMATION
            return const DashboardScreen();
          }
          return const SplashScreen();
        },
        loading: () {
          print('Auth state loading...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stack) {
          print('Auth state error: $error');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Authentication Error'),
                  Text(error.toString()),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(authStateProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
