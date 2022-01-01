import 'package:flutter/material.dart';
import 'package:rummikub/shared/models/player.dart';

class BotSettingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var width = (MediaQuery.of(context).size.width > 500 ? MediaQuery.of(context).size.width / 4 : 40).toDouble();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.lightBlueAccent,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: width),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildMaterialButton(context, 'BASIC BOT', 'basicBot'),
              SizedBox(height: 60),
              _buildMaterialButton(context, 'ADVANCED BOT', 'advancedBot'),
            ],
          )
        ),
    );
  }

  MaterialButton _buildMaterialButton(BuildContext context, String name, String type) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () => Navigator.of(context).pushNamed('/game_settings',
          arguments: {'player': Player('You', '0'), 'serverType': type}),
      color: Colors.teal,
      child: Text(name, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}