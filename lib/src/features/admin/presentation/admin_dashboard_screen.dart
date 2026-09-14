import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_setup.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = SupabaseSetup.client;

  // 1. Total Animals
  final animalsRes = await client.from('animals').select('id');
  final totalAnimals = (animalsRes as List).length;

  // 2. Pending Applications
  final appsRes = await client
      .from('applications')
      .select('id')
      .eq('status', 'pending');
  final totalApps = appsRes.length;

  // 3. Total Donations Revenue
  final donations = await client.from('donations').select('amount');
  double totalRevenue = 0;
  for (var d in donations) {
    totalRevenue += (d['amount'] as num).toDouble();
  }

  return {
    'animals': totalAnimals,
    'applications': totalApps,
    'revenue': totalRevenue,
  };
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Admin Analytics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[900], // Distinctive Admin color
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'Go to Home',
            onPressed: () => context.go('/'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out Admin',
            onPressed: () async {
              await SupabaseSetup.client.auth.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Ecosystem Overview',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.blueGrey[900],
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exclusive manager-level analytics and ecosystem health.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Dashboard Stat Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      return GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: isWide ? 3 : 1,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: isWide ? 1.2 : 2.0,
                        children: [
                          _buildStatCard(
                            title: 'Total Revenue',
                            value: '\$${stats['revenue']!.toStringAsFixed(0)}',
                            icon: Icons.monetization_on,
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            title: 'Pending Applications',
                            value: stats['applications'].toString(),
                            icon: Icons.assignment,
                            color: Colors.orange,
                          ),
                          _buildStatCard(
                            title: 'Listed Rescues',
                            value: stats['animals'].toString(),
                            icon: Icons.pets,
                            color: theme.primaryColor,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 48),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.security, color: Colors.blueGrey),
                              SizedBox(width: 12),
                              Text(
                                'Role Access Management',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          const Text(
                            'As a Super Admin, you have global control over the system. Your account is permanently verified.',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[900],
                            ),
                            onPressed: () {},
                            icon: const Icon(
                              Icons.manage_accounts,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Manage Volunteers (Coming Soon)',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 28,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
