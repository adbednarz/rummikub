import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/presentation/screens/game_screen.dart';
import 'package:rummikub/presentation/screens/home_screen.dart';
import 'package:rummikub/presentation/screens/login_screen.dart';
import 'package:rummikub/presentation/screens/registration_screen.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
        );
      case '/registration':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => AuthCubit(),
              child: RegistrationScreen(),
            )
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => AuthCubit(),
            child: LoginScreen(),
          )
        );
      case '/game':
        return MaterialPageRoute(
            builder: (_) => GameScreen(),
            );
      default:
        return null;
    }
  }
}