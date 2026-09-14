import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/supabase_setup.dart';
import 'src/core/theme.dart';
import 'src/core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase & DotEnv
  await SupabaseSetup.initialize();

  runApp(const ProviderScope(child: PawsAndClawsApp()));
}

class PawsAndClawsApp extends StatelessWidget {
  const PawsAndClawsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Paws & Claws',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
