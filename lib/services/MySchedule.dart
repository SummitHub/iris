import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:iris_flutter/models/meeting.dart';
import 'package:iris_flutter/services/Lectures.dart';
import 'package:iris_flutter/models/appointments.dart';
import 'package:iris_flutter/models/lecture.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';

class MySchedule with ChangeNotifier{

  Future addLecture(Lecture lec, BuildContext context) async {
    var user = Provider.of<User>(context);
    addAppointmentToDB(user.id, context, Type.Lecture, lec.id);
  } 

  Future<bool> checkAppointment(String appointmentId, BuildContext context) async {
    var user = Provider.of<User>(context);
    bool exists = await Firestore.instance.collection('users').document(user.id).collection('schedule').document(appointmentId).get().then((doc) => doc.exists);
    return exists;
  }

  addMeeting(BuildContext context, List<Map<String,dynamic>> meeting, List<Map<String, String>> guests, String currentUserName) async {
    var user = Provider.of<User>(context);
    await createMeeting(user.id, meeting, guests).then( (meetingID) {
      addAppointmentToDB(user.id, context, Type.Meeting, meetingID);
    });
    notifyListeners();
  }

  removeAppointment(String appointmentId, BuildContext context, Type type){
    print("MySchedule.dart: Removing Appointment: " + appointmentId);
    var user = Provider.of<User>(context);
    removeAppointmentFromDB(user.id, type, appointmentId);
    print("MySchedule.dart: Removed Appointment: " + appointmentId + ". Notifying...");
  }

  acceptMeeting(String id, BuildContext context)async{
    var user = Provider.of<User>(context);
    await moveIdtoMeetings(user.id, id);
    await updateMeetingStatus(user.id, id);
    removeAppointment(id, context, Type.Meeting);
    notifyListeners();
  }

  declineMeeting(String id, BuildContext context) async{
    var user = Provider.of<User>(context);
    await Firestore.instance.collection('meetings').document(id).collection('guests').document(user.id).updateData({'status' : "denied"});
    removeAppointment(id, context, Type.Meeting);
    notifyListeners();
   }


  Future<void> removeAppointmentFromDB(String myId, Type type, String id) async {
    if (type == Type.Lecture) {
      await Firestore.instance.collection('users').document(myId).collection('schedule').document(id).delete();
    } else deleteMeeting(myId, id);
  }

  Future<void> addAppointmentToDB(String myId, BuildContext context, Type type, String id) async {
    if (type == Type.Lecture) {
      var lectures = Provider.of<Lectures>(context);
      var agendaLecture;
      agendaLecture = lectures.groupedLectures[0].singleWhere((item) => item.id == id, orElse: () => lectures.groupedLectures[1].singleWhere((item) => item.id == id, orElse: () => lectures.groupedLectures[2].singleWhere((item) => item.id == id)));
      List speakers = agendaLecture.speakers;
      List filteredSpeakers = [];
      speakers.forEach((speaker) {
        filteredSpeakers.add({
          'id': speaker['_id'],
          'title': speaker['title'],
          'position': speaker['position'],
          'company': speaker['company']
        });
      }); 

      Firestore.instance.collection('users').document(myId).collection('schedule').document(id).setData({ 
          'id': id, 
          'type': 'lecture', 
          'title': agendaLecture.title,
          'startDate': agendaLecture.startDate,
          'startTime': agendaLecture.startTime,
          'speakers': filteredSpeakers,
          'endTime': agendaLecture.endTime,
          'location': agendaLecture.location,
        });// adiciona a meeting no schedule do usuário
    } else if (type == Type.Meeting) {
      Firestore.instance.collection('meetings').document(id).get().then((doc) {
        Firestore.instance.collection('users').document(myId).collection('schedule').document(id).setData({
        'id' : doc.documentID, 
        'startDate' : doc.data['startDate'],
        'startTime' : doc.data['startTime'],
        'endTime' : doc.data['endTime'],
        'location' : doc.data['location'],
        'hostId' : doc.data['hostId'],
        'hostName' : doc.data['hostName'],
        'names' : doc.data['names'],
        'confirmed' : doc.data['confirmed'],
        'type' : 'meeting',
      }); 
      });
    } else if (type == Type.Invitation) {
        Firestore.instance.collection('meetings').document(id).get().then((doc) {
          Firestore.instance.collection('users').document(myId).collection('schedule').document(id).setData({
          'id' : doc.documentID, 
          'startDate' : doc.data['startDate'],
          'startTime' : doc.data['startTime'],
          'endTime' : doc.data['endTime'],
          'location' : doc.data['location'],
          'hostId' : doc.data['hostId'],
          'hostName' : doc.data['hostName'],
          'names' : doc.data['names'],
          'confirmed' : doc.data['confirmed'],
          'type' : 'invitation',
        }); 
      });
    }
  }
  
