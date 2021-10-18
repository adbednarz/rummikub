import 'package:flutter/material.dart';

class HomeScreen  extends StatelessWidget {
  final Color logoGreen = Color(0xff25bcbb);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildMaterialButton(context, 'login'),
              SizedBox(height: 20),
              _buildMaterialButton(context, 'registration'),
            ],
          )
      ),
    );
  }

  _buildMaterialButton(BuildContext context, String path) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
          Navigator.of(context).pushNamed('/' + path);
      },
      color: logoGreen,
      child: Text(path.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}