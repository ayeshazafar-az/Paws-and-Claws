import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/animal.dart';
import '../../../core/supabase_setup.dart';

class SelectedSpeciesNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setSpecies(String? species) => state = species;
}

final selectedSpeciesProvider =
    NotifierProvider<SelectedSpeciesNotifier, String?>(
      () => SelectedSpeciesNotifier(),
    );

final urgentAnimalsProvider = FutureProvider<List<Animal>>((ref) async {
  final response = await SupabaseSetup.client
      .from('animals')
      .select()
      .eq('is_urgent', true)
      .eq('adoption_status', 'available');

  return (response as List)
      .map((e) => Animal.fromJson(e))
      .where((a) => a.sellerId != null && a.sellerId!.isNotEmpty)
      .toList();
});

final allAnimalsProvider = FutureProvider<List<Animal>>((ref) async {
  final selectedSpecies = ref.watch(selectedSpeciesProvider);

  var query = SupabaseSetup.client
      .from('animals')
      .select()
      .eq('adoption_status', 'available');

  if (selectedSpecies != null && selectedSpecies != 'All') {
    query = query.eq('species', selectedSpecies);
  }

  final response = await query;
  return (response as List)
      .map((e) => Animal.fromJson(e))
      .where((a) => a.sellerId != null && a.sellerId!.isNotEmpty)
      .toList();
});
