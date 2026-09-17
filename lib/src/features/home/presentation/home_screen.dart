import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/animal_provider.dart';
import '../widgets/animal_card.dart';
import '../../../core/supabase_setup.dart'; // To get current user details
import '../../auth/providers/role_provider.dart';
import '../../../core/providers/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = SupabaseSetup.client.auth.currentUser;
    final String greetingName =
        user?.userMetadata?['full_name']?.split(' ').first ?? 'Friend';

    final urgentAsync = ref.watch(urgentAnimalsProvider);
    final allAsync = ref.watch(allAnimalsProvider);
    final selectedSpecies = ref.watch(selectedSpeciesProvider);

    final role = ref.watch(userRoleProvider);

    return Scaffold(
      floatingActionButton: (role == 'adopter' || role == 'guest')
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/chat'),
              icon: const Icon(Icons.chat, color: Colors.white),
              backgroundColor: theme.colorScheme.secondary,
              label: const Text(
                'Live Support',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(urgentAnimalsProvider);
            ref.invalidate(allAnimalsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            greetingName,
                            style: theme.textTheme.displayMedium,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final role = ref.watch(userRoleProvider);
                              if (role == 'adopter')
                                return const SizedBox.shrink(); // Hide from standard users

                              return Row(
                                children: [
                                  if (role == 'admin')
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[900]
                                            ?.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.only(right: 12),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.admin_panel_settings,
                                          color: Colors.blueGrey,
                                        ),
                                        tooltip: 'Admin Portal',
                                        onPressed: () => context.push('/admin'),
                                      ),
                                    ),
                                  if (role == 'volunteer')
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.only(right: 12),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.assignment,
                                          color: Colors.teal,
                                        ),
                                        tooltip: 'Shelter Portal',
                                        onPressed: () =>
                                            context.push('/volunteer'),
                                      ),
                                    ),
                                  if (role == 'seller' || role == 'admin')
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.pinkAccent.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      margin: const EdgeInsets.only(right: 12),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.analytics,
                                          color: Colors.pinkAccent,
                                        ),
                                        tooltip: 'Revenue Analytics',
                                        onPressed: () =>
                                            context.push('/analytics'),
                                      ),
                                    ),
                                  if (role == 'seller' || role == 'admin')
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                        ),
                                        tooltip: 'Post Pet / Sell',
                                        onPressed: () =>
                                            context.push('/add_animal'),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.auto_awesome,
                                color: Colors.deepPurpleAccent,
                              ),
                              tooltip: 'Gemini AI Matchmaker',
                              onPressed: () => context.push('/ai_matchmaker'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final isDark =
                                    ref.watch(themeProvider) == ThemeMode.dark;
                                return IconButton(
                                  icon: Icon(
                                    isDark ? Icons.light_mode : Icons.dark_mode,
                                    color: Colors.amber,
                                  ),
                                  tooltip: 'Toggle Theme',
                                  onPressed: () => ref
                                      .read(themeProvider.notifier)
                                      .toggleTheme(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              context.push('/profile');
                            },
                            child: CircleAvatar(
                              backgroundColor: theme.colorScheme.secondary,
                              radius: 24,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Urgent Banner Section
              SliverToBoxAdapter(
                child: urgentAsync.when(
                  data: (urgentAnimals) {
                    if (urgentAnimals.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Urgent Cases',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: urgentAnimals.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: AnimalCard(
                                  animal: urgentAnimals[index],
                                  onTap: () {
                                    context.push(
                                      '/details',
                                      extra: urgentAnimals[index],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
              ),

              // Categories Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Cat', 'Dog', 'Bird'].map((species) {
                        final isSelected =
                            (selectedSpecies == null && species == 'All') ||
                            selectedSpecies == species;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(species),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                ref
                                    .read(selectedSpeciesProvider.notifier)
                                    .setSpecies(
                                      species == 'All' ? null : species,
                                    );
                              }
                            },
                            selectedColor: theme.colorScheme.secondary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Main Feed Grid
              allAsync.when(
                data: (animals) {
                  if (animals.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No animals found.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.crossAxisExtent > 600
                            ? 4
                            : 2;

                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio:
                                    0.75, // Adjust for nice card proportions
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return AnimalCard(
                              animal: animals[index],
                              onTap: () {
                                context.push('/details', extra: animals[index]);
                              },
                            );
                          }, childCount: animals.length),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error loading animals')),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),
        ),
      ),
    );
  }
}
