import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/animal.dart';
import '../../../core/supabase_setup.dart';

final selectedSpeciesProvider = StateProvider<String?>((ref) => null);

final urgentAnimalsProvider = FutureProvider<List<Animal>>((ref) async {
  final response = await SupabaseSetup.client
      .from('animals')
      .select()
      .eq('is_urgent', true)
      .eq('adoption_status', 'available');

  return (response as List).map((e) => Animal.fromJson(e)).toList();
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
  return (response as List).map((e) => Animal.fromJson(e)).toList();
});
