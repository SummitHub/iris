import 'dart:core' as prefix0;
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/services/MySchedule.dart';
import 'package:iris_flutter/components/appointmentCard.dart';
import 'package:iris_flutter/services/timeHelpers.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';
import 'package:iris_flutter/models/appointments.dart';

handleDayChange(String direction, PageController pageController, currentPage) {
  if (direction == 'right') {
    if (currentPage == 2) {
      pageController.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.ease);
    }
  }
  if (direction == 'left') {
    if (currentPage == 0) {
      pageController.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      pageController.previousPage(duration: Duration(milliseconds: 400), curve: Curves.ease);
    }
  }
}

prettyDayByPage(BuildContext context, currentPage){
    String month, mday, wday;
    switch (currentPage){
      case 0 : 
        month = "de Julho";
        mday = "31";
        wday = "Quarta";
        break;
      case 1 : 
        month = "de Agosto";
        mday = "01º";
        wday = "Quinta";
        break;
      case 2 :  
        month = "de Agosto";
        mday = "02";
        wday = "Sexta";
        break;
      default:
        month = "ERRO";
        mday = "XX";
        wday = "404";
        break;
    } 
    return Container(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(mday, style: TextStyle(fontSize: 46, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700,)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(month.toUpperCase(), style: TextStyle(fontSize: 17.3, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700, height: 0.8)),
              Text(wday.toUpperCase(), style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700,height: 0.8)),
            ],
          )
        ],
      ),
    );
  }

