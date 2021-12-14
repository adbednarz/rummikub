import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:rummikub/logic/game_settings_cubit.dart';
import 'package:rummikub/shared/custom_error_dialog.dart';

class GameSettingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.lightBlueAccent,
        body: BlocConsumer<GameSettingsCubit, GameSettingsState>(
            listener: (context, state) {
              if (state is Failure) {
                showDialog(
                    context: context,
                    builder: (context) =>
                        CustomErrorDialog('Error', state.message)
                );
              } else if (state is GameFound) {
                var playerId = BlocProvider.of<GameSettingsCubit>(context).playerId;
                var serverType = BlocProvider.of<GameSettingsCubit>(context).repository;
                Navigator.of(context).pushNamed('/play', arguments:
                {'gameId': state.gameId, 'playerId': playerId, 'serverType': serverType});
              }
            },
            builder: (context, state) {
              if (state is Loading) {
                return Center(
                  child:  CircularProgressIndicator()
                );
              } else if (state is Waiting) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Currently missing ${state.missingPlayersNumber} player(s)'),
                    ],
                  ),
                );
              }
              return Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Time for move'),
                      _buildTimeSizeInput(context, state),
                      SizedBox(height: 60),
                      Text('Number of players'),
                      _buildGameSizeInput(context, state),
                      SizedBox(height: 60),
                      _buildMaterialButton(context),
                    ],
                  )
              );
            }
        )
    );

  }

  ScrollConfiguration _buildTimeSizeInput(BuildContext context, GameSettingsState state) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      child: NumberPicker(
        axis: Axis.horizontal,
        value: state.timeForMove,
        minValue: 40,
        maxValue: 120,
        step: 20,
        onChanged: (value) => BlocProvider.of<GameSettingsCubit>(context).changeTimeForMove(value),
      ),
    );
  }

  ScrollConfiguration _buildGameSizeInput(BuildContext context, GameSettingsState state) {
    var size = BlocProvider.of<GameSettingsCubit>(context).gameSize;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      child: NumberPicker(
        axis: Axis.horizontal,
        value: state.playersNumber,
        minValue: size ?? 2,
        maxValue: size ?? 4,
        onChanged: (value) => BlocProvider.of<GameSettingsCubit>(context).changePlayersNumber(value),
      ),
    );
  }

  MaterialButton _buildMaterialButton(BuildContext context) {
    var players = BlocProvider.of<GameSettingsCubit>(context).selectedPlayers;
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () => players != null
          ? BlocProvider.of<GameSettingsCubit>(context).createGame()
          : BlocProvider.of<GameSettingsCubit>(context).searchGame(),
      color: Colors.teal,
      child: Text('START GAME', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}