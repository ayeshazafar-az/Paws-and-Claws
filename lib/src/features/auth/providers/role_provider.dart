import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_setup.dart';
import 'auth_provider.dart';

// Provides the current user's role securely and reacts to auth state changes
final userRoleProvider = Provider<String>((ref) {
  // Watch auth provider to ensure the role updates when users switch accounts!
  final authState = ref.watch(authStateProvider);
  final user = authState.value?.session?.user;

  if (user == null) return 'adopter'; // default unsigned/guest

  // Extract role from metadata, defaulting to adopter if empty
  final role = user.userMetadata?['role']?.toString();
  return role ?? 'adopter';
});

// A quick utility future to ensure the current logged in user has admin privileges
// We will call this temporarily during the dashboard init so the user can test the app
final ensureAdminPrivilegesProvider = FutureProvider<void>((ref) async {
  final user = SupabaseSetup.client.auth.currentUser;
  if (user != null) {
    if (user.userMetadata?['role'] != 'admin') {
      await SupabaseSetup.client.auth.updateUser(
        UserAttributes(data: {'role': 'admin'}),
      );
    }
  }
});
