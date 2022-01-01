import 'package:flutter/material.dart';

class HomeScreen  extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var width = (MediaQuery.of(context).size.width > 500 ? MediaQuery.of(context).size.width / 4 : 40).toDouble();
    return Scaffold(
      backgroundColor: Color(0xff18203d),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: width),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildMaterialButton(context, '/login', 'LOGIN'),
              SizedBox(height: 20),
              _buildMaterialButton(context, '/registration', 'REGISTRATION'),
              SizedBox(height: 20),
              _buildMaterialButton(context, '/bot_settings', 'PLAY WITH BOT'),
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
      onPressed: () => Navigator.of(context).pushNamed(path),
      color: Colors.cyan,
      child: Text(name, style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}