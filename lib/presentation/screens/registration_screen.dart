import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rummikub/logic/auth_cubit.dart';
import 'package:rummikub/shared/custom_error_dialog.dart';

class RegistrationScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Color(0xff18203d),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showDialog(
                  context: context,
                  builder: (context) => CustomErrorDialog('Error', state.errorMessage)
              );
            } else if (state is AuthLogged) {
              Navigator.of(context).pushNamed('/game', arguments: BlocProvider.of<AuthCubit>(context));
            }
          },
          builder: (context, state) {
            if (state is AuthLoading || state is AuthLogged) {
              return Center(
                child: CircularProgressIndicator()
              );
            }
            return Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: SingleChildScrollView(
                child: _buildForm(context),
              ),
            );
          }
        )
    );
  }

  Container _buildForm(BuildContext context) {
    return Container(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildTextFormField(Icons.email, 'Email', emailController),
              SizedBox(height: 20),
              _buildTextFormField(Icons.account_circle, 'Username', usernameController),
              SizedBox(height: 20),
              _buildTextFormField(Icons.lock, 'Password', passwordController),
              SizedBox(height: 20),
              _buildTextFormField(Icons.lock, 'Confirm Password', confirmPasswordController),
              SizedBox(height: 30),
              _buildMaterialButton(context),
            ],
          ),
        )
    );
  }

  Container _buildTextFormField(IconData icon, String labelText, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Color(0xff232c51), border: Border.all(color: Colors.blue)),
      child: TextFormField(
        controller: controller,
        obscureText: labelText.endsWith('Password') ? true : false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$labelText cannot be empty';
          } else if (labelText == 'Password' && value.length < 6) {
            return 'At least 6 characters';
          } else if (labelText == 'Confirm Password') {
            if (passwordController.text != confirmPasswordController.text) {
              return 'Confirm password is different';
            }
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

  MaterialButton _buildMaterialButton(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        if (_formKey.currentState!.validate()) {
            BlocProvider.of<AuthCubit>(context).register(
                email: emailController.text,
                username: usernameController.text,
                password: passwordController.text);
        }
      },
      color: Colors.cyan,
      child: Text('REGISTER', style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}