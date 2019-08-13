import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iris_flutter/services/Lectures.dart';
import 'package:iris_flutter/components/lectureWidgets.dart';
import 'package:iris_flutter/models/lecture.dart';


class NextLecturesWidget extends StatefulWidget {
  NextLecturesWidget(this.numberOfLectures);
  final int numberOfLectures;

  _NextLecturesWidgetState createState() => _NextLecturesWidgetState();
}

class _NextLecturesWidgetState extends State<NextLecturesWidget> {
int currentDay;
List<Lecture> todaysLectures;

  @override
  void initState() {
    super.initState();
    switch (DateTime.now().day.toInt()){
      case 31: 
        currentDay = 0;
        break;
      case 1: 
        currentDay = 1;
        break;
      case 2:  
        currentDay = 2;
        break;
      default:
        currentDay = 0;
        break;
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 248,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                height: 120, 
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        color: Color(0xFFE5E5E5)
                      ,)
                    ,)
                  ],
                ),
              ),
              SizedBox(
                height: 120, 
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        color: Color(0xFFE5E5E5)
                      ,)
                    ,)
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          height: 248,
           child: Consumer<Lectures>(
            builder: (BuildContext context, lectures, Widget child) {
              if (lectures.shouldFetchData) {
                return SizedBox();
              }
              todaysLectures = lectures.groupedLectures[currentDay];
              todaysLectures.removeWhere((lec) =>  lec.startDateTime.isBefore(DateTime.now()));
              if (todaysLectures.length < 1) {
                if (currentDay == 2) return SizedBox(
                  height: 248,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 10),
                    child: Text("Próxima palestra dia 05/08/2020.\n Garanta o seu ingresso antecipado!", style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontSize: 18, fontWeight: FontWeight.w800), textAlign: TextAlign.center,),
                  ),
                );
                else todaysLectures = (lectures.groupedLectures[currentDay+1]);
              }
              return ListView.builder(
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.numberOfLectures,
                itemBuilder: (context, position) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: lectureCard( context, todaysLectures[position]),
                  );
                },
              );
            }
          )
        ),
      ],
    );
  }
}