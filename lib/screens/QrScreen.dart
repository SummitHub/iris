import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/screens/SignupScreen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QrScreen extends StatefulWidget {
  const QrScreen({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText;
  bool fetching = false;
  bool openedCamera = true;
  bool loadingSympla = false;
  Map<String, dynamic> requestData;
  FocusNode _textFocusNode = FocusNode();
  TextEditingController _textController = TextEditingController();
  QRViewController controller;

  @override
  void initState() {
    _textFocusNode.addListener(() {
      if (_textFocusNode.hasFocus) setState(() => openedCamera=false);
      if (!_textFocusNode.hasFocus) setState(() => openedCamera=true);
    });


    _textController.addListener((){      
      if(_textController.text.length>9 && !fetching) {
        setState(() => fetching = true);
        getSymplaTicket(_textController.text);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              openedCamera
              ?Expanded(
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              )
              :SizedBox(height: 100,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: !loadingSympla
                    ?IconButton(
                      icon: Icon(FontAwesomeIcons.qrcode,
                        size: 30, 
                        color: Color(0xFFE1EC49),
                      ),
                      onPressed: () => _textFocusNode.unfocus(),
                    )
                    :CircularProgressIndicator(),
                  )
                ),
              ),
              Container(
                height: 120,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                  child: Column(children:
                    <Widget>[
                      Column(
                        children: <Widget>[
                          Text("Escaneie o seu QR Code", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                          Text("ou", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                          Text("digite o identificador da sua credencial.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.characters,
                        focusNode: _textFocusNode,
                        controller: _textController,
                        style: TextStyle(fontSize: 18, color: Color(0xFFE1EC49)),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          alignLabelWithHint: true,
                          hintText: "Número de Inscrição" ,
                          hintStyle: TextStyle(color: Color(0xFFE1EC49), decoration: TextDecoration.underline)),
                        validator: (value) => value.isEmpty ? 'Enter a valid e-mail or username' : null,
                        onSaved: (value) => _textController.text = value,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 25),
              child: BackButton(color: Colors.white,),
            ),
          ),
          fetching
          ? Align(
            alignment: Alignment.center,
            child: AlertDialog(
                content: Container(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 20,),
                    Text("Buscando suas informações"),
                    Text("Aguarde...")
                  ],
              ),
                ),
            ),
          )
          : SizedBox()
        ],
      ),
    );
  }

  Map<String, String> requestHeaders = {
    's_token': '6d317bc0623cad70c90d5d7b91a69eba4cdd63241cb3237d291d1e61b5d5badf'
  };

  getRequestTotalPages() async {
      var data = await http.get('https://www.sympla.com.br/public/v3/events/514992/participants?page_size=200', headers: requestHeaders);
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
          var pageData = await http.get('https://api.sympla.com.br/public/v3/events/514992/participants?page_size=200&page='+i.toString(), headers: requestHeaders);
          var pageParticipants = json.decode(pageData.body);
          print(pageParticipants['data']);
          pageParticipants['data'].forEach((user) {
            if (user['ticket_num_qr_code'] == qrString){ 
              participant = user;
              i = 99;
            }
          });
          print(participant.toString());          
        }

        print("GOT FUTURE: " + totalPages.toString());
      });
      _textController.clear();
      setState(() => fetching = false);


      if (participant!=null){
        requestData = Map<String, dynamic>.from(participant);

        Navigator.pushReplacement(context,MaterialPageRoute(
          builder: (context) => SignupScreen(requestData)
        ));
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
        qrText = scanData;
        if (!fetching) {
        setState(() {
          fetching = true;
        });
          getSymplaTicket(qrText);
        }
    });
  }


}