import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/data/bot/local_game.dart';
import 'package:rummikub/data/firebase_repository.dart';
import 'package:rummikub/data/repository.dart';
import 'package:rummikub/logic/active_players_cubit.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_board_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_panel_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_rack_cubit.dart';
import 'package:rummikub/logic/game_searching_cubit.dart';
import 'package:rummikub/presentation/screens/active_players_screen.dart';
import 'package:rummikub/presentation/screens/game_action_screen.dart';
import 'package:rummikub/presentation/screens/game_screen.dart';
import 'package:rummikub/presentation/screens/game_searching_screen.dart';
import 'package:rummikub/presentation/screens/home_screen.dart';
import 'package:rummikub/presentation/screens/login_screen.dart';
import 'package:rummikub/presentation/screens/registration_screen.dart';

class AppRouter {
  final Repository _firebaseRepository = FirebaseRepository();

  Route? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        settings: RouteSettings(name: '/'),
        builder: (context) => HomeScreen(),
      );
    } else if (settings.name == '/registration') {
      return MaterialPageRoute(
          builder: (context) => BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(_firebaseRepository),
            child: RegistrationScreen(),
          )
      );
    } else if (settings.name == '/login') {
      return MaterialPageRoute(
          builder: (context) => BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(_firebaseRepository),
            child: LoginScreen(),
          )
      );
    } else if (settings.name == '/game') {
      return MaterialPageRoute(
          settings: RouteSettings(name: '/game'),
          builder: (context) => BlocProvider.value(
            value: settings.arguments as AuthCubit,
            child: GameScreen(),
          )
      );
    } else if (settings.name == '/game_settings') {
      return MaterialPageRoute(
          builder: (context) =>
              BlocProvider<GameSearchingCubit>(
                create: (context) =>
                    GameSearchingCubit(
                        _firebaseRepository, settings.arguments as String),
                child: GameSearchingScreen(),
              )
      );
    } else if (settings.name == '/find_players') {
      return MaterialPageRoute(
          builder: (context) =>
              BlocProvider<ActivePlayersCubit>(
                create: (context) =>
                    ActivePlayersCubit(
                        _firebaseRepository, settings.arguments as String),
                child: ActivePlayersScreen(),
              )
      );
    } else if (settings.name!.startsWith('/play')) {
      Repository server;
      if (settings.name == '/play') {
        server = _firebaseRepository;
      } else {
        server = LocalGame();
      }
      return MaterialPageRoute(
          builder: (context) =>
              MultiBlocProvider(
                providers: [
                  BlocProvider<GameActionPanelCubit>(
                    create: (context) =>
                        GameActionPanelCubit(server, settings.arguments as Map<String, String>),
                  ),
                  BlocProvider<GameActionBoardCubit>(
                    create: (context) =>
                        GameActionBoardCubit(server, settings.arguments as Map<String, String>),
                  ),
                  BlocProvider<GameActionRackCubit>(
                    create: (context) =>
                        GameActionRackCubit(server, settings.arguments as Map<String, String>),
                  ),
                ],
                child: GameActionScreen(),
              ),
          settings: settings
      );
    } else {
      return null;
    }
  }
}