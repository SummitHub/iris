import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/models/appointments.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingScreen extends StatefulWidget {
  MeetingScreen(this.appointment, this.pageController);
  final Appointment appointment;
  final PageController pageController;
  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  bool confirmed;
  PageController pageController;
  var guests;

  @override
  void initState() { 
    super.initState();
    confirmed = widget.appointment.extraInfo;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                headerSection(context),
                Container(
                  color: Theme.of(context).secondaryHeaderColor,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      titleAndSubtitle(context),
                      Divider(
                        color: Color(0xFF707070),
                      ),
                      detailsSection(context),
                    ],
                  ),
                ),
                descriptionSection(context),
              ],
            )
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal:27),
              child:
                widget.appointment.type == Type.Invitation
                ? buttonsOverlay(context)
                : buttonOverlay(context, pageController),
            )
          ),
          SizedBox(height: 50,)
        ],
      )
    );
  }

  headerSection(context){
    return Container(
      height: 65,
      color: Theme.of(context).secondaryHeaderColor,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: 56,
              width: 56,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: BackButton(color: Colors.white,)
              )  
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text("Reunião", style: TextStyle(color: Colors.white, fontSize: 18.5, fontWeight: FontWeight.w900),),
            ),
          )
        ],
      ),
    );
  }

  titleAndSubtitle(context){
    //print(lecture.speakers[0].toString());
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 0.0,),
            child: Text((widget.appointment.title.toString()).toUpperCase(), 
              style: TextStyle(fontSize: 36, color: Theme.of(context).primaryColor)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Text(widget.appointment.subtitle.toString().toUpperCase(), 
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 8, color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  detailsSection(context){
    String dia;
    switch (widget.appointment.startDate) {
      case '2019-07-31':
        dia = "31 de Julho";
        break;
      case '2019-08-01':
        dia = "1º de Agosto";
        break;
      case '2019-08-02':
        dia = "2 de Agosto";
        break;
      default:
        dia = "--";
    }
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 1.2),
                  child: Icon(FontAwesomeIcons.calendarAlt, color: Theme.of(context).primaryColor,size: 10),
                ),
                Text(" " + dia, style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor))
              ] 
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 1.2),
                  child: Icon(FontAwesomeIcons.clock, color: Theme.of(context).primaryColor, size: 10),
                ),
                Text(" " + widget.appointment.startTime.substring(0,5) + " - " + widget.appointment.endTime.substring(0,5), style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor))
              ] 
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 1.2),
              child: Row(
                children: <Widget>[
                  Icon(FontAwesomeIcons.mapMarkerAlt, color: Theme.of(context).primaryColor, size: 10),
                  Text(" " + capitalizeString(widget.appointment.location), style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor))
                ] 
              ),
            ),
          ],
        ),
      ),
    );
  }

  descriptionSection(context){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Mais Detalhes",
              style: TextStyle(fontSize: 17.3, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)
            ),
            SizedBox(height: 10),
            StreamBuilder(
              stream: Firestore.instance.collection('meetings').document(widget.appointment.id).collection('guests').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if (!snapshot.hasData){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator()
                      ],
                    ),
                  );
                }
                guests = snapshot.data.documents;
                return Column(children: listOfGuests());
              },
            ),
          ],
        ),
      ),
    );
  }

  listOfGuests(){
    List<Widget> temp = [];
    guests.forEach((document) {
      Color color;
      switch (document.data['status']) {
        case 'confirmed':
          color = Color(0xFF32D17C);
          break;
        case 'unconfirmed':
          color = Color(0xFFECE749);
          break;
        case 'denied':
          color = Color(0xFFFF2E2E);
          break;
        default:
          color = Colors.black;
          break;
      }
      temp.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: <Widget>[
                Icon(Icons.arrow_right, color: color, size: 25,),
                Text(document.data['name'],
                  style: TextStyle(fontFamily: 'CircularBook', fontSize: 15, color: Color(0xFF989898)),
                )
                
              ],
            ),
          ),
        )
      );
    });

    return temp;
  }

  String capitalizeString(String text){
    if (text.length <= 1) return text.toUpperCase();
    var ltext = text.toLowerCase();
    var words = ltext.split(' ');
    var capitalized = words.map((word) {
      var first = word.substring(0, 1).toUpperCase();
      var rest = word.substring(1);
      return '$first$rest';
    });
    return capitalized.join(' ');
  }

  buttonsOverlay(context){
    return Row( 
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            widget.appointment.declineInvite(context);
            Navigator.pop(context);
          }, 
          padding: EdgeInsets.zero,
          child: Container(
            height: 55,
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: 2,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                      ),
                      height: 50,
                      width: normalizedWidth(context, 145),
                      child: Center(child: Text('RECUSAR', style: TextStyle(fontWeight: FontWeight.w800, color:Theme.of(context).primaryColor, fontSize: 13.8))),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width: 4,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                      ),
                      height: 50,
                      width: normalizedWidth(context, 143),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        FlatButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            widget.appointment.acceptInvite(context);
            Navigator.pop(context);
          }, 
          child: Container(
            height: 55,
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(height: 2,),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                      ),
                      height: 50,
                      width: normalizedWidth(context, 145),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width: 4,),
                    Container(
                      height: 50,
                      width: normalizedWidth(context, 143),
                      color: Theme.of(context).primaryColor,
                      child: Center(child: Text('ACEITAR', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  buttonOverlay(BuildContext context, PageController pageController){
    return FlatButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        widget.appointment.remove(context);
        Navigator.pop(context);
        pageController.jumpTo(widget.pageController.page);
      }, 
      child: Container(
        height: 65,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(height: 2,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                  ),
                  height: 60,
                  width: normalizedWidth(context, 292),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: 4,),
                Container(
                  height: 60  ,
                  width: normalizedWidth(context, 290),
                  color: Theme.of(context).primaryColor,
                  child: Center(child: Text('CANCELAR/REMOVER', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}