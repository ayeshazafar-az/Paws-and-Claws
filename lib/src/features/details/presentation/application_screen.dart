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
      appBar: AppBar(
        title: Text(
          'Apply for ${widget.animal.name}',
          style: const TextStyle(color: Colors.white),
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
                'Adoption Questionnaire',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Please answer honestly. This helps us ensure ${widget.animal.name} goes to the perfect home.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 32),

              _buildFieldLabel(
                'Why do you want to adopt ${widget.animal.name}?',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'I would love to adopt because...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'This field is required'
                    : null,
              ),
              const SizedBox(height: 24),

              _buildFieldLabel('Describe your experience with pets.'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _experienceController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'I grew up with dogs and cats...',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'This field is required'
                    : null,
              ),
              const SizedBox(height: 24),

              SwitchListTile(
                title: const Text('Do you currently have other pets?'),
                activeColor: theme.colorScheme.secondary,
                value: _hasOtherPets,
                onChanged: (val) => setState(() => _hasOtherPets = val),
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onPressed: _isSubmitting ? null : _submitApplication,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Application',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}
