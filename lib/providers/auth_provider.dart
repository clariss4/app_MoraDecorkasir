import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_services.dart';
import '../services/database_service.dart';

// Providers untuk services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    return event.session?.user;
  });
});

// Loading state provider
final loadingProvider = StateProvider<bool>((ref) => false);
