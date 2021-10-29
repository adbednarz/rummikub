import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:rummikub/logic/game_settings_cubit.dart';

class GameSettingsScreen extends StatelessWidget {
  final Color logoGreen = Color(0xff25bcbb);
  final TextEditingController incDecNumController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildDropdownButton(context),
              SizedBox(height: 20),
              _buildMaterialButton(context),
            ],
          )
      ),
    );
  }

  _buildDropdownButton(BuildContext context) {
    return NumberInputPrefabbed.squaredButtons(
      controller: incDecNumController,
      initialValue: 2,
      min: 2,
      max: 4,
      incDecBgColor: Colors.green,
    );
  }

  _buildMaterialButton(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        BlocProvider.of<GameSettingsCubit>(context).searchGame(
            playersNumber: int.parse(incDecNumController.text)
        );
        //Navigator.of(context).pushNamed('/play');
      },
      color: logoGreen,
      child: Text('SEARCH GAME', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}