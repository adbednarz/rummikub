import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/shared/custom_error_dialog.dart';

class GameScreen extends StatelessWidget {
  final Color logoGreen = Color(0xff25bcbb);

  @override
  Widget build(BuildContext context) {
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
            } else if (state is AuthLoggedOut) {
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            }
          },
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildMaterialButton(context, 'PLAY', '/game_settings'),
                  _buildMaterialButton(context, 'FIND_PLAYERS', '/find_players'),
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
        var playerId = (BlocProvider.of<AuthCubit>(context).state as AuthLogged).user.uid;
        Navigator.of(context).pushNamed(path, arguments: playerId);
      },
      color: logoGreen,
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
            onPressed: () {
              authCubit.logOut();
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}