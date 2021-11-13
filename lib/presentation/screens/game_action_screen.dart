import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/game_action_cubit.dart';

class GameActionScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<GameActionCubit, GameActionState>(
          listener: (context, state) {

          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                elevation: 0,
                minWidth: double.maxFinite,
                height: 50,
                onPressed: () {
                  BlocProvider.of<GameActionCubit>(context).putTiles();
                },
                child: Text('REGISTER', style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ],
          )
        )
    );
  }
}