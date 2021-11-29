import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  final String title, text;

  CustomErrorDialog(this.title, this.text);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Container contentBox(context) {
    return Container(
      padding: EdgeInsets.only(left: 20,top: 40, right: 20, bottom: 20
      ),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black,offset: Offset(0,10),
                blurRadius: 10
            ),
          ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
          SizedBox(height: 15,),
          Text(text, style: TextStyle(fontSize: 14), textAlign: TextAlign.center,),
          SizedBox(height: 22,),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                  },
                child: Text('Ok', style: TextStyle(fontSize: 18),)),
          ),
        ],
      ),
    );
  }
}