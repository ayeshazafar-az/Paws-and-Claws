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
  String _selectedBreed = 'Unknown';
  bool _isUrgent = false;
  bool _isPosting = false;

  final Map<String, List<String>> _breeds = {
    'Dog': [
      'Unknown',
      'Mixed Breed',
      'Golden Retriever',
      'German Shepherd',
      'Labrador',
      'Bulldog',
      'Poodle',
      'Husky',
      'Other',
    ],
    'Cat': [
      'Unknown',
      'Mixed Breed',
      'Persian',
      'Siamese',
      'Maine Coon',
      'Ragdoll',
      'Bengal',
      'Sphynx',
      'Other',
    ],
    'Bird': [
      'Unknown',
      'Parrot',
      'Cockatiel',
      'Canary',
      'Finch',
      'Lovebird',
      'Other',
    ],
    'Other': ['Unknown', 'Other'],
  };

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
          'breed': _selectedBreed == 'Unknown' ? null : _selectedBreed,
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'List a Rescue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Help them find a home 🐾',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fill out the card below to post a new rescue directly to the dashboard.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          label: 'Animal Name',
                          icon: Icons.pets,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),

                        DropdownButtonFormField<String>(
                          value: _selectedSpecies,
                          decoration: _inputDecoration(
                            'Species',
                            Icons.category,
                          ),
                          items: ['Dog', 'Cat', 'Bird', 'Other'].map((species) {
                            return DropdownMenuItem(
                              value: species,
                              child: Text(species),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedSpecies = val!;
                              _selectedBreed =
                                  'Unknown'; // Reset breed safely when species changes
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: _selectedBreed,
                                decoration: _inputDecoration(
                                  'Breed',
                                  Icons.merge_type,
                                ),
                                isExpanded: true,
                                items: _breeds[_selectedSpecies]!.map((breed) {
                                  return DropdownMenuItem(
                                    value: breed,
                                    child: Text(
                                      breed,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedBreed = val!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildInputField(
                                controller: _ageController,
                                label: 'Age (mo)',
                                icon: Icons.calendar_today,
                                isNumber: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildInputField(
                          controller: _descController,
                          label: 'Description & Personality',
                          icon: Icons.description,
                          maxLines: 4,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _isUrgent
                                ? Colors.redAccent.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                'Urgent Rescue Case',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isUrgent
                                      ? Colors.redAccent
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                'Highlights them in red on the dashboard.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              activeColor: Colors.redAccent,
                              value: _isUrgent,
                              onChanged: (val) =>
                                  setState(() => _isUrgent = val),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 8,
                      shadowColor: theme.colorScheme.secondary.withOpacity(0.5),
                    ),
                    onPressed: _isPosting ? null : _postAnimal,
                    icon: _isPosting
                        ? const SizedBox.shrink()
                        : const Icon(Icons.send, size: 20),
                    label: _isPosting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Post Animal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[600],
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
    );
  }
}
