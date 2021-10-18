import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final Color primaryColor = Color(0xff18203d);
  final Color secondaryColor = Color(0xff232c51);

  final Color logoGreen = Color(0xff25bcbb);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: primaryColor,
        body: Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: _buildForm(context),
          ),
        ));
  }

  _buildForm(BuildContext context) {
    return Container(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildTextFormField(Icons.account_circle, 'Username'),
              SizedBox(height: 20),
              _buildTextFormField(Icons.lock, 'Password'),
              SizedBox(height: 30),
              _buildMaterialButton(context),
            ],
          ),
        )
    );
  }

  _buildTextFormField(IconData icon, String labelText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: secondaryColor, border: Border.all(color: Colors.blue)),
      child: TextFormField(
        controller: labelText == 'Username' ? emailController : passwordController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$labelText cannot be empty';
          } else if (labelText == 'Username') {

          } else {

          }
          return null;
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.white),
            icon:
              Icon(icon, color: Colors.white),
              border: InputBorder.none),
      ),
    );
  }

  _buildMaterialButton(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          Navigator.of(context).pushNamed(
            '/',
          );
        }
      },
      color: logoGreen,
      child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}