import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rummikub/logic/active_players_cubit.dart';

class ActivePlayersScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.lightBlueAccent,
        body: BlocConsumer<ActivePlayersCubit, ActivePlayersState>(
            listener: (context, state) {
              if (state is Message) {
                Fluttertoast.showToast(
                  gravity: ToastGravity.TOP,
                  msg: state.message,
                  backgroundColor: Colors.grey,
                );
              }
            },
            builder: (context, state) {
              return Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) =>
                          BlocProvider.of<ActivePlayersCubit>(context).filtrActivePlayers(value),
                      decoration: const InputDecoration(
                          labelText: 'Search',
                          suffixIcon: Icon(Icons.search)),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      flex: 6,
                      child: _buildList(context, state),
                    ),
                    SizedBox(height: 20),
                    _buildButton(context, state),
                    SizedBox(height: 20),
                  ],
                ),
              );
            }
        )
    );
  }

  StatelessWidget _buildList(BuildContext context, ActivePlayersState state) {
    return state.activePlayers.isNotEmpty
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: state.activePlayers.length,
            itemBuilder: (context, index) {
              return Card(
                color: state.selectedPlayers.contains(state.activePlayers[index])
                    ? Colors.amberAccent : Colors.blueAccent,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(state.activePlayers[index]),
                  onTap: () {
                    BlocProvider.of<ActivePlayersCubit>(context)
                        .addPlayer(state.activePlayers[index]);
                  }

                ),
              );
            }
          )
        : const Text(
            'No results found',
              style: TextStyle(fontSize: 24),
          );
  }

  MaterialButton _buildButton(BuildContext context, ActivePlayersState state) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        if (state.selectedPlayers.isNotEmpty) {
          Navigator.of(context).pushNamed('/game_settings', arguments:
          {
            'playerId': BlocProvider.of<ActivePlayersCubit>(context).playerId,
            'selectedPlayers': state.selectedPlayers,
            'serverType': 'firebase'
          });
        } else {
          Fluttertoast.showToast(
            gravity: ToastGravity.TOP,
            msg: 'You have to choose at least one player.',
            backgroundColor: Colors.grey,
          );
        }
      },
      color: Color(0xff25bcbb),
      child: Text('CREATE GAME', style: TextStyle(
          color: Colors.white, fontSize: 16)),
    );
  }

}