Widget headerSchedule(currentPage, PageController pageController) {
  return Column(
      children: <Widget>[
        SizedBox(
          height: 75,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text("Minha Agenda", style: TextStyle(color: Colors.white, fontSize: 18.5, fontWeight: FontWeight.w900),),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Container(
            child: Consumer<MySchedule>(
              builder: (context, mySchedule , _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => handleDayChange('left', pageController, currentPage),
                    child: Container(
                      color: Colors.transparent,
                      width: 95,
                      child: Center(
                        child: Text("<", 
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  prettyDayByPage(context, currentPage),
                  GestureDetector(
                    onTap: () => handleDayChange('right', pageController, currentPage),
                    child: Container(
                      width: 95,
                      color: Colors.transparent,
                      child: Center(
                        child: Text(">", 
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
}

appointmentList(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context, PageController pageController, CupertinoTabController _tabController) {

  if (snapshot.data.documents.length < 1) return noAppointmentMessage(context, _tabController);
  return snapshot.data.documents.map<Widget>((doc) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right:13.8, bottom: 17.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 13.8),
            child: Container(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.8, right: 6),
                    child: Icon(FontAwesomeIcons.clock, color: Theme.of(context).primaryColor, size: 13.4,),
                  ),
                  Text(
                    convertTimeFromString(doc.data['startTime']), 
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 17.3, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                AppointmentCard(key: UniqueKey(), appointment: convertToAppointment(doc, context), pageController: pageController),
              ],
            ),
          ),
        ],
      ),
    );
  }).toList();  
} 

Widget getAppointmentCard(DocumentSnapshot doc, context) {
  return AppointmentCard(key: UniqueKey(), appointment: convertToAppointment(doc, context),);
}

convertToAppointment(DocumentSnapshot doc, BuildContext context) {
  print(doc.data['confirmed']);
  List titles = normalizeTitles(doc, context, getAppointmentType(doc.data['type']));
  return Appointment(doc.documentID, getAppointmentType(doc.data['type']), titles[0], titles[1], doc.data['startDate'],  doc.data['startTime'],  doc.data['endTime'],  doc.data['location'], doc.data['confirmed']);
}

normalizeTitles(DocumentSnapshot doc, BuildContext context, Type type) { 
  List finalTitles = [];
  if (type == Type.Invitation) {
    finalTitles = handleInvitationTitles(doc.data, context);
  } else if(type == Type.Meeting) {
    finalTitles = handleMeetingTitles(doc.data, context);
  } else if(type == Type.Lecture) {
    finalTitles = handleLectureTitles(doc.data);
  } 
  return finalTitles;
}
handleMeetingTitles(data, context) {
  var user = Provider.of<User>(context);
  String tempNames = '';
  if (data['names'].length > 0) {
    for (String name in data['names']) if (name != user.userName) tempNames += name + ', ';
  }
  print('handling meeting or invite');
  return ['Reunião', tempNames.substring(0,tempNames.length-2)].toList();
}

handleInvitationTitles(data, context) {
  var user = Provider.of<User>(context);
  String tempNames = '';
  if (data['names'].length > 0) {
    for (String name in data['names']) if (name != user.userName) tempNames += name + ', ';
  }
  print('handling meeting or invite');
  return ['Convite para reunião', tempNames.substring(0,tempNames.length-2)].toList();
} 

handleLectureTitles(data) {
  String title = data['title'];
  String subtitle = ';';
  if (data['speakers'] != null) {
    switch (data['speakers'].length){
      case 1 : 
        subtitle = data['speakers'][0]['title'].toString() + ' - ' + data['speakers'][0]['position'] + "/" + data['speakers'][0]['company'];        
        break;
      case 2 : 
        subtitle = data['speakers'][0]['title'].toString() + ' - ' + data['speakers'][0]['position'] + "/" + data['speakers'][0]['company'] + '\n' + data['speakers'][1]['title'].toString() + ' - ' + data['speakers'][1]['position'] + "/" + data['speakers'][1]['company'];        
        break;
      case 3 : 
        subtitle = data['speakers'][0]['title'].toString() + ' - ' + data['speakers'][0]['position'] + "/" + data['speakers'][0]['company']+ '\n' + data['speakers'][1]['title'].toString() + ' - ' + data['speakers'][1]['position'] + "/" + data['speakers'][1]['company']+ '\n' + data['speakers'][1]['title'].toString() + ' - ' + data['speakers'][2]['position'] + "/" + data['speakers'][2]['company'];        
        break;
      case 4 :
        subtitle = data['speakers'][0]['title'].toString() + ' - ' + data['speakers'][0]['position'] + "/" + data['speakers'][0]['company']+ '\n' + data['speakers'][1]['title'].toString() + ' - ' + data['speakers'][1]['position'] + "/" + data['speakers'][1]['company']+ '\n' + data['speakers'][1]['title'].toString() + ' - ' + data['speakers'][2]['position'] + "/" + data['speakers'][2]['company']+ '\n' + data['speakers'][3]['title'].toString() + ' - ' + data['speakers'][3]['position'] + "/" + data['speakers'][3]['company'];
        break;
      case 5 :
        subtitle = data['speakers'][0]['title'].toString() + ' - ' + data['speakers'][0]['position'] + "/" + data['speakers'][0]['company']+ '\n' + data['speakers'][1]['title'].toString() + ' - ' + data['speakers'][1]['position'] + "/" + data['speakers'][1]['company']+ '\n' + data['speakers'][1]['title'].toString() + ' - ' + data['speakers'][2]['position'] + "/" + data['speakers'][2]['company']+ '\n' + data['speakers'][3]['title'].toString() + ' - ' + data['speakers'][3]['position'] + "/" + data['speakers'][4]['company']+ '\n' + data['speakers'][4]['title'].toString() + ' - ' + data['speakers'][4]['position'] + "/" + data['speakers'][4]['company'];
        break;
      default :
        subtitle = data['speakers'][0]['title'].toString() + ' - ' + data['speakers'][0]['position'] + "/" + data['speakers'][0]['company'];        
        break;        
    }
  }
  return [title, subtitle]; 
}

getAppointmentType(String typeString) {
  if (typeString == 'invitation') {
    return Type.Invitation;
  } else if(typeString == 'meeting') {
    return Type.Meeting;
  } else if(typeString == 'lecture') {
    return Type.Lecture;
  } 
}

noAppointmentMessage(BuildContext context, CupertinoTabController _tabController){
  return <Widget>[Container(height: 110,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('NADA NESSE DIA, BORA MARCAR!', 
            style: TextStyle(fontSize: 22, color: Theme.of(context).primaryColor)),
          IconButton(
            icon: Icon(Icons.add_circle), color: Theme.of(context).primaryColor,
            onPressed: () => _tabController.index = 1,
          ),
        ],
      ),
    ),
  )];
}