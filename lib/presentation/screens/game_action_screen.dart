import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/game_action/game_action_board_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_panel_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_rack_cubit.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/models/tiles_set.dart';
import 'package:rummikub/shared/strings.dart';

class GameActionScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
      color: Colors.teal,
      child: BlocListener<GameActionPanelCubit, GameActionPanelState>(
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
              BlocBuilder<GameActionBoardCubit, GameActionBoardState>(
                  builder: (context, state) {
                    return Expanded(
                        flex: 10,
                        child: _board(context, state),
                    );
                  }
              ),
              BlocBuilder<GameActionRackCubit, GameActionRackState>(
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

  _board(BuildContext context, GameActionBoardState state) {
    final children = <Widget>[];
    int counter = 0;
    for(int i = 0; i < state.sets.length; i++) {
      while(counter < state.sets[i].position - 1) {
        children.add(_buildDragTarget(context, counter, i));
        counter++;
      }
      if (counter % 13 != 0) {
        if (counter % 13 == 12) {
          children.add(_buildDragTarget(context, counter, i));
          counter++;
        } else if (i != 0 && state.sets[i-1].position +
            state.sets[i-1].tiles.length + 1 != state.sets[i].position) {
          children.add(_buildDragTarget2(context, i, 'start'));
          counter++;
        } else if (i == 0) {
          children.add(_buildDragTarget2(context, i, 'start'));
          counter++;
        }
      }
      for(int j = 0; j < state.sets[i].tiles.length; j++) {
        children.add(
            Draggable<Tile>(
              data: state.sets[i].tiles[j],
              child: _tile(state.sets[i].tiles[j]),
              feedback: _tile(state.sets[i].tiles[j]),
              childWhenDragging: Container(),
              onDragStarted: () {
                BlocProvider.of<GameActionBoardCubit>(context).draggable = [i, j];
              },
            )
        );
        counter++;
      }
      if (counter % 13 != 0) {
        if (i + 1 < state.sets.length &&
            state.sets[i].position + state.sets[i].tiles.length + 1
                == state.sets[i + 1].position && counter % 13 != 12) {
          children.add(_buildDragTarget3(context, i));
        } else {
          children.add(_buildDragTarget2(context, i, 'end'));
        }
        counter++;
      }
    }
    while(counter < 140) {
      children.add(_buildDragTarget(context, counter, state.sets.length - 1));
      counter++;
    }
    return GridView.count(
      crossAxisCount: 13,
      mainAxisSpacing: 5,
      physics: NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  _rack(BuildContext context, GameActionRackState state) {
    double padding = (MediaQuery.of(context).size.width - (state.rack.length/2).ceil() * 35) / 2;
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: padding > 0 ? padding : 0),
      crossAxisCount: state.rack.length > 14 ? (state.rack.length/2).ceil() : 7,
      reverse: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(state.rack.length, (index) {
        bool flag = false;
        return state.rack[index] != null ?
          Draggable<Tile>(
            data: state.rack[index]!,
            child: _tile(state.rack[index]!),
            feedback: _tile(state.rack[index]!),
            childWhenDragging: Container(),
            onDragCompleted: () {
              BlocProvider.of<GameActionRackCubit>(context).changeRack(index, null);
            },
          ) :
          DragTarget<Tile>(
            builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
              return flag ?
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white)
                ),
              ) : Container();
            },
            onWillAccept: (Tile? tile) {
              if (tile!.isMine) {
                flag = true;
                return true;
              } else {
                return false;
              }
            },
            onLeave: (Tile? tile) {
              flag = false;
            },
            onAccept: (Tile tile) {
              BlocProvider.of<GameActionRackCubit>(context).changeRack(index, tile);
            },
          );
        }),
    );
  }

  _tile(Tile tile) {
    return Container(
      width: 10,
      height: 10,
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

  _buildDragTarget(BuildContext context, int counter, int previousSetIndex) {
    bool flag = false;
    return DragTarget<Tile>(
      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
        return flag ?
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white)
          ),
        ) : Container();
      },
      onWillAccept: (Tile? tile) {
        flag = true;
        return true;
      },
      onLeave: (Tile? tile) {
        flag = false;
      },
      onAccept: (Tile tile) {
        BlocProvider.of<GameActionBoardCubit>(context).addNewSet(counter, previousSetIndex, tile);
      },
    );
  }

  _buildDragTarget2(BuildContext context, int index, String direction) {
    bool flag = false;
    return DragTarget<Tile>(
      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
        return flag ?
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white)
          ),
        ) : Container();
      },
      onWillAccept: (Tile? tile) {
        flag = true;
        return true;
      },
      onLeave: (Tile? tile) {
        flag = false;
      },
      onAccept: (Tile tile) {
        BlocProvider.of<GameActionBoardCubit>(context).addToExistingSet(index, tile, direction);
      },
    );
  }

  _buildDragTarget3(BuildContext context, int index) {
    bool flag = false;
    return DragTarget<Tile>(
      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
        return flag ?
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white)
          ),
        ) : Container();
      },
      onWillAccept: (Tile? tile) {
        flag = true;
        return true;
      },
      onLeave: (Tile? tile) {
        flag = false;
      },
      onAccept: (Tile tile) {
        BlocProvider.of<GameActionBoardCubit>(context).combineTwoSet(index, tile);
      },
    );
  }

}
