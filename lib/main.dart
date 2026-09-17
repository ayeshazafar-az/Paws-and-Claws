import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/supabase_setup.dart';
import 'src/core/theme.dart';
import 'src/core/router.dart';
import 'src/core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase & DotEnv
  await SupabaseSetup.initialize();

  runApp(const ProviderScope(child: PawsAndClawsApp()));
}

class PawsAndClawsApp extends ConsumerWidget {
  const PawsAndClawsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Paws & Claws',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentThemeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
