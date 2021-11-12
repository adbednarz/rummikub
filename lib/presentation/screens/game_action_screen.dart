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
          child: BlocBuilder<GameActionCubit, GameActionState>(
            builder: (context, state) {
              return Text(state.titles.length.toString());
            },
          ),
        )
    );
  }

}