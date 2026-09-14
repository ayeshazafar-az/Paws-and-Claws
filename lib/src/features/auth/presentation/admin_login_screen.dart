import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_setup.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _adminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final secretKey = _secretKeyController.text;

    if (email.isEmpty || password.isEmpty || secretKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Verify Secret Vault Key
      final environmentSecret = dotenv.env['ADMIN_SECRET_KEY'];
      if (environmentSecret == null || secretKey != environmentSecret) {
        throw Exception('INVALID SECRET VAULT KEY. Access Denied.');
      }

      // 2. Authenticate
      final res = await SupabaseSetup.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // 3. Grant Admin Privileges in metadata securely
        await SupabaseSetup.client.auth.updateUser(
          UserAttributes(data: {'role': 'admin'}),
        );

        if (mounted) {
          context.go('/admin'); // Force route immediately to admin portal
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // Dark Admin Theme
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.tealAccent),
                const SizedBox(height: 24),
                const Text(
                  'Staff Portal',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Restricted Access Gateway',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[300]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Inputs
                _buildTextField(
                  _emailController,
                  'Staff Email',
                  Icons.email,
                  false,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _passwordController,
                  'Password',
                  Icons.lock,
                  true,
                ),
                const SizedBox(height: 32),

                // The dramatic secret key field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.tealAccent.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _secretKeyController,
                    obscureText: true,
                    style: const TextStyle(
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'SECRET VAULT KEY',
                      labelStyle: TextStyle(color: Colors.tealAccent),
                      prefixIcon: Icon(Icons.key, color: Colors.tealAccent),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.blueGrey[900],
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _adminLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black87)
                      : const Text(
                          'AUTHORIZE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool obscure,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey[300]),
        prefixIcon: Icon(icon, color: Colors.blueGrey[300]),
        filled: true,
        fillColor: Colors.blueGrey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
