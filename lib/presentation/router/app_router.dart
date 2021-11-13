import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/data/firebase_repository.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/logic/game_action_cubit.dart';
import 'package:rummikub/logic/game_searching_cubit.dart';
import 'package:rummikub/presentation/screens/game_action_screen.dart';
import 'package:rummikub/presentation/screens/game_screen.dart';
import 'package:rummikub/presentation/screens/game_searching_screen.dart';
import 'package:rummikub/presentation/screens/home_screen.dart';
import 'package:rummikub/presentation/screens/login_screen.dart';
import 'package:rummikub/presentation/screens/registration_screen.dart';

class AppRouter {
  final Repository _firebaseRepository = FirebaseRepository();

  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          settings: RouteSettings(name: '/'),
          builder: (context) => HomeScreen(),
        );
      case '/registration':
        return MaterialPageRoute(
            builder: (context) => BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(_firebaseRepository),
              child: RegistrationScreen(),
            )
        );
      case '/login':
        return MaterialPageRoute(
            builder: (context) => BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(_firebaseRepository),
              child: LoginScreen(),
            )
        );
      case '/game':
        return MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: settings.arguments as AuthCubit,
              child: GameScreen(),
            )
        );
      case '/game_settings':
        return MaterialPageRoute(
            builder: (context) => BlocProvider<GameSearchingCubit>(
              create: (context) => GameSearchingCubit(_firebaseRepository, settings.arguments as String),
              child: GameSearchingScreen(),
            )
        );
      case '/play':
        return MaterialPageRoute(
            builder: (context) => BlocProvider<GameActionCubit>(
              create: (context) => GameActionCubit(_firebaseRepository, settings.arguments as Map<String, String>),
              child: GameActionScreen(),
            ),
            settings: settings
        );
      default:
        return null;
    }
  }
}