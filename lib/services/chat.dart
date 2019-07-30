import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/components/chatWidgets.dart';


class Chat with ChangeNotifier {

  confirmChatRoom(List userChats, String userID, String otherUserID, String chatID) async {
      createChatRoom(chatID, userID, otherUserID);
  }

  messagesBuilder(String userID, String otherUserID, ScrollController scrollController){
    List involvedUsers = [userID, otherUserID];
    involvedUsers.sort();
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('chatRooms').document(involvedUsers[0]+'+'+involvedUsers[1]).collection('messages').orderBy('timestamp').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        Timer(Duration(milliseconds: 1), () => scrollController.jumpTo(scrollController.position.maxScrollExtent));
        return ListView(
          padding: EdgeInsets.only(top: 11.5),
          controller: scrollController, 
          children: listMessages(snapshot, context, userID));
      }
    );
  }

  void sendMessage(String content, String chatID, String userID, String otherUserID) async {
    List involvedUsers = [userID, otherUserID];
    involvedUsers.sort();
    var hostUser = await Firestore.instance.collection('users').document(involvedUsers[0]).get();
    var guestUser = await Firestore.instance.collection('users').document(involvedUsers[1]).get();
    Map<String, dynamic> message = {
      'content': content,
      'senderID': userID,
      'recieverID': otherUserID,
      'timestamp': Timestamp.now()
    };
    Map<String, dynamic> latestMessage = {
      'latest': content,
      'timestamp': Timestamp.now(),
      'involvedUsers': involvedUsers,
      'hostName': hostUser['name'],
      'hostImage': hostUser['picture'],
      'hostPosition': hostUser['position']+ ' em '+ hostUser['company'],
      'guestName': guestUser['name'],
      'guestImage': guestUser['picture'],
      'guestPosition': guestUser['position']+ ' em '+ guestUser['company'],
    };
    Firestore.instance.collection('chatRooms').document(involvedUsers[0]+'+'+involvedUsers[1]).collection('messages').document().setData(message);
    Firestore.instance.collection('users').document('$userID').collection('activeChats').document(involvedUsers[0]+'+'+involvedUsers[1]).setData(latestMessage);
    Firestore.instance.collection('users').document('$otherUserID').collection('activeChats').document(involvedUsers[0]+'+'+involvedUsers[1]).setData(latestMessage);
  }                                               

  createChatRoom(String chatID, String userID, String otherUserID) async {
    var chatID;
    List involvedUsers = [userID, otherUserID];
    involvedUsers.sort();
   
    Map<String, List> info = {
      'involvedUsers': involvedUsers,
    };

    await Firestore.instance.collection('chatRooms').document(involvedUsers[0]+'+'+involvedUsers[1]).setData(info)
      .then((onValue) => {      
      Firestore.instance.collection('users').document('$userID').updateData({'chats': FieldValue.arrayUnion([Firestore.instance.collection('chatRooms').document(involvedUsers[0]+'+'+involvedUsers[1]).documentID])}),
      print('ADICIONANDO CHATROOM NO SEU USUÁRIO'),
      Firestore.instance.collection('users').document('$otherUserID').updateData({'chats': FieldValue.arrayUnion([Firestore.instance.collection('chatRooms').document(involvedUsers[0]+'+'+involvedUsers[1]).documentID])}),
      print('ADICIONANDO CHATROOM NO OUTRO USUÁRIO'),
      chatID = involvedUsers[0]+'+'+involvedUsers[1],
    });

    return chatID;
  }

}
