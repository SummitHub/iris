import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import "dart:math";

class VisitCounterScreen extends StatefulWidget {

  @override
  _VisitCounterScreenState createState() => _VisitCounterScreenState();
}

class _VisitCounterScreenState extends State<VisitCounterScreen> {

  bool qrOpened = false;
  String userId;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText;
  bool qrTriggered = false;
  Map<String, dynamic> requestData;
  QRViewController controller;
  List<String> listOfIds = [];

  @override
  void didChangeDependencies() {
    userId = Provider.of<User>(context).id;
    print(userId.toString());    super.didChangeDependencies();
  }

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
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      height: 56,
                      width: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/sideLines2.png'),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 56,
                      width: 56,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: IconButton(
                          icon: Icon(FontAwesomeIcons.dice, color: Colors.white,),
                          onPressed: () => raffleUser(),
                        )
                      )  
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text("Contador de Visitantes", style: TextStyle(color: Colors.white, fontSize: 18.5, fontWeight: FontWeight.w900),),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('users').document(userId.toString()).collection('visitants').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  listOfIds = [];
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  if (!snapshot.hasData)
                    return new Text('Nenhum visitante cadastrado');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting: return new Text('Loading...');
                    default:
                      return new ListView(
                        children: snapshot.data.documents.map((DocumentSnapshot document) {
                          listOfIds.add(document.documentID.toString());
                          return new ListTile(
                            title: new Text(document['name']),
                            subtitle: new Text(document['email']),
                          );
                        }).toList(),
                      );
                  }
                },
              )
            ),
            qrOpened
            ? Container(height: normalizedWidth(context, 360), width: normalizedWidth(context, 360), 
              child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              )
            )
            : SizedBox(),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(FontAwesomeIcons.qrcode, color: Colors.white, size: 28,),
        onPressed: () => setState(
          () => qrOpened = !qrOpened
        )
      ),
    );
  }

    Future getSymplaTicket(String qrString) async {
    if (qrString != "") {
      print("LOADING");
      Map<String, String> requestHeaders = {
        's_token': 'aa73c849da4bf43501e8f7e742a5960b953eb30102f54a5c4a71788199b80030'
      };
      var data = await http.get('https://api.sympla.com.br/public/v3/events/402416/participants?ticket_num_qr_code='+qrString, headers: requestHeaders);
      var jsonData = json.decode(data.body);
      List results = jsonData['data'];
      var participant = results.where((item) => item['ticket_num_qr_code'].startsWith(qrString));

      requestData = Map<String, dynamic>.from(participant.first);
      addVisitant(requestData, qrString);
      print("GOT IT");
    }
  }

  _onQRViewCreated(QRViewController controller) {
    print("INIT QR");
    final channel = controller.channel;
    controller.init(qrKey);
    this.controller = controller;
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onRecognizeQR":
          print("PISCA");
          dynamic arguments = call.arguments;
          print("LIST OF IDS: " + listOfIds.toString());
          if (!listOfIds.contains(arguments.toString())) await getSymplaTicket( arguments.toString());
      }
    });
  }

  Future addVisitant(Map<String, dynamic> requestData, String qrText) async {
    print("ADDING USER!!!");
    Firestore.instance.collection('users').document(userId).collection('visitants').document(qrText)
    .setData({
      'name' : requestData['first_name'] + ' ' + requestData['last_name'],
      'email' : requestData['email'],
      'company': requestData['custom_form'][2]['value'],
      'phone' : requestData['custom_form'][0]['value'],
    });
  }

  Future<void> raffleUser() async {
    String name = '';
    String email = '';
    String phone = '';

    final _random = new Random();
    String winnerId = listOfIds[_random.nextInt(listOfIds.length)]; 
    Firestore.instance.collection('users').document(userId).collection('visitants').document(winnerId).get().then((doc){
      if (doc.data['name']!=null || doc.data['email']!=null) {
        name = doc.data['name'].toString();
        email = doc.data['email'].toString();
        phone = doc.data['phone'].toString();
      } else {
        name = 'ERRO';
        email = "ERRO";
        phone = "ERRO";
      }

    });
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Sorteio!'),
        content: SingleChildScrollView(
          child: FutureBuilder<Object>(
            future: Firestore.instance.collection('users').document(userId).collection('visitants').document(winnerId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator(backgroundColor: Color(0xFFf55288),));
              return ListBody(
                children: <Widget>[

            Text.rich(
              TextSpan(
                text: 'Winner: ',
                
                style: TextStyle(fontWeight: FontWeight.w800),
                children: <TextSpan>[
                  TextSpan(text: name ),
                ],
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10,),
            Text.rich(
              TextSpan(
                text: 'Email: ',
                children: <TextSpan>[
                  TextSpan(text: email),
                ],
              ),
              textAlign: TextAlign.start,
            ),            
            SizedBox(height: 10,),
            Text.rich(
              TextSpan(
                text: 'Phone: ',
                children: <TextSpan>[
                  TextSpan(text: phone),
                ],
              ),
              textAlign: TextAlign.start,
            ),

                ],
              );
            }
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}
