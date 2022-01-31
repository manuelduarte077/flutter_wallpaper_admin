import 'package:flutter/material.dart';



Widget emptyPage (icon, messgae){
  return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
        Icon(icon, size: 60, color: Colors.grey,),
        SizedBox(height: 10,),
        Text(messgae, style: TextStyle(fontSize: 18, color:Colors.grey, fontWeight: FontWeight.w600),)
      ],),
    );
}