import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/shared/custom_error_dialog.dart';

class GameScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var width = (MediaQuery.of(context).size.width > 500 ? MediaQuery.of(context).size.width / 4 : 40).toDouble();
    return WillPopScope(
        onWillPop: () {
          return _onWillPop(context);
        },
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showDialog(context: context, builder: (context) =>
                  CustomErrorDialog('Error', state.errorMessage)
              );
            } else if (state is AuthInvited) {
              final authCubit = BlocProvider.of<AuthCubit>(context);
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: _buildAlertDialog(context, state, authCubit),
                    );
                  }
              );
            } else if (state is AuthLoggedOut) {
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            }
          },
          child: Container(
              color: Color(0xff18203d),
              padding: EdgeInsets.symmetric(horizontal: width),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildMaterialButton(context, 'PLAY', '/game_settings'),
                  SizedBox(height: 20),
                  _buildMaterialButton(context, 'FIND PLAYERS', '/find_players'),
                ],
              )
          ),
        ),
    );
  }

  MaterialButton _buildMaterialButton(BuildContext context, String text, String path) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        var player = BlocProvider.of<AuthCubit>(context).state.user!;
        Navigator.of(context).pushNamed(path, arguments: {'player': player});
      },
      color: Colors.cyan,
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final authCubit = BlocProvider.of<AuthCubit>(context);
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => authCubit.logOut(),
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  AlertDialog _buildAlertDialog(BuildContext context, AuthInvited state, AuthCubit authCubit) {
    return AlertDialog(
      title: Text('Invitation'),
      content: Text('Player ' + state.player + ' wants you to join his game. Do you accept?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            authCubit.acceptInvitation(false);
            Navigator.of(context).pop();
          },
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            authCubit.acceptInvitation(true);
            Navigator.of(context).pushNamed('/game_settings', arguments:
            {
              'player': state.user!,
              'gameId': state.gameId,
              'serverType': 'firebase'
            });
          },
          child: Text('Yes'),
        ),
      ],
    );
  }
}