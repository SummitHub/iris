import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';

class Invitations with ChangeNotifier {

  createInvitation(context, meetingInfo ){
    List<String> receivers = [];
    meetingInfo['guests'].forEach((Map<String,String> map){
      receivers.add(map['id'].toString());
    });
    print("Enviando invitation para: " + receivers.toString());

    sendInvitation(context, meetingInfo, receivers);
  }

  cancelInvitation(){
  }

  acceptInvitation(){
  }

  declineInvitation(){
  }

  Future sendInvitation(BuildContext context, Map<String,dynamic> meetingInfo, List<String> receivers) async {
    var _user = Provider.of<User>(context);
    await Firestore.instance.collection('invitations').add(meetingInfo).then((docID) {
      Firestore.instance.collection('users').document(_user.id).collection("myInvitations").document(docID.documentID).setData(meetingInfo);
      receivers.forEach((guestID) => Firestore.instance.collection('users').document(guestID).collection("myInvitations").document(docID.documentID).setData(meetingInfo));
    });
  }

}