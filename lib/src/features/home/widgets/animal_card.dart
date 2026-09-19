import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/animal.dart';
import '../../auth/providers/role_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimalCard extends ConsumerWidget {
  final Animal animal;
  final VoidCallback onTap;

  const AnimalCard({super.key, required this.animal, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = SupabaseSetup.client.auth.currentUser;
    final role = ref.watch(userRoleProvider);

    final imageUrl = animal.imageUrl;

    // Convert months to readable string
    final ageStr = animal.ageMonths != null
        ? (animal.ageMonths! >= 12
              ? '${(animal.ageMonths! / 12).floor()} yrs'
              : '${animal.ageMonths} mos')
        : 'Unknown';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'animal_image_${animal.id}',
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Container(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        child: Center(
                          child: Icon(
                            Icons.pets,
                            size: 48,
                            color: theme.colorScheme.secondary.withOpacity(0.5),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          animal.name,
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (role != 'admin' && animal.sellerId != user?.id)
                        GestureDetector(
                          onTap: () {
                            context.push(
                              '/chat',
                              extra: {
                                'id': animal.sellerId,
                                'name': animal.name,
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withOpacity(
                                0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 20,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${animal.breed ?? animal.species} • $ageStr',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
