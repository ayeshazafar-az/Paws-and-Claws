import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase_setup.dart';
import '../providers/animal_provider.dart';

class AddAnimalScreen extends ConsumerStatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  ConsumerState<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends ConsumerState<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedSpecies = 'Dog';
  bool _isUrgent = false;
  bool _isPosting = false;

  void _postAnimal() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isPosting = true);

      try {
        final age = int.tryParse(_ageController.text) ?? 5;
        // Construct a dynamic unsplash image based on species
        final imageUrl =
            'https://source.unsplash.com/800x800/?${_selectedSpecies.toLowerCase()}';

        await SupabaseSetup.client.from('animals').insert({
          'name': _nameController.text.trim(),
          'species': _selectedSpecies,
          'breed': _breedController.text.trim().isNotEmpty
              ? _breedController.text.trim()
              : null,
          'age_months': age,
          'description': _descController.text.trim(),
          'image_url': imageUrl,
          'is_urgent': _isUrgent,
          'adoption_status': 'available',
        });

        // Refresh the feed
        ref.invalidate(allAnimalsProvider);
        ref.invalidate(urgentAnimalsProvider);

        if (mounted) {
          setState(() => _isPosting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully listed!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // Go back to feed
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isPosting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List a Rescue',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Help them find a home',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the details of the animal you are listing for adoption.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSpecies,
                decoration: const InputDecoration(
                  labelText: 'Species',
                  border: OutlineInputBorder(),
                ),
                items: ['Dog', 'Cat', 'Bird', 'Other'].map((species) {
                  return DropdownMenuItem(value: species, child: Text(species));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSpecies = val!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age (months)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Is this an urgent medical/rescue case?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Highlights them in red on the dashboard.',
                ),
                activeColor: Colors.redAccent,
                value: _isUrgent,
                onChanged: (val) => setState(() => _isUrgent = val),
              ),

              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onPressed: _isPosting ? null : _postAnimal,
                child: _isPosting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Animal', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
