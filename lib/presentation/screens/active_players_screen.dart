import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rummikub/logic/active_players_cubit.dart';

class ActivePlayersScreen extends StatelessWidget {
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);

  final Color logoGreen = Color(0xff25bcbb);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: primaryColor,
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
                child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) =>
                              BlocProvider.of<ActivePlayersCubit>(context).filtrActivePlayers(value),
                          decoration: const InputDecoration(
                              labelText: 'Search',
                              suffixIcon: Icon(Icons.search)),
                        ),
                        _buildList(context, state),
                        _buildButton(context),
                      ],
                    )
                ),
              );
            }
        )
    );
  }

  _buildList(BuildContext context, ActivePlayersState state) {
    return state.activePlayers.isNotEmpty
        ? ListView.builder(
            itemCount: state.activePlayers.length,
            itemBuilder: (context, index) {
              var flag = false;
              return Card(
                color: flag ? Colors.amberAccent : Colors.transparent,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(state.activePlayers[index]),
                  onTap: () =>
                    flag = BlocProvider.of<ActivePlayersCubit>(context)
                        .addPlayer(state.activePlayers[index])
                ),
              );
            }
          )
        : const Text(
            'No results found',
              style: TextStyle(fontSize: 24),
          );
  }

  MaterialButton _buildButton(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        if (BlocProvider.of<ActivePlayersCubit>(context).selectedPlayers.isNotEmpty) {
          var playerId = BlocProvider
              .of<ActivePlayersCubit>(context)
              .playerId;
          var selectedPlayers = BlocProvider
              .of<ActivePlayersCubit>(context)
              .selectedPlayers;
          Navigator.of(context).pushNamed(
              '/game_settings', arguments:
          {
            'playerId': playerId,
            'selectedPlayers': selectedPlayers
          });
        } else {
          Fluttertoast.showToast(
            gravity: ToastGravity.TOP,
            msg: 'You have to choose at least one player.',
            backgroundColor: Colors.grey,
          );
        }
      },
      color: logoGreen,
      child: Text('Login', style: TextStyle(
          color: Colors.white, fontSize: 16)),
    );
  }

}