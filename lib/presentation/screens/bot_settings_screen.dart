import 'package:flutter/material.dart';

class BotSettingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.lightBlueAccent,
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
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
          arguments: {'playerId': '0', 'serverType': type}),
      color: Colors.teal,
      child: Text(name, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}