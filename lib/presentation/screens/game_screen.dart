import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/shared/custom_error_dialog.dart';

class GameScreen extends StatelessWidget {
  final Color logoGreen = Color(0xff25bcbb);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                showDialog(
                  context: context,
                  builder: (context) =>
                      CustomErrorDialog("Error", state.errorMessage)
                );
              } else if (state is AuthLoggedOut) {
                Navigator.of(context).pop();
              }
            },
            builder: (context, state) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildMaterialButton(context, 'game_settings', 'PLAY'),
                  ],
                )
              );
            }
          )
        ),
        onWillPop: () async {
          return _onWillPop(context);
        },
    );
  }

  _buildMaterialButton(BuildContext context, String path, String text) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        Navigator.of(context).pushNamed('/' + path);
      },
      color: logoGreen,
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);
    return await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: new Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authCubit.logOut();
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    );
  }
}