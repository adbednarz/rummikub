import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/game_action_cubit.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/strings.dart';

class GameActionScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
      color: Colors.teal,
      child: BlocListener<GameActionCubit, GameActionState>(
          listener: (context, state) {

          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<GameActionCubit, GameActionState>(
                  builder: (context, state) {
                    return Expanded(
                        flex: 1,
                        child: _tmp(Colors.yellow),
                    );
                  }
              ),
              BlocBuilder<GameActionCubit, GameActionState>(
                  builder: (context, state) {
                    return Expanded(
                        flex: 8,
                        child: _board(context, state),
                    );
                  }
              ),
              BlocBuilder<GameActionCubit, GameActionState>(
                  builder: (context, state) {
                    return Expanded(
                        flex: 2,
                        child: _rack(context, state),
                    );
                  }
              ),
            ],
          ),
        ),
    );
  }

  _tmp(Color color) {
    return Container(
      color: color,
    );
  }

  _panel(BuildContext context, GameActionState state) {
    return Row(
      children: [

      ],
    );
  }

  _board(BuildContext context, GameActionState state) {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 13,
      children: List.generate(state.board.length, (index) {
        bool flag = false;
        return state.board[index] != null ?
        Draggable<Map<String, Tile>>(
          data: {"board." + index.toString(): state.board[index]!},
          child: _tile(state.board[index]!),
          feedback: _tile(state.board[index]!),
          childWhenDragging: Container(),
        ) :
        DragTarget<Map<String, Tile>>(
          builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
            return flag ?
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white)
              ),
            ) : Container();
          },
          onWillAccept: (Map<String, Tile>? tile) {
            flag = true;
            return true;
          },
          onLeave: (Map<String, Tile>? tile) {
            flag = false;
          },
          onAccept: (Map<String, Tile> item) {
            String from = item.keys.first;
            BlocProvider.of<GameActionCubit>(context).addToBoard(from, item[from]!, index);
          },
        );
      }),
    );
  }

  _rack(BuildContext context, GameActionState state) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    int rackSize = (state.rack.length/2).ceil() * 35;
    return GridView.count(
      padding: width > height ? EdgeInsets.symmetric(horizontal: (width - rackSize) / 2) : null,
      crossAxisCount: state.rack.length > 14 ? (state.rack.length/2).ceil() : 7,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(state.rack.length, (index) {
        bool flag = false;
        return state.rack[index] != null ?
          Draggable<Map<String, Tile>>(
            data: {"rack." + index.toString(): state.rack[index]!},
            child: _tile(state.rack[index]!),
            feedback: _tile(state.rack[index]!),
            childWhenDragging: Container(),
          ) :
          DragTarget<Map<String, Tile>>(
            builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
              return flag ?
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white)
                ),
              ) : Container();
            },
            onWillAccept: (Map<String, Tile>? tile) {
              flag = true;
              return true;
            },
            onLeave: (Map<String, Tile>? tile) {
              flag = false;
            },
            onAccept: (Map<String, Tile> item) {
              String from = item.keys.first;
              BlocProvider.of<GameActionCubit>(context).addToRack(from, item[from]!, index);
            },
          );
        }),
    );
  }

  _tile(Tile tile) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.amber[100],
      ),
      child: Center(
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              tile.number == 0 ? "?" : tile.number.toString(),
              style: TextStyle(
                  decoration: TextDecoration.none,
                  color: colors[tile.color],
              ),
              textAlign: TextAlign.center,
            )
          ),
      ),
    );
  }
}
