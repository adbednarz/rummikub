import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/data/auth_repository.dart';
import 'package:rummikub/data/bot/game_bot.dart';
import 'package:rummikub/data/firebase/auth_firebase.dart';
import 'package:rummikub/data/firebase/game_firebase.dart';
import 'package:rummikub/data/game_repository.dart';
import 'package:rummikub/logic/active_players_cubit.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_board_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_panel_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_rack_cubit.dart';
import 'package:rummikub/logic/game_settings_cubit.dart';
import 'package:rummikub/presentation/screens/active_players_screen.dart';
import 'package:rummikub/presentation/screens/bot_settings_screen.dart';
import 'package:rummikub/presentation/screens/game_action_screen.dart';
import 'package:rummikub/presentation/screens/game_screen.dart';
import 'package:rummikub/presentation/screens/game_settings_screen.dart';
import 'package:rummikub/presentation/screens/home_screen.dart';
import 'package:rummikub/presentation/screens/login_screen.dart';
import 'package:rummikub/presentation/screens/registration_screen.dart';

class AppRouter {
  final AuthRepository _authRepository = AuthFirebase();
  final GameRepository _gameRepository = GameFirebase();

  Route? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        settings: RouteSettings(name: '/'),
        builder: (context) => HomeScreen(),
      );
    } else if (settings.name == '/registration') {
      return MaterialPageRoute(
          builder: (context) => BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(_authRepository, _gameRepository),
            child: RegistrationScreen(),
          )
      );
    } else if (settings.name == '/login') {
      return MaterialPageRoute(
          builder: (context) => BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(_authRepository, _gameRepository),
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
      var params = settings.arguments as Map<String, dynamic>;
      int? gameSize = params['selectedPlayers'] != null
          ? params['selectedPlayers'].length + 1
          : null;
      GameRepository server;
      if (params['serverType'] == 'basicBot') {
        server = GameBot('basicBot');
      } else if (params['serverType'] == 'advancedBot') {
        server = GameBot('advancedBot');
      } else {
        server = _gameRepository;
      }
      return MaterialPageRoute(
          builder: (context) =>
              BlocProvider<GameSettingsCubit>(
                create: (context) =>
                    GameSettingsCubit(
                      server,
                      params['playerId'],
                      selectedPlayers: params['selectedPlayers'],
                      gameSize: gameSize,
                      gameId: params['gameId']
                    ),
                child: GameSettingsScreen(),
              )
      );
    } else if (settings.name == '/bot_settings') {
      return MaterialPageRoute(
        builder: (context) => BotSettingsScreen(),
      );
    } else if (settings.name == '/find_players') {
      var params = settings.arguments as Map<String, String>;
      return MaterialPageRoute(
          builder: (context) =>
              BlocProvider<ActivePlayersCubit>(
                create: (context) =>
                    ActivePlayersCubit(_authRepository, params['playerId']!),
                child: ActivePlayersScreen(),
              )
      );
    } else if (settings.name == '/play') {
      
      var params = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (context) =>
              MultiBlocProvider(
                providers: [
                  BlocProvider<GameActionPanelCubit>(
                    create: (context) => GameActionPanelCubit(
                        params['serverType'],
                        params['gameId'],
                        params['playerId']
                    ),
                  ),
                  BlocProvider<GameActionBoardCubit>(
                    create: (context) => GameActionBoardCubit(
                        params['serverType'],
                        params['gameId'],
                        params['playerId']
                    ),
                  ),
                  BlocProvider<GameActionRackCubit>(
                    create: (context) => GameActionRackCubit(
                        params['serverType'],
                        params['gameId'],
                        params['playerId']
                    ),
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