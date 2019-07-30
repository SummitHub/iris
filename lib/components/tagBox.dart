  
  import 'package:flutter/material.dart';

tagBox(String text, context, borderColor, bgColor){
    return Chip(
      padding: EdgeInsets.zero,
      labelPadding: EdgeInsets.symmetric(horizontal: 19.5, vertical: 0),
      backgroundColor: bgColor,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.zero), 
        side: BorderSide(width: 0.3, color: borderColor)
      ),
      label: Text(text, style: text=='+'? TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor)
      : TextStyle(fontSize: 8.7, fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor)),
    );
  }