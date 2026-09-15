import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_setup.dart';

import 'volunteer_inbox_screen.dart';

final pendingApplicationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final res = await SupabaseSetup.client
      .from('applications')
      .select('*, animals(*)')
      .eq('status', 'pending');
  return res as List<dynamic>;
});

class VolunteerDashboardScreen extends ConsumerWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appsAsync = ref.watch(pendingApplicationsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Shelter Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.inbox, color: Colors.white),
            tooltip: 'Live Support Inbox',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VolunteerInboxScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: appsAsync.when(
        data: (apps) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Incoming Applications',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.teal[900],
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Review and process adoption questionnaires below.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  if (apps.isEmpty)
                    Card(
                      elevation: 0,
                      color: Colors.teal.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(48.0),
                        child: Center(
                          child: Text(
                            'No pending applications right now 🎉',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...apps.map((app) {
                      final animal = app['animals'] as Map<String, dynamic>?;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(24),
                          leading: CircleAvatar(
                            radius: 32,
                            backgroundImage: animal?['image_url'] != null
                                ? NetworkImage(animal!['image_url'])
                                : null,
                            child: animal?['image_url'] == null
                                ? const Icon(Icons.pets)
                                : null,
                          ),
                          title: Text(
                            'Application for ${animal?['name'] ?? 'Unknown'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Status: ${app['status']}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
