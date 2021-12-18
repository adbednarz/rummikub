import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:rummikub/logic/game_action/game_action_board_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_panel_cubit.dart';
import 'package:rummikub/logic/game_action/game_action_rack_cubit.dart';
import 'package:rummikub/shared/models/player.dart';
import 'package:rummikub/shared/models/tile.dart';
import 'package:rummikub/shared/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GameActionScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return _onWillPop(context);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
          color: Colors.teal,
          child: MultiBlocListener(
            listeners: [
              _createListenerActionPanel(),
              _createListenerActionBoard(),
            ],
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
                          flex: 6,
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
        ),
    );
  }

  Row _panel(BuildContext context, GameActionPanelState state) {
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
                      maxValue: BlocProvider.of<GameActionPanelCubit>(context).timeForMove ?? 120,
                      progressColor: Colors.green,
                      backgroundColor: Colors.white70,
                      currentValue:
                        BlocProvider.of<GameActionPanelCubit>(context).currentTurn
                            == player.playerId ? state.procent : 0,
                    ),
                    Container(
                      padding: EdgeInsets.all(2),
                      child: FittedBox(
                          child: Text(
                            player.name,
                            style: TextStyle(
                              fontSize: 20,
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
              onPressed: () {
                if (BlocProvider.of<GameActionPanelCubit>(context).isMyTurn()) {
                  if (BlocProvider.of<GameActionBoardCubit>(context).putTiles()) {
                    BlocProvider.of<GameActionPanelCubit>(context).tilesWasPut();
                    BlocProvider.of<GameActionRackCubit>(context).confirmRackModifications();
                  }
                }
              },
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

  /* plansza składa się z pól, które:
    - zawierają kość,
    - nie sąsiadują z żadnym zbiorem
    - znajdują się bezpośrednio za lub przed zbiorem
    - znajdują się pomiędzy dwoma zbiorami
  */
  GridView _board(BuildContext context, GameActionBoardState state) {
    final children = <Widget>[];
    var counter = 0;
    // iterujemy po ułożonych zbiorach kości
    for(var i = 0; i < state.sets.length; i++) {
      // plansze wypełniamy pustymi polami, aż do ostatniego pola przed zbiorem
      while(counter < state.sets[i].position - 1) {
        children.add(_buildDragTarget(context, i, counter: counter));
        counter++;
      }

      // pomiędzy wierszami nie występuje przerwa między zbiorami (warunek 1)
      // pola łączące zbiory zostało dodane w poprzedniej iteracji (warunek 2)
      // ostatnie pola w wierszu nie może wskazywać na dołączenie do zbioru w następnym wierszu (warunek 3)
      if (counter != state.sets[i].position) {
        if (i == 0 || state.sets[i-1].position + state.sets[i-1].tiles.length + 1 != state.sets[i].position) {
          if (counter % 13 != 12) {
            children.add(_buildDragTarget(context, i, direction: 'start'));
          } else {
            children.add(_buildDragTarget(context, i, counter: counter));
          }
          counter++;
        }
      }

      // kolejno dodawanie pół z kośćmi ze zbioru
      for(var j = 0; j < state.sets[i].tiles.length; j++) {
        children.add(
            Draggable<Tile>(
              data: state.sets[i].tiles[j],
              feedback: _tile(state.sets[i].tiles[j]),
              childWhenDragging: Container(),
              onDragStarted: () {
                BlocProvider.of<GameActionBoardCubit>(context).draggable = [i, j]; // wskazanie jaki element jest obecnie przenoszony
              },
              onDraggableCanceled: (velocity, offset) {
                BlocProvider.of<GameActionBoardCubit>(context).draggable = [-1, -1];
              },
              child: _tile(state.sets[i].tiles[j]),
            )
        );
        counter++;
      }

      // pole łączące zbiory w przypadku, gdy oddziela ich tylko jedno pole
      // pole to nie może być pierwszym i ostatnim polem w wierszu (nie łączymy zbiory pomiędzy wierszami)
      if (i + 1 < state.sets.length && counter % 13 != 12 &&
          state.sets[i].position + state.sets[i].tiles.length + 1 == state.sets[i + 1].position) {
        if (counter % 13 != 0) {
          children.add(_buildDragTarget(context, i));
        } else {
          children.add(_buildDragTarget(context, i+1, direction: 'start'));
        }
        counter++;
      } else if (counter % 13 != 0) {
        // za zbiorem dajemy pole wskazujące na dołączenie do tego zbioru
        // oprócz pola pierwszego, gdyż nie występuje łączenie pomiędzy wierszami
        children.add(_buildDragTarget(context, i, direction: 'end'));
        counter++;
      }
    }

    // pustymi polami wypełniamy resztę planszy
    while(counter < 140) {
      children.add(_buildDragTarget(context, state.sets.length, counter: counter));
      counter++;
    }

    var padding = 0.0;
    if (kIsWeb) {
      padding = MediaQuery.of(context).size.width * 1 / 4;
    } else if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height){
      padding = MediaQuery.of(context).size.width * 1 / 4;
    }
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: padding),
      crossAxisCount: 13,
      mainAxisSpacing: 5,
      physics: NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  GridView _rack(BuildContext context, GameActionRackState state) {
    var padding = (MediaQuery.of(context).size.width - (state.rack.length/2).ceil() * 35) / 2;
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: padding > 0 ? padding : 0),
      crossAxisCount: state.rack.length > 14 ? (state.rack.length/2).ceil() : 7,
      reverse: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(state.rack.length, (index) {
        var flag = false;
        return state.rack[index] != null ?
          Draggable<Tile>(
            data: state.rack[index]!,
            feedback: _tile(state.rack[index]!),
            childWhenDragging: Container(),
            onDragStarted: () {
              BlocProvider.of<GameActionBoardCubit>(context).draggable = [-1, -1]; // wskazanie, że nie jest to element z tablicy
            },
            onDragCompleted: () {
              BlocProvider.of<GameActionRackCubit>(context).changeRack(index, null);
            },
            child: _tile(state.rack[index]!),
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
              if (tile!.isMine && BlocProvider.of<GameActionPanelCubit>(context).isMyTurn()) {
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
              BlocProvider.of<GameActionBoardCubit>(context).removeDraggable();
              BlocProvider.of<GameActionRackCubit>(context).changeRack(index, tile);
            },
          );
        }),
    );

  }

  Container _tile(Tile tile) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.amber[100],
      ),
      child: Center(
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              tile.number == 0 ? '?' : tile.number.toString(),
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

  DragTarget<Tile> _buildDragTarget(BuildContext context, int index, {int? counter, String? direction}) {
    var flag = false;
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
        if (BlocProvider.of<GameActionPanelCubit>(context).isMyTurn()) {
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
        if (counter != null) {
          BlocProvider.of<GameActionBoardCubit>(context).addNewSet(counter, index, tile);
        } else if (direction != null) {
          BlocProvider.of<GameActionBoardCubit>(context).addToExistingSet(index, tile, direction);
        } else {
          BlocProvider.of<GameActionBoardCubit>(context).combineTwoSet(index, tile);
        }
      },
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final gameActionPanelCubit = BlocProvider.of<GameActionPanelCubit>(context);
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to leave the Game?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              gameActionPanelCubit.leaveGameBeforeEnd();
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  BlocListener<GameActionPanelCubit, GameActionPanelState> _createListenerActionPanel() {
    return BlocListener<GameActionPanelCubit, GameActionPanelState>(
      listener: (context, state) {
        if (state is PanelInfo) {
        } else if (state is MissedTurn) {
          if (BlocProvider.of<GameActionBoardCubit>(context).timePassed()) {
            BlocProvider.of<GameActionRackCubit>(context).confirmRackModifications();
          } else {
            BlocProvider.of<GameActionRackCubit>(context).restorePreviousRack();
            Fluttertoast.showToast(
              gravity: ToastGravity.TOP,
              msg: 'Your turn is missed',
              backgroundColor: Colors.grey,
            );
          }
        } else if (state is GameCancelled) {
          Fluttertoast.showToast(
            gravity: ToastGravity.TOP,
            msg: state.message,
            backgroundColor: Colors.grey,
          );
          Navigator.of(context).popUntil(ModalRoute.withName('/game'));
        } else if (state is GameFinished) {
          Fluttertoast.showToast(
            gravity: ToastGravity.CENTER,
            msg: state.message,
            backgroundColor: Colors.grey,
          );
        } else if (state is GameAbandoned) {
          if (BlocProvider.of<GameActionPanelCubit>(context).gameId == '0') {
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
          } else {
            Navigator.of(context).popUntil(ModalRoute.withName('/game'));
          }
        }
        },
    );
  }

  BlocListener<GameActionBoardCubit, GameActionBoardState> _createListenerActionBoard() {
    return BlocListener<GameActionBoardCubit, GameActionBoardState>(
      listener: (context, state) {
        if (state is BoardInfo) {
          Fluttertoast.showToast(
            gravity: ToastGravity.TOP,
            msg: state.message,
            backgroundColor: Colors.grey,
          );
        }
      },
    );
  }

}