  Future<String> createMeeting(String myId, List<Map<String,dynamic>> meetingInfos, guests) async {
    String meetingID =  await Firestore.instance.collection('meetings').add(meetingInfos[0]).then((doc) {
      Firestore.instance.collection('users').document(myId).collection('schedule').document(doc.documentID).setData(meetingInfos[1]); // adiciona a meeting no schedule do usuário
      guests.forEach((guest) {
        Firestore.instance.collection('meetings').document(doc.documentID).collection('guests').document(guest['id']).setData({'name': guest['name'], 'status': 'unconfirmed'});
        Firestore.instance.collection('users').document(guest['id']).collection('schedule').document(doc.documentID).setData(meetingInfos[1]); // adiciona a meeting no schedule do convidado
        Firestore.instance.collection('users').document(myId).collection('schedule').document(doc.documentID).collection('guests').document(guest['id']).setData({'name': guest['name'],'id': guest['id']}); // adiciona os convidados nas informações da meeting no schedule
        Firestore.instance.collection('users').document(guest['id']).collection('schedule').document(doc.documentID).collection('guests').document(guest['id']).setData({'name': guest['name'],'id': guest['id']}); // adiciona os convidados nas informações da meeting no schedule
      });
      return doc.documentID;
    });
   return meetingID;
  }

  deleteMeeting(String myId, String meetingId) async {
    await Firestore.instance.collection('meetings').document(meetingId).get().then((meeting) async {
      if (meeting.data['hostId'] == myId) {
        await Firestore.instance.collection('meetings').document(meetingId).collection('guests').getDocuments().then((guests) {
          guests.documents.forEach((guest) async {
              await Firestore.instance.collection('users').document(guest.documentID).collection('schedule').document(meetingId).collection('guests').getDocuments().then((doc) {
                doc.documents.forEach((doc) async {
                  await doc.reference.delete();
                });
              }); 
              await Firestore.instance.collection('users').document(guest.documentID).collection('schedule').document(meetingId).delete();
          });
        });
        await Firestore.instance.collection('meetings').document(meetingId).collection('guests').getDocuments().then((doc) {
          doc.documents.forEach((doc) async {
            await doc.reference.delete();
          });
        }); 
        await Firestore.instance.collection('meetings').document(meetingId).delete();
      } 
      else {


        await Firestore.instance.collection('meetings').document(meetingId).collection('guests').document(myId).updateData({'status' : "denied"});
        await Firestore.instance.collection('meetings').document(meetingId).collection('guests').getDocuments().then( (guests) async {
          if (guests.documents.length <= 1) {
            await Firestore.instance.collection('meetings').document(meetingId).collection('guests').getDocuments().then((doc) {
              doc.documents.forEach((doc) async {
                await doc.reference.delete();
              });
            }); 
            await Firestore.instance.collection('meetings').document(meetingId).delete();
          }
        });

        //se só tu falta recusar, deletar reunião
        //se mais ninguem confirmou, taca status pra unconfirmed

      }
    });
    await Firestore.instance.collection('users').document(myId).collection('schedule').document(meetingId).collection('guests').getDocuments().then((doc) {
      doc.documents.forEach((doc) async {
        await doc.reference.delete();
      });
    }); 
    await Firestore.instance.collection('users').document(myId).collection('schedule').document(meetingId).delete();
  }

  moveIdtoMeetings(String myId, String id) async {
    await Firestore.instance.collection('users').document(myId).collection('schedule').document(id).updateData({ 'type': 'meeting' });
    await Firestore.instance.collection('meetings').document(id).collection('guests').getDocuments().then((guests) {
      guests.documents.forEach((guest) async {
        await Firestore.instance.collection('users').document(guest.documentID).collection('schedule').document(id).updateData({'type': 'meeting' });
      });
    });
  }

  updateMeetingStatus(String myId, String id) async {
    await Firestore.instance.collection('meetings').document(id).collection('guests').document(myId).updateData({'status' : "confirmed"});
    await Firestore.instance.collection('meetings').document(id).updateData( {'confirmed' : true});

    await Firestore.instance.collection('users').document(myId).collection('schedule').document(id).updateData({'confirmed': true });
    await Firestore.instance.collection('meetings').document(id).collection('guests').getDocuments().then((guests) {
      guests.documents.forEach((guest) async {
        await Firestore.instance.collection('users').document(guest.documentID).collection('schedule').document(id).updateData({'confirmed': true });
      });
    });
  }





}

