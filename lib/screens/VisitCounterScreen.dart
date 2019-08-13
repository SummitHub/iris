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
  bool fetching = false;
  bool addinguser = false;
  String userId;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText;
  bool qrTriggered = false;
  QRViewController controller;
  List<String> listOfIds = [];

  @override
  void didChangeDependencies() {
    userId = Provider.of<User>(context).id;
    print(userId.toString());    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

                            title: new Text(document['credencial']),
                            //subtitle: new Text(document['email']),
                          );
                        }).toList(),
                      );
                  }
                },
              )
            ),
            qrOpened
            ? Container(height: normalizedWidth(context, 360), width: normalizedWidth(context, 360), 
              child: Stack(
                children: <Widget>[
                  QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  ),
                  fetching?
                  Center(
                    child: CircularProgressIndicator(),
                  ):SizedBox()
                ],
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

  Map<String, String> requestHeaders = {
    's_token': 'aa73c849da4bf43501e8f7e742a5960b953eb30102f54a5c4a71788199b80030'
  };

  getRequestTotalPages() async {
      var data = await http.get('https://www.sympla.com.br/public/v3/events/402416/participants?page_size=200', headers: requestHeaders);
      var jsonData = json.decode(data.body);
      return jsonData['pagination']['total_page'];
  }

  getSymplaTicket(String qrString) async {
    if (qrString != "") {
      var participant;
      await getRequestTotalPages().then((totalPages) async {
        print("TOTAL DE PAGINAS: " + totalPages.toString());
        for (int i = 0; i <= totalPages; i++) {
          print("INDEX DO FOR "+ i.toString());
          var pageData = await http.get('https://api.sympla.com.br/public/v3/events/402416/participants?page_size=200&page='+i.toString(), headers: requestHeaders);
          var pageParticipants = json.decode(pageData.body);
          print(pageParticipants['data']);
          pageParticipants['data'].forEach((user) {
            if (user['ticket_num_qr_code'] == qrString){ 
              participant = user;
              i = 99;
            }
          });
        }
      });
      if (participant!=null){
        return Map<String, dynamic>.from(participant);
      }
    }
  }


    void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
        qrText = scanData;
          if (!addinguser){
            addinguser = true;
            addVisitant(qrText);
          }
    });
  }


  Future addVisitant(String qrText) async {
    print("ADDING USER!!!");
    await Firestore.instance.collection('users').document(userId).collection('visitants').document(qrText).setData({'credencial' : qrText});
    userAdded();
  }

  Future<void> userAdded(){
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Visitante Registrado'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                 addinguser =  false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future getWinner(String ticket) async {
    Map<String, dynamic> requestData = await getSymplaTicket(ticket);
    return {
      'name' : requestData['first_name'] + ' ' + requestData['last_name'],
      'email' : requestData['email'],
      'company': requestData['custom_form'][2]['value'],
      'phone' : requestData['custom_form'][0]['value'],
    };
  }

  Future<void> raffleUser() async {

    final _random = new Random();
    String winnerTicket = listOfIds[_random.nextInt(listOfIds.length)]; 

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sorteio!'),
          content: SingleChildScrollView(
            child: FutureBuilder(
              future: getWinner(winnerTicket),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                print("SNAPSHOT DATA: " + snapshot.data.toString());
                
                return ListBody(
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        text: 'Winner: ',
                        style: TextStyle(fontWeight: FontWeight.w800),
                        children: <TextSpan>[
                          TextSpan(text: snapshot.data['name'] ),
                        ],
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 10,),
                    Text.rich(
                      TextSpan(
                        text: 'Email: ',
                        children: <TextSpan>[
                          TextSpan(text: snapshot.data['email']),
                        ],
                      ),
                      textAlign: TextAlign.start,
                    ),            
                    SizedBox(height: 10,),
                    Text.rich(
                      TextSpan(
                        text: 'Phone: ',
                        children: <TextSpan>[
                          TextSpan(text: snapshot.data['phone']),
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
