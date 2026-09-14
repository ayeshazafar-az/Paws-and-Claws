import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/animal.dart';
import '../../../core/supabase_setup.dart';

// Very simple favorites mock state for now
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String animalId) {
    if (state.contains(animalId)) {
      state = {...state}..remove(animalId);
    } else {
      state = {...state, animalId};
    }
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  () => FavoritesNotifier(),
);

class DetailsScreen extends ConsumerWidget {
  final Animal animal;

  const DetailsScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(favoritesProvider).contains(animal.id);
    final imageUrl =
        animal.imageUrl ??
        'https://images.unsplash.com/photo-1543466835-00a7907e9de1';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : Colors.white,
                ),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggle(animal.id);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'animal_image_${animal.id}',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -32, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          animal.name,
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          animal.species,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${animal.breed ?? 'Mixed Breed'} • ${animal.ageMonths != null ? "${(animal.ageMonths! / 12).floor()} yrs" : "Unknown"}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (animal.isUrgent)
                        _buildTraitTag(
                          context,
                          Icons.warning_amber,
                          'Urgent Rescue',
                          Colors.redAccent,
                        ),
                      _buildTraitTag(
                        context,
                        Icons.medical_services,
                        'Vaccinated',
                        Colors.green,
                      ),
                      _buildTraitTag(
                        context,
                        Icons.child_friendly,
                        'Good with Kids',
                        Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About ${animal.name}',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    animal.description ??
                        'A loving companion looking for a forever home.',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adoption Fee', style: theme.textTheme.bodyMedium),
                Text('\$150', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final user = SupabaseSetup.client.auth.currentUser;
                    if (user != null) {
                      await SupabaseSetup.client.from('applications').insert({
                        'user_id': user.id,
                        'animal_id': animal.id,
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Application successfully submitted! We will contact you soon.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      throw 'You must be logged in to apply.';
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Apply to Adopt'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitTag(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
