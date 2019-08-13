import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/services/chat.dart';
import 'package:provider/provider.dart';

listMessages(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context, userID){

  String lastMessageSenderId = '';
  List<int> changedUser = [];

  snapshot.data.documents.forEach((doc) {
    if(snapshot.data.documents.indexOf(doc) == 0) lastMessageSenderId = doc['senderID'];
    if (doc['senderID'] != lastMessageSenderId) changedUser.add(snapshot.data.documents.indexOf(doc));
    if (snapshot.data.documents.indexOf(doc) == snapshot.data.documents.length-1) changedUser.add(snapshot.data.documents.indexOf(doc)+1);
    lastMessageSenderId = doc['senderID'];
  }); 

  print("LISTA DE NUMEROS ORIGINAIS: " + changedUser.toString());
  changedUser.forEach((num) => changedUser[changedUser.indexOf(num)] = num-1);
  print("LISTA DE NUMEROS SHIFTADOS: " + changedUser.toString());

  var messages = snapshot.data.documents.map((doc) {
    bool hasTriangle = (changedUser.contains(snapshot.data.documents.indexOf(doc)));
      return messageContainer(doc['content'], doc['senderID'], userID, doc['timestamp'], hasTriangle);  
  }).toList();  

  return messages;
}

Widget messageContainer(String content, String senderID, String userID, Timestamp time, bool hasTriangle){
  DateTime date = time.toDate();
  bool ownMessage = (senderID == userID);
  Color color =  ownMessage ?   Color(0xFF8E8E8E) : Colors.white;
  return Stack(
    children: <Widget>[
      if (hasTriangle) 
        ownMessage ? 
        Positioned(
          right: 10,
          bottom: 14.5,
          child: Container(
            height: 15,
            width: 25,
            child: CustomPaint(
                  size: Size(15, 15),
                  painter: BaloonTriangle(ownMessage),
                ),
          ),
        ) :
        Positioned(
          left: 10,
          bottom: 14.5,
          child: Container(
            height: 15,
            width: 25,
            child: CustomPaint(
                  size: Size(15, 15),
                  painter: BaloonTriangle(ownMessage),
                ),
          ),
        ),
      Row(
          children: <Widget>[
            if (ownMessage) Expanded(child: SizedBox(),),
            Padding(
              padding: hasTriangle ? 
              EdgeInsets.only(left: 14.9, right: 14.9, bottom: 19.2):EdgeInsets.only(left: 14.9, right: 14.9, bottom: 7.7),
                child: Container(
                color: color,
                padding: EdgeInsets.only(top: 13.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.5),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 220),
                        child: Text(content, style: TextStyle(fontSize: 13.5, color: ownMessage ? Colors.white : Color(0xFF7B7B7B)),)),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 13.9, bottom: 2, top: 3),
                        child: Text(date.hour.toString() + ":" + (date.minute < 10 ? '0' + date.minute.toString() : date.minute.toString()), style: TextStyle(fontSize: 9, color: Color(0xFFCECECE))),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (!ownMessage) Expanded(child: SizedBox(),),
          ],
      ),
    ],
  );
}

Widget buildRow(BuildContext context, userID, otherUserID, chatID) {

  final TextEditingController _textController = TextEditingController();
  var chat = Provider.of<Chat>(context);

  _handleSubmitted(String content) {  
    _textController.clear();
    chat.sendMessage(content, chatID, userID, otherUserID);
  } 

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.7),
    child: Row( 
      children: <Widget> [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              cursorColor: Theme.of(context).primaryColor,
              style: TextStyle(color: Color(0xFF101010)),
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: "Digite aqui a sua mensagem",
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
              ),
            )
          ),
        ),
        SizedBox(width: 20,),
        GestureDetector(
          onTap: () => {if (_textController.text.isNotEmpty) _handleSubmitted(_textController.text)},
          child: Container(
            color: Theme.of(context).primaryColor,
            width: 40,
            height: 40,
            child: Icon(FontAwesomeIcons.arrowUp, size: 16, color: Colors.white),
          )
        )
      ]
    ),
  );
}

class BaloonTriangle extends CustomPainter {
  BaloonTriangle(this.ownMessage);
  bool ownMessage;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = ownMessage ?  Color(0xFF8E8E8E) : Colors.white;
    var path = Path();
    ownMessage ? {
      path.lineTo(0.7*(size.width), 0),
      path.lineTo(0, size.height/2),
      path.lineTo(size.width, size.height),
      path.lineTo(0.7*(size.width), 0),
    }
    : {
      path.lineTo(0.3*(size.width), 0),
      path.lineTo(size.width, size.height/2),
      path.lineTo(0, size.height),
      path.lineTo(0.3*(size.width), 0),
    };
    //path.lineTo(0, size.height);
    //path.lineTo(0, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BaloonTriangle oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(BaloonTriangle oldDelegate) => false;
}


/*               CustomPaint(
                size: Size(15, 18.3),
                painter: TrianglePainter(bgcolor),
              ), */