import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  final _ageController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedSpecies = 'Dog';
  String _selectedBreed = 'Unknown';
  bool _isUrgent = false;
  bool _isPosting = false;

  Uint8List? _imageBytes;
  String? _imageFileName;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFileName = image.name;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  void _postAnimal() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image of the pet first!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isPosting = true);

      try {
        final age = int.tryParse(_ageController.text) ?? 5;
        final user = SupabaseSetup.client.auth.currentUser;

        // 1. Upload Image to Supabase Storage
        final extension = _imageFileName?.split('.').last ?? 'jpg';
        final uniquePath =
            '\${DateTime.now().millisecondsSinceEpoch}_user_\${user?.id.substring(0,5)}.$extension';

        await SupabaseSetup.client.storage
            .from('pets')
            .uploadBinary(
              uniquePath,
              _imageBytes!,
              fileOptions: FileOptions(
                contentType: 'image/$extension',
                upsert: true,
              ),
            );

        // 2. Get Public URL
        final String finalImageUrl = SupabaseSetup.client.storage
            .from('pets')
            .getPublicUrl(uniquePath);

        // 3. Insert into Database
        await SupabaseSetup.client.from('animals').insert({
          'name': _nameController.text.trim(),
          'species': _selectedSpecies,
          'breed': _selectedBreed == 'Unknown' ? null : _selectedBreed,
          'age_months': age,
          'description': _descController.text.trim(),
          'image_url': finalImageUrl,
          'is_urgent': _isUrgent,
          'adoption_status': 'available',
          if (user != null) 'seller_id': user.id,
        });

        // 4. Refresh the feed
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
          context.pop();
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
                    'Upload a photo and fill out the details below to publish directly to the global feed.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Image Uploader
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        image: _imageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_imageBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageBytes == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 48,
                                  color: theme.primaryColor.withOpacity(0.6),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to Upload Photo',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
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
                              _selectedBreed = 'Unknown';
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
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Urgent Rescue',
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
                            onChanged: (val) => setState(() => _isUrgent = val),
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
                            'Post Animal to Feed',
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
