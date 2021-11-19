import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/game_action/game_action_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_panel_cubit.dart';
import 'package:rummikub/shared/models/player.dart';
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
              BlocBuilder<GameActionPanelCubit, GameActionPanelState>(
                  builder: (context, state) {
                    return Expanded(
                        flex: 1,
                        child: _panel(context, state),
                    );
                  }
              ),
              BlocBuilder<GameActionCubit, GameActionState>(
                  builder: (context, state) {
                    return Expanded(
                        flex: 10,
                        child: _board(context, state),
                    );
                  }
              ),
              BlocBuilder<GameActionCubit, GameActionState>(
                  builder: (context, state) {
                    return Expanded(
                        flex: 1,
                        child: _rack(context, state),
                    );
                  }
              ),
            ],
          ),
        ),
    );
  }

  _panel(BuildContext context, GameActionPanelState state) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GridView.count(
            padding: EdgeInsets.only(top: 5),
            childAspectRatio: 5,
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            physics: NeverScrollableScrollPhysics(),
            children: [
              for (Player player in state.players)
                Stack(
                  children: [
                    FAProgressBar(
                      maxValue: 60,
                      progressColor: Colors.green,
                      backgroundColor: Colors.white70,
                      currentValue: player.currentTurn ? state.procent : 0,
                    ),
                    Container(
                      padding: EdgeInsets.all(2),
                      child: FittedBox(
                          child: Text(
                            player.name,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black,
                            ),
                          ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: FittedBox(
            child: OutlinedButton(
              onPressed: () {  },
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _board(BuildContext context, GameActionState state) {
    return GridView.count(
      crossAxisCount: 13,
      mainAxisSpacing: 5,
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
    double padding = (MediaQuery.of(context).size.width - (state.rack.length/2).ceil() * 35) / 2;
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: padding > 0 ? padding : 0),
      crossAxisCount: state.rack.length > 14 ? (state.rack.length/2).ceil() : 7,
      reverse: true,
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
              if (tile!.values.first.isMine) {
                flag = true;
                return true;
              } else {
                return false;
              }
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
