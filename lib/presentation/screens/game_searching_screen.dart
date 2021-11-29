import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:rummikub/logic/game_searching_cubit.dart';
import 'package:rummikub/shared/custom_error_dialog.dart';

class GameSearchingScreen extends StatelessWidget {
  final Color logoGreen = Color(0xff25bcbb);
  final TextEditingController incDecNumController = TextEditingController();

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
                {'gameId': state.gameId, 'playerId': playerId});
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
                      _buildDropdownButton(context),
                      SizedBox(height: 20),
                      _buildMaterialButton(context),
                    ],
                  )
              );
            }
        )
    );
  }

  NumberInputPrefabbed _buildDropdownButton(BuildContext context) {
    return NumberInputPrefabbed.squaredButtons(
      controller: incDecNumController,
      initialValue: 2,
      min: 2,
      max: 4,
      incDecBgColor: Colors.green,
    );
  }

  MaterialButton _buildMaterialButton(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        BlocProvider.of<GameSearchingCubit>(context).searchGame(
            playersNumber: int.parse(incDecNumController.text)
        );
      },
      color: logoGreen,
      child: Text('SEARCH GAME', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}