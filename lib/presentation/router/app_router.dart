import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/data/firebase_repository.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/logic/game_creating_cubit.dart';
import 'package:rummikub/presentation/screens/game_action_screen.dart';
import 'package:rummikub/presentation/screens/game_screen.dart';
import 'package:rummikub/presentation/screens/game_settings_screen.dart';
import 'package:rummikub/presentation/screens/home_screen.dart';
import 'package:rummikub/presentation/screens/login_screen.dart';
import 'package:rummikub/presentation/screens/registration_screen.dart';

class AppRouter {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  late AuthCubit _authCubit;

  AppRouter() {
    this._authCubit = AuthCubit(_firebaseRepository);
  }

  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
        );
      case '/registration':
        return MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _authCubit,
              child: RegistrationScreen(),
            )
        );
      case '/login':
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: _authCubit,
            child: LoginScreen(),
          )
        );
      case '/game':
        return MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: _authCubit,
              child: GameScreen(),
            )
        );
      case '/game_settings':
        return MaterialPageRoute(
            builder: (context) => BlocProvider<GameCreatingCubit>(
              create: (context) => GameCreatingCubit(_firebaseRepository),
              child: GameSettingsScreen(),
            )
        );
      case '/play':
        return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider.value(
                  value: _authCubit,
                ),
                BlocProvider.value(
                  value: _authCubit,
                ),
              ],
              child: GameActionScreen(),
            )
        );
      default:
        return null;
    }
  }

  void dispose() {
    _authCubit.close();
  }
}