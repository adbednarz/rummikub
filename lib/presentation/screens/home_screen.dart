import 'package:flutter/material.dart';

class HomeScreen  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff18203d),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildMaterialButton(context, '/login', 'LOGIN'),
              SizedBox(height: 20),
              _buildMaterialButton(context, '/registration', 'REGISTRATION'),
              SizedBox(height: 20),
              _buildMaterialButton(context, '/play_with_bot', 'PLAY WITH BOT'),
            ],
          )
      ),
    );
  }

  MaterialButton _buildMaterialButton(BuildContext context, String path, String name) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        if (path == '/play_with_bot') {
          Navigator.of(context).pushNamed('/game_settings', arguments: {'playerId': '0'});
          // Navigator.of(context).pushNamed('/play_with_bot', arguments: {'gameId': '0', 'playerId': '0'});
        } else {
          Navigator.of(context).pushNamed(path);
        }
      },
      color: Colors.cyan,
      child: Text(name, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}