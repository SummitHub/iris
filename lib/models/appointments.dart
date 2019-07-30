import 'package:iris_flutter/services/MySchedule.dart';
import 'package:provider/provider.dart';
enum Type { Lecture, Meeting, Invitation }

class Appointment {
  String id;
  Type type;
  String title;
  String subtitle;
  String startDate;
  String startTime;
  String endTime;
  String location;
  var extraInfo;
  
  DateTime startDateTime;
  DateTime endDateTime;

  Appointment(this.id, this.type, this.title, this.subtitle, this.startDate, this.startTime, this.endTime, this.location, this.extraInfo){
      startDateTime = DateTime.parse(startDate.toString() + ' ' + startTime.toString());
      endDateTime = DateTime.parse(startDate.toString() + ' ' + endTime.toString());
  }
  
  remove(context){
    type==Type.Invitation 
    ? declineInvite(context) 
    : Provider.of<MySchedule>(context).removeAppointment(id, context, type);
  }

  acceptInvite(context){
    Provider.of<MySchedule>(context).acceptMeeting(id, context);
  }

  declineInvite(context){
    Provider.of<MySchedule>(context).declineMeeting(id, context);
  }
}
