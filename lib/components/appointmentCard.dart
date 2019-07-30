import 'package:flutter/material.dart';
import 'package:iris_flutter/models/appointments.dart';
import 'package:iris_flutter/screens/LectureScreen.dart';
import 'package:iris_flutter/screens/MeetingScreen.dart';
import 'package:iris_flutter/services/Lectures.dart';
import 'package:provider/provider.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({Key key, this.appointment, this.pageController}) : super(key: key);
  final Appointment appointment;
  final PageController pageController;
  @override
  _AppointmentCardState createState() => _AppointmentCardState(appointment);
}

class _AppointmentCardState extends State<AppointmentCard> {
  _AppointmentCardState(this.appointment);
  Appointment appointment;
  Color bgcolor = Colors.grey;
  Color fColor = Colors.white;
  String dismissedText;
  List<Widget> cardText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    switch (appointment.type){
      case Type.Lecture:
        switch (appointment.location){
            case 'principal': 
              bgcolor = Theme.of(context).primaryColor;
              fColor = Colors.white;
              break;
            case 'share': 
              bgcolor = Color(0xFF5D2F88);
              fColor = Color(0xFFFFFFFF);
              break;
            case 'comunidade': 
              bgcolor = Color(0xFF1EAAF4);
              fColor = Color(0xFFE1EC49);
              break;
            default:  
              bgcolor = Color(0xFF1EAAF4);
              fColor = Color(0xFFE1EC49);
              break;
          }
        cardText = [
          Text(appointment.title.toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: fColor, fontSize: 21.1, fontWeight: FontWeight.w800)),
          Text(appointment.subtitle.toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: fColor, fontSize: 6.72, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, height: 1.2)),
        ];
        dismissedText = "Palestra removida da agenda";
        break;
      case Type.Meeting: 
        if (!appointment.extraInfo) {
          bgcolor = Colors.white60;
          fColor = Theme.of(context).secondaryHeaderColor;
          dismissedText = "Convite para reunião recusado";
          cardText = [
            Text(appointment.title.toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: fColor, fontSize: 21.1, fontWeight: FontWeight.w800)),
            Text(appointment.location.toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: fColor, fontSize: 6.72, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, height: 1.2)),
          ];
        } else {
          bgcolor = Theme.of(context).secondaryHeaderColor;
          fColor = Colors.white;
          dismissedText = "Reunião removida da agenda";
          cardText = [
            Text(appointment.title.toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: fColor, fontSize: 21.1, fontWeight: FontWeight.w800)),
            Text(appointment.location.toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: fColor, fontSize: 6.72, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, height: 1.2)),
          ];
        }
        break;
    case Type.Invitation:
      bgcolor = Colors.white60;
      fColor = Theme.of(context).secondaryHeaderColor;
      dismissedText = "Convite para reunião recusado";
      cardText = [
          Text(appointment.title.toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: fColor, fontSize: 21.1, fontWeight: FontWeight.w800)),
          Text(appointment.location.toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: fColor, fontSize: 6.72, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, height: 1.2)),
        ];
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.3),
      child: Dismissible(
        key: Key(UniqueKey().toString()),
        onDismissed: (direction) => {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(dismissedText))),
          appointment.remove(context),
          widget.pageController.jumpTo(widget.pageController.page),
        },
        child: GestureDetector(
          onTap: () => appointment.type == Type.Lecture
            ? openLectures()
            : Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
            builder: (context) => MeetingScreen(appointment, widget.pageController)
            )),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomPaint(
                size: Size(15, 18.3),
                painter: TrianglePainter(bgcolor),
              ),
              Expanded(
                  child: Container(
                  color: bgcolor,
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.8, left: 17.2, right: 17.2, bottom: 6.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cardText
                    ),
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  openLectures(){
    var lectures = Provider.of<Lectures>(context);
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      builder: (context) => LectureScreen(lectures.lectures.singleWhere((lecture) => lecture.id == appointment.id))
    ));
  }




}

class TrianglePainter extends CustomPainter {
  TrianglePainter(this.bgcolor);
  final Color bgcolor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = bgcolor;
    var path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height/2);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    //path.lineTo(0, size.height);
    //path.lineTo(0, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(TrianglePainter oldDelegate) => false;
}