import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:iris_flutter/screens/HomeScreen.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:iris_flutter/components/tagBox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen(this.participant);
  Map<String, dynamic> participant;

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _descriptionController = TextEditingController();
  FocusNode _tagsFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  ScrollController _extraInfoScrollController = ScrollController();
  MaskedTextController cpfMaskedController = MaskedTextController(mask: "000.000.000-00");

  File _image;
  String _imageUrl;
  final formKey = new GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> acKey = new GlobalKey();
  final signUpPageController = PageController(initialPage: 0);
  String _accountID;
  String _name;
  String _password;
  String _company;
  String _position;
  String _segment;
  List<String> userTags = [];
  List<String> suggestedTags = [];
  bool _exhibitor;
  bool loadingFinalStep = false;
  bool visibleField = false;
  bool validateAndSave() {
    final form = formKey.currentState;
    form.save();
    return form.validate();
  }

  validateAndSubmit(context) async {
    if (validateAndSave()){
      try {
        await createUser(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomeScreen();
            } 
          ),
        );
      }
      catch(e) { print("Error: $e"); }
    }
  }

  Future createUser(context) async {
    var user = Provider.of<User>(context);
      try {
        print("Creating user: <$_accountID>, Password: <${_password.replaceAll('-', '').replaceAll('.', '').replaceAll(' ', '')}>");
        await user.createUserWithEmailAndPassword(
          _accountID, 
          _password.replaceAll('-', '').replaceAll('.', '').replaceAll(' ', ''), 
          _name, 
          _company, 
          _position, 
          _segment, 
          _imageUrl.toString(), 
          userTags, 
          _descriptionController.text, 
          _exhibitor
        );
        print('created the new user');
      }
      catch(e) { print("Error: $e"); }
  }
  
    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1080);
      setState(() {
        _image = image;
          print('Image Path $_image');
      });
    }

    Future uploadPic(BuildContext context) async{
      if (_image==null){
        _imageUrl = '';
      } else {
        StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('userPics').child(_accountID + DateTime.now().toIso8601String());
        StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
        StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
        var downUrl = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          _imageUrl = downUrl;
        });
        print("Profile Picture uploaded");
      }
    }

   @override
  void initState() {
    _descriptionFocusNode.addListener(() {
      if(_descriptionFocusNode.hasFocus){
        extraInfoScrollDown();
      }
    });
    _tagsFocusNode.addListener(() {
      if(_tagsFocusNode.hasFocus) extraInfoScrollHalfWayDown();
    });
    cpfMaskedController.updateText(widget.participant['custom_form'][1]['value']);
    super.initState();
  }

  extraInfoScrollHalfWayDown()async {
    await Future.delayed(Duration(milliseconds: 300));
    _extraInfoScrollController.animateTo(_extraInfoScrollController.position.maxScrollExtent/2, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  extraInfoScrollDown() async {
    print("SCROLL DOWNN");
    await Future.delayed(Duration(milliseconds: 300));
    _extraInfoScrollController.animateTo(_extraInfoScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }
  
  openTagTextField() async {
    setState(() => visibleField = true);
    await Future.delayed(Duration(milliseconds: 100));
    _tagsFocusNode.requestFocus();
  }

  finishSignUp(context ) async {
    setState(() => loadingFinalStep = true);
    List<String> newTags = List<String>.from(userTags);
    newTags.removeWhere((tag) => suggestedTags.contains(tag));
    print("uploading new tags: " + userTags.toString());
    Firestore.instance.collection('general').document('userTags').updateData( {'tags' : FieldValue.arrayUnion(newTags)});
    await uploadPic(context);
    await validateAndSubmit(context); 
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    _tagsFocusNode.dispose();
    _extraInfoScrollController.dispose();
    _descriptionFocusNode.dispose();
    signUpPageController.dispose();
    cpfMaskedController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.participant.toString());

    print(userTags.toString());
    print(suggestedTags.toString());
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      body: Form(
              key: formKey,
              child: PageView(
              controller: signUpPageController,
              children: <Widget>[
                step1(context),
                step2(context),
              ],
            ),
      ),
    );
  }

  Widget step1(context){
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10.0, left: 30, right: 30),
          child: Column(
            children: <Widget>[

              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Confirme suas informações", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                          enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Color(0xFFE1EC49))),
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          labelText: "E-mail"
                        ),
                        validator: (value) => value.isEmpty ? 'Insira um e-mail válido' : null,
                        onSaved: (value) => _accountID = value,
                        initialValue: widget.participant['email'].trimLeft().trimRight(),
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        cursorColor: Theme.of(context).primaryColor,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                          enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Color(0xFFE1EC49))),
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          labelText: "Nome"
                        ),
                        validator: (value) => value.isEmpty ? 'Insira um nome válido' : null,
                        onSaved: (value) => _name = value,
                        initialValue: capitalizeString((widget.participant['first_name']+' '+widget.participant['last_name']).trimLeft().trimRight().toLowerCase()),
                      ),
                      TextFormField(
                        controller: cpfMaskedController,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        cursorColor: Theme.of(context).primaryColor,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                          enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Color(0xFFE1EC49))),
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          labelText: "CPF"
                        ),
                        validator: (value) => value.isEmpty ? 'Insira um CPF válido' : null,
                        onSaved: (value) => _password = value,
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                          enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Color(0xFFE1EC49))),
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          labelText: "Empresa"
                        ),
                        validator: (value) => value.isEmpty ? 'Insira uma empresa válida' : null,
                        onSaved: (value) => _company = value,
                        initialValue: capitalizeString((widget.participant['custom_form'][2]['value'].trimLeft().trimRight().toLowerCase())),
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                          enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Color(0xFFE1EC49))),
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          labelText: "Cargo"
                        ),
                        validator: (value) => value.isEmpty ? 'Insira um cargo válido' : null,
                        onSaved: (value) => _position = value,
                        initialValue: capitalizeString((widget.participant['custom_form'][3]['value']).trimLeft().trimRight().toLowerCase()),
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                          enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Color(0xFFE1EC49))),
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          labelText: "Segmento"
                        ),
                        validator: (value) => value.isEmpty ? 'Insira um segmento válido' : null,
                        onSaved: (value) => _segment = value,
                        initialValue: capitalizeString((widget.participant['custom_form'][4]['value']).trimLeft().trimRight().toLowerCase()),
                      ),
                      TextFormField(
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        readOnly: true,
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                          enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Color(0xFFE1EC49))),
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          labelText: "Tipo de Ingresso"
                        ),
                        validator: (value) => value.isEmpty ? 'Insira um tipo de ingresso válido' : null,
                        onSaved: (value) { value.contains('Expositor') ? _exhibitor = true : _exhibitor = false; },
                        initialValue: widget.participant['ticket_name'],
                      ),
                    ],
                  )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row( 
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () { Navigator.of(context).pop(); },
                      child: Container(
                        height: 55,
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                SizedBox(height: 2,),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                                  ),
                                  height: 50,
                                  width: (135/360)*MediaQuery.of(context).size.width,
                                  child: Center(child: Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.w800, color:Theme.of(context).primaryColor, fontSize: 13.8))),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 4,),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                                  ),
                                  height: 50,
                                  width: (133/360)*MediaQuery.of(context).size.width,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => {
                        formKey.currentState.save(),
                        print("CPF: " + _password),
                        signUpPageController.nextPage(curve: Curves.easeInOutSine, duration: Duration(milliseconds: 200)),
                      },
                      child: Container(
                        height: 55,
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                SizedBox(height: 2,),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                                  ),
                                  height: 50,
                                  width: (135/360)*MediaQuery.of(context).size.width,
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 4,),
                                Container(
                                  height: 50,
                                  width: (133/360)*MediaQuery.of(context).size.width,
                                  color: Theme.of(context).primaryColor,
                                  child: Center(child: Text('CONTINUAR', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ]
    );
  }

  Widget step2(context){
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: SingleChildScrollView(
            controller: _extraInfoScrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                profileHeader(context),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("Escolha uma foto", 
                              style: TextStyle(fontSize: 22, color: Color(0xFF101010), fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                            child: Divider(height: 0),
                          ),
                          Row( 
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text("Adicione até 7 tags:",
                                style: TextStyle(fontSize: 17.3, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)
                              ),
                            ],
                          ),
                          
                          tagsSection(context),
                        

                          
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 5),
                            child: Divider(height: 0),
                          ),

                          descriptionSection(context),

                          SizedBox(height: 100),
                        ],
                      ),
                    ),
                    loadingFinalStep
                    ?Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                    :SizedBox(),                  
                  ],
                ),
              ],
            ),
          )
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12),
            child: Row( 
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed:() => {
                    formKey.currentState.save(),
                    signUpPageController.previousPage(curve: Curves.easeInOutSine, duration: Duration(milliseconds: 200)),
                  },
                  child: Container(
                    height: 55,
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(height: 2,),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                              ),
                              height: 50,
                              width: (135/360)*MediaQuery.of(context).size.width,
                              child: Center(child: Text('VOLTAR', style: TextStyle(fontWeight: FontWeight.w800, color:Theme.of(context).primaryColor, fontSize: 13.8))),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 4,),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                              ),
                              height: 50,
                              width: (133/360)*MediaQuery.of(context).size.width,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => finishSignUp(context), 
                  child: Container(
                    height: 55,
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(height: 2,),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                              ),
                              height: 50,
                              width: (135/360)*MediaQuery.of(context).size.width,
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(width: 4,),
                            Container(
                              height: 50,
                              width: (133/360)*MediaQuery.of(context).size.width,
                              color: Theme.of(context).primaryColor,
                              child: Center(child: Text('CONCLUIR', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ]
    );
  }

  profileHeader(context){
    return Stack(
      children: <Widget>[
        Container(
          height: 120,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).secondaryHeaderColor,
        ),
        Padding(  
          padding: const EdgeInsets.only(top: 53),
          child: Center(
            child: GestureDetector(
              onTap: () => getImage(),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                child: (_image==null) 
                ? CircleAvatar(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  radius: 47,
                  child: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon( FontAwesomeIcons.camera, size: 35.0, color: Colors.white)),
                  )
                : null,
                backgroundImage: (_image==null) ? null : FileImage( _image),       
                
              ),
            ),
          ),
        ),
      ],
    );
  }

  tagsSection(BuildContext context){
    return FutureBuilder(
      future: Firestore.instance.collection('general').document('userTags').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData){
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator()
              ],
            ),
          );
        }
        suggestedTags.clear();
        List<Widget> currentTags =[];
        if (snapshot.data['tags'].length > 0) {
          for (String tag in snapshot.data['tags']){
            suggestedTags.add(tag);
          }
        }
        for (String tag in userTags) {
          currentTags.add(  GestureDetector(
            onLongPress: () => setState(()=> userTags.remove(tag)),
            child: tagBox(tag[0].toUpperCase() + tag.substring(1), context, Theme.of(context).primaryColor, Colors.white)
          ,));
        }
        if (currentTags.length <= 6) currentTags.add(GestureDetector(
          onTap: () => openTagTextField(),
          child: tagBox('+', context, Theme.of(context).primaryColor, Colors.white),
        ));
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: -4,
                  children: currentTags
                )      
              ),
            ),
            Text("(Para remover uma tag, toque nela e segure)", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, color: Color(0xFF787878))),            
            !visibleField
            ? SizedBox()
            :AutoCompleteTextField<String>(
              focusNode: _tagsFocusNode,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              
              key: acKey,
              suggestions: suggestedTags,
              itemSorter: (a, b) => a.compareTo(b),
              itemFilter: (item, query) => item.toLowerCase().startsWith(query.toLowerCase()),
              itemSubmitted: (item) => setState((){
                if(!userTags.contains(item)) userTags.add(item);
                visibleField = false;
                }),
              style: TextStyle(fontSize: 18),
              textSubmitted: (item) => setState((){
                if (item.trimRight().trimLeft().length > 2 && !userTags.contains(item.trimRight().trimLeft())) userTags.add(item.trimRight());
                visibleField = false;
                }),
              decoration: InputDecoration(
                hintText: "Digite aqui sua tag",
                contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Theme.of(context).primaryColor)),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                suffixIcon: IconButton(padding: EdgeInsets.zero, icon: Icon(Icons.check), color: Theme.of(context).primaryColor, onPressed: () => acKey.currentState.triggerSubmitted(  ))
              ),
              itemBuilder: (context, item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(item, style: TextStyle( fontSize: 16.0),),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      }
    ); 
  }

  descriptionSection(context){
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: <Widget>[
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text("Descrição pessoal:",
                  style: TextStyle(fontSize: 17.3, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)
                ),
              ),
              SizedBox(width: 40,)
            ],
          ),
          SizedBox(height: 15),

          TextField(
            textCapitalization: TextCapitalization.sentences,
            cursorColor: Color(0xFFB4B4B4),
            cursorWidth: 1.2,
            
            decoration: InputDecoration(
              hintText: 'Escreva sobre você aqui.',
              fillColor: Color(0xFF707070),
              contentPadding: EdgeInsets.zero,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2)),
              focusedBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Theme.of(context).primaryColor)),
            ),
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, color: Color(0xFF101010), height: 1.2),
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            maxLines: 10,
            minLines: 3,
            keyboardType: TextInputType.multiline,
          )
        ],
      ),
    );
  }

  String capitalizeString(String text){
    if (text.length <= 1) return text.toUpperCase();
    var words = text.split(' ');
    var capitalized = words.map((word) {
      print("WORD: " + word);
      var first = word.substring(0, 1).toUpperCase();
      var rest = word.substring(1);
      return '$first$rest';
    });
    return capitalized.join(' ');
  }

}