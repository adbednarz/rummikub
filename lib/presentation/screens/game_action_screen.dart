import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/game_action_cubit.dart';

class GameActionScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<GameActionCubit, GameActionState>(
          listener: (context, state) {

          },
          builder: (context, state) {
            return ListView(
                children: state.tiles
                    .asMap().entries.map(
                      (e) => Text("${e.value} at index ${e.key}"),
                ).toList()
            );
          }
        )
    );
  }
}