import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:rummikub/logic/game_searching_cubit.dart';
import 'package:rummikub/shared/custom_error_dialog.dart';

class GameSearchingScreen extends StatelessWidget {
  final Color logoGreen = Color(0xff25bcbb);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<GameSearchingCubit, GameSearchingState>(
            listener: (context, state) {
              if (state is Failure) {
                showDialog(
                    context: context,
                    builder: (context) =>
                        CustomErrorDialog('Error', state.errorMessage)
                );
              } else if (state is GameFound) {
                var playerId =  BlocProvider.of<GameSearchingCubit>(context).playerId;
                Navigator.of(context).pushNamed('/play', arguments:
                {'gameId': state.gameId, 'playerId': playerId,
                'timeForMove': state.timeForMove.toString()});
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
                      Text("Time for move"),
                      _buildTimeSizeInput(context, state),
                      SizedBox(height: 60),
                      Text("Number of players"),
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

  ScrollConfiguration _buildTimeSizeInput(BuildContext context, GameSearchingState state) {
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
        onChanged: (value) => BlocProvider.of<GameSearchingCubit>(context).changeTimeForMove(value),
      ),
    );
  }

  ScrollConfiguration _buildGameSizeInput(BuildContext context, GameSearchingState state) {
    var players = BlocProvider.of<GameSearchingCubit>(context).selectedPlayers;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      }),
      child: NumberPicker(
        axis: Axis.horizontal,
        value: state.playersNumber,
        minValue: players != null ? players.length : 2,
        maxValue: players != null ? players.length : 4,
        onChanged: (value) => BlocProvider.of<GameSearchingCubit>(context).changePlayersNumber(value),
      ),
    );
  }

  MaterialButton _buildMaterialButton(BuildContext context) {
    var players = BlocProvider.of<GameSearchingCubit>(context).selectedPlayers;
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () => players != null
          ? BlocProvider.of<GameSearchingCubit>(context).createGame()
          : BlocProvider.of<GameSearchingCubit>(context).searchGame(),
      color: logoGreen,
      child: Text('SEARCH GAME', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}