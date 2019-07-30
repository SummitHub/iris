 import 'package:flutter/cupertino.dart';
 import 'package:flutter/material.dart';

tagScrollView(BuildContext context, List<String> tags){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: ListView.builder(
        itemCount: tags.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index){
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              backgroundColor: Color(0xFFDEDEDE),
              label: Text(tags[index], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF5F5F5F))),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
          );
        }        
      ),
    ),
  );
}