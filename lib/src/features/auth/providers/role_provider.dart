import 'package:flutter_riverpod/flutter_riverpod.dart';
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
