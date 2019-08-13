import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iris_flutter/screens/ChatScreen.dart';
import 'package:iris_flutter/services/chat.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:iris_flutter/screens/SearchScreen.dart';
import 'package:provider/provider.dart';

class ListOfChats extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).secondaryHeaderColor,
              height: 75,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text("Chat", style: TextStyle(color: Colors.white, fontSize: 18.5, fontWeight: FontWeight.w900),),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ChatWidget()
            )
          ],
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white, size: 28,),
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => SearchScreen()
        ))
      ),
    );
  }
}

class ChatWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Chat>(
        builder: (context, chat, _) {
          var user = Provider.of<User>(context);
          return Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('users').document(user.id).collection('activeChats').orderBy("timestamp", descending: true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator()
                      ],
                    ),
                  );
                return ListView(children: listUsers(snapshot, context));
              }
            ),
          );
        }
    );
  }
}

listUsers(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context){
  var user = Provider.of<User>(context);
  return snapshot.data.documents
      .map((doc) {
        String hostName = doc.data['name'].toString().isNotEmpty ? doc.data['hostName'] : 'Participante';
        String hostPosition = doc.data['position'].toString().isNotEmpty ? doc.data['hostPosition'] : 'Visitante';
        String hostImage = doc.data['position'].toString().isNotEmpty ? doc.data['hostImage'] : 'https://scontent.fpoa2-1.fna.fbcdn.net/v/t1.0-0/p370x247/41654574_716754288671534_4855720008577187840_n.png?_nc_cat=106&_nc_oc=AQmSgepAIMZTr-wV3AbJvRoLRwY4UQgwM_Wlg5-kIu8aNXlCbCBEono7gzmGaVkLHZw&_nc_ht=scontent.fpoa2-1.fna&oh=1ce63ce35551f007b6b0c73ed783c025&oe=5DABF9B3';

        String guestName = doc.data['name'].toString().isNotEmpty ? doc.data['guestName'] : 'Participante';
        String guestPosition = doc.data['position'].toString().isNotEmpty ? doc.data['guestPosition'] : 'Visitante';
        String guestImage = doc.data['position'].toString().isNotEmpty ? doc.data['guestImage'] : 'https://scontent.fpoa2-1.fna.fbcdn.net/v/t1.0-0/p370x247/41654574_716754288671534_4855720008577187840_n.png?_nc_cat=106&_nc_oc=AQmSgepAIMZTr-wV3AbJvRoLRwY4UQgwM_Wlg5-kIu8aNXlCbCBEono7gzmGaVkLHZw&_nc_ht=scontent.fpoa2-1.fna&oh=1ce63ce35551f007b6b0c73ed783c025&oe=5DABF9B3';


        DateTime date = doc.data['timestamp'].toDate();
        //print("+++" + doc.data['involvedUsers'].toString());
        return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: GestureDetector(
          onTap: () => {
            doc.data['involvedUsers'][0] == user.id 
            ? openChat(doc.data['involvedUsers'][1], context, guestName, guestImage, guestPosition)
            : openChat(doc.data['involvedUsers'][0], context, hostName, hostImage, hostPosition)
          },
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      height: 90, 
                      width: 90,
                      child: CachedNetworkImage(placeholder: (context, url) => LinearProgressIndicator(), imageUrl: doc.data['involvedUsers'][0] == user.id ? guestImage: hostImage, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: normalizedWidth(context, 180)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(doc.data['involvedUsers'][0] == user.id ? guestName : hostName, style: TextStyle(fontSize: 16, color: Color(0xFF666666), fontWeight: FontWeight.bold), maxLines: 1,),
                                Text(doc.data['involvedUsers'][0] == user.id ? guestPosition : hostPosition, style: TextStyle(fontSize: 10.5, color: Color(0xFFACACAC), fontWeight: FontWeight.w300 ), maxLines: 1),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Text(doc.data['latest'], style: TextStyle(fontSize: 14, color: Color(0xFFb8b8b8), fontWeight: FontWeight.w300,), maxLines: 1,),
                          ],
                        ),
                      ),
                    ),
                  ]
                ),
                Container(
                  height: 90,
                  child: Padding(
                    padding: EdgeInsets.only(right: 14.0, top: 8),
                    child: Text(date.hour.toString() + ":" + (date.minute < 10 ? '0' + date.minute.toString() : date.minute.toString()), style: TextStyle(fontSize: 9.6, color: Color(0xFFCECECE))),
                  )
                )
              ],
            ),
          ),
        ),
      );
    }).toList();  

}


openChat(String otherUserID, BuildContext context, String otherUserName, String otherUserPicture, String otherUserPosition) async {
  var user = Provider.of<User>(context);
  String _userID = user.id;
  print("---opening chat with: " + otherUserName); 
  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
    builder: (context) => ChatScreen(otherUserID, _userID, context, otherUserName, otherUserPicture, otherUserPosition)
  ));
}