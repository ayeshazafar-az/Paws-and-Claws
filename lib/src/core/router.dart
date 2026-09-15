import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/admin_login_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/details/presentation/details_screen.dart';
import '../features/donation/presentation/donation_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/home/presentation/add_animal_screen.dart';
import '../features/details/presentation/application_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/manage_volunteers_screen.dart';
import '../features/volunteer/presentation/volunteer_dashboard_screen.dart';
import '../features/chat/presentation/chat_room_screen.dart';
import '../features/ai/presentation/ai_matchmaker_screen.dart';
import 'models/animal.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;

      final isLoginRoute = state.matchedLocation == '/login';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isAdminLoginRoute = state.matchedLocation == '/admin_login';

      if (!isAuth) {
        if (isOnboardingRoute || isLoginRoute || isAdminLoginRoute) return null;
        return '/onboarding';
      }

      if (isLoginRoute || isOnboardingRoute || isAdminLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/admin_login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/manage_volunteers',
        builder: (context, state) => const ManageVolunteersScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatRoomScreen(),
      ),
      GoRoute(
        path: '/ai_matchmaker',
        builder: (context, state) => const AIPetMatchmakerScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) {
          final animal = state.extra as Animal;
          return DetailsScreen(animal: animal);
        },
      ),
      GoRoute(
        path: '/donate',
        builder: (context, state) => const DonationScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/add_animal',
        builder: (context, state) => const AddAnimalScreen(),
      ),
      GoRoute(
        path: '/apply',
        builder: (context, state) {
          final animal = state.extra as Animal;
          return ApplicationScreen(animal: animal);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/volunteer',
        builder: (context, state) => const VolunteerDashboardScreen(),
      ),
    ],
  );
}
