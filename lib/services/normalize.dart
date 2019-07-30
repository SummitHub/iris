
import 'package:flutter/material.dart';

double normalizedWidth (BuildContext context, double width){
  return ((width/360)*MediaQuery.of(context).size.width);
}
double normalizedheight (BuildContext context, double height){
  return ((height/360)*MediaQuery.of(context).size.height);
}