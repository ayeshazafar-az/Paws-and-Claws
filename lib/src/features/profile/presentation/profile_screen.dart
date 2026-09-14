import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase_setup.dart';
import '../../../core/models/application.dart';
import '../../../core/models/donation.dart';

final applicationsProvider = FutureProvider<List<Application>>((ref) async {
  final user = SupabaseSetup.client.auth.currentUser;
  if (user == null) return [];
  final response = await SupabaseSetup.client
      .from('applications')
      .select()
      .eq('user_id', user.id)
      .order('submitted_at', ascending: false);
  return (response as List).map((e) => Application.fromJson(e)).toList();
});

final donationsProvider = FutureProvider<List<Donation>>((ref) async {
  final user = SupabaseSetup.client.auth.currentUser;
  if (user == null) return [];
  final response = await SupabaseSetup.client
      .from('donations')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
  return (response as List).map((e) => Donation.fromJson(e)).toList();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = SupabaseSetup.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? 'User';
    final email = user?.email ?? '';

    final appsAsync = ref.watch(applicationsProvider);
    final donsAsync = ref.watch(donationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.secondary,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fullName, style: theme.textTheme.displayMedium),
                        Text(email, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Section: Applications
            _buildSectionHeader(
              context,
              'My Applications',
              Icons.edit_document,
            ),
            appsAsync.when(
              data: (apps) {
                if (apps.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Text('No active applications found.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return ListTile(
                      leading: const Icon(Icons.pets),
                      title: Text(
                        'Application for Animal #${app.animalId.substring(0, 6)}',
                      ),
                      subtitle: Text(
                        'Submitted: ${app.submittedAt.toString().substring(0, 10)}',
                      ),
                      trailing: Chip(label: Text(app.status)),
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Failed to load applications.'),
            ),
            const Divider(),

            // Section: History
            _buildSectionHeader(context, 'Giving History', Icons.favorite),
            donsAsync.when(
              data: (dons) {
                if (dons.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Text('No donations recorded.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dons.length,
                  itemBuilder: (context, index) {
                    final don = dons[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                      ),
                      title: Text('Donation: \$${don.amount.toInt()}'),
                      subtitle: Text(
                        '${don.type} • ${don.createdAt.toString().substring(0, 10)}',
                      ),
                      trailing: Chip(label: Text(don.status)),
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Failed to load history.'),
            ),
            const Divider(),

            // Section: Settings
            _buildSectionHeader(context, 'Settings', Icons.settings),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await SupabaseSetup.client.auth.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
