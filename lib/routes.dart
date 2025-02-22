import 'package:flutter/material.dart';
import 'package:warhammer/services/miniature_service.dart';
import 'screens/auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/filtered_miniature_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/registration':
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/favorites':
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case '/details':
        final setId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ItemDetailScreen(setId: setId),
        );
      case '/filtered':
        final filterParams = settings.arguments as FilterParams;
        return MaterialPageRoute(
          builder: (_) => FilteredMiniatureScreen(filterParams: filterParams),
        );
      case '/auth_screen':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found!')),
      );
    });
  }
}