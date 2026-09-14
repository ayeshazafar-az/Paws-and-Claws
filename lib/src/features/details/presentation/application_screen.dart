import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/supabase_setup.dart';
import '../../../core/models/animal.dart';

class ApplicationScreen extends StatefulWidget {
  final Animal animal;

  const ApplicationScreen({super.key, required this.animal});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _hasOtherPets = false;
  bool _isSubmitting = false;

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final user = SupabaseSetup.client.auth.currentUser;
        if (user == null) throw Exception("Please log in to apply.");

        // We insert to the backend schema as defined
        await SupabaseSetup.client.from('applications').insert({
          'user_id': user.id,
          'animal_id': widget.animal.id,
          'status': 'pending',
          'reason': _reasonController.text.trim(),
          'experience': _experienceController.text.trim(),
          'has_other_pets': _hasOtherPets,
        });

        if (mounted) {
          setState(() => _isSubmitting = false);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Application Submitted! 🎉'),
              content: Text(
                'Your application to adopt ${widget.animal.name} has been sent to the shelter. We will review your answers and get back to you shortly!',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.go('/'); // Send back to home feed
                  },
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
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
        title: Text(
          'Apply for ${widget.animal.name}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.secondary.withOpacity(
                      0.2,
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 48,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Adoption Questionnaire',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please answer honestly. This helps us ensure ${widget.animal.name} goes to the perfect forever home.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

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
                        _buildFieldLabel(
                          'Why do you want to adopt ${widget.animal.name}?',
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reasonController,
                          maxLines: 4,
                          decoration: _inputDecoration(
                            'I would love to adopt because...',
                            Icons.chat_bubble_outline,
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'This field is required'
                              : null,
                        ),
                        const SizedBox(height: 32),

                        _buildFieldLabel('Describe your experience with pets.'),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _experienceController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            'I grew up with dogs and cats...',
                            Icons.history,
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'This field is required'
                              : null,
                        ),
                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Do you currently have other pets?',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            activeColor: theme.colorScheme.secondary,
                            value: _hasOtherPets,
                            onChanged: (val) =>
                                setState(() => _hasOtherPets = val),
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
                    onPressed: _isSubmitting ? null : _submitApplication,
                    icon: _isSubmitting
                        ? const SizedBox.shrink()
                        : const Icon(Icons.check_circle, size: 20),
                    label: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit Application',
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

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(
          bottom: 50.0,
        ), // Align icon to top in multiline
        child: Icon(icon, color: Colors.grey[400]),
      ),
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
