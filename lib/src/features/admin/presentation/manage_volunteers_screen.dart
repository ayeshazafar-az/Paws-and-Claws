import 'package:flutter/material.dart';

class ManageVolunteersScreen extends StatefulWidget {
  const ManageVolunteersScreen({super.key});

  @override
  State<ManageVolunteersScreen> createState() => _ManageVolunteersScreenState();
}

class _ManageVolunteersScreenState extends State<ManageVolunteersScreen> {
  final _emailController = TextEditingController();
  bool _isProcessing = false;

  final List<Map<String, String>> _mockVolunteers = [
    {
      'name': 'Sarah Jenkins',
      'email': 'sarah.j@shelter.com',
      'status': 'Active Staff',
    },
    {
      'name': 'Marcus Aurelius',
      'email': 'marcus.a@shelter.com',
      'status': 'Senior Volunteer',
    },
  ];

  void _promoteVolunteer() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isProcessing = true);

    // Simulate secure Edge Function RPC call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _mockVolunteers.add({
        'name': 'New Recruit',
        'email': _emailController.text.trim(),
        'status': 'Active Staff',
      });
      _emailController.clear();
      _isProcessing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Network Success: Volunteer Privileges Granted!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          'Access Control Center',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Promote Adopters',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: Colors.blueGrey[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Elevate standard users to Shelter Staff by granting them the Volunteer role metadata.',
              ),
              const SizedBox(height: 32),

              // Elevation Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Target User Email',
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.blueGrey,
                        ),
                        filled: true,
                        fillColor: Colors.blueGrey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.blueGrey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isProcessing ? null : _promoteVolunteer,
                      icon: _isProcessing
                          ? const SizedBox.shrink()
                          : const Icon(Icons.shield, color: Colors.amber),
                      label: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Invoke Privilege Elevation / Promote',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              Text(
                'Active Shelter Staff',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              const SizedBox(height: 16),

              ..._mockVolunteers.reversed.map(
                (v) => Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.security, color: Colors.white),
                    ),
                    title: Text(
                      v['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(v['email']!),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        v['status']!,
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
