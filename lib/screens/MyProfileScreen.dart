import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/components/tagBox.dart';
import 'package:iris_flutter/screens/VisitCounterScreen.dart';
import 'package:iris_flutter/screens/ProfilePictureScreen.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatefulWidget {

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {

  TextEditingController descriptionController = TextEditingController();
  FocusNode _tagsFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  GlobalKey<AutoCompleteTextFieldState<String>> acKey = new GlobalKey();
  ScrollController _profileScrollController = ScrollController();

  bool editingDescription = false;
  bool visibleTagField = false;


  List<String> userTags = [];
  List<String> suggestedTags = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: profileContent(context),
    );
  }

  profileContent(BuildContext context){
    return Consumer<User>(
      builder: (context, user, _) {
        return FutureBuilder(
          future: user.getCurrentUserInfo(),
          builder: (context, snapshot) {
            Map userInfo = snapshot.data;
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
            descriptionController.text = userInfo['about'];
            userTags = userInfo['tags'];
            return SingleChildScrollView(
              controller: _profileScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  profileHeader(userInfo, context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Column(
                      children: <Widget>[
                        titleAndSubtitle(context, userInfo),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 12),
                          child: tagsSection(context),
                        ),
                        Divider(height: 0),
                        descriptionSection(userInfo, context),
                        SizedBox(height: 40),


                        userInfo['exhibitor'] ?
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute<void>(
                              builder: (context) => VisitCounterScreen()
                            ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(FontAwesomeIcons.qrcode, color: Theme.of(context).secondaryHeaderColor),
                              Text("  Contador de Visitantes", style: TextStyle(fontSize: 16, color: Theme.of(context).secondaryHeaderColor),)
                            ],
                          ),
                        )
                        :SizedBox(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              )
            );
          }
        );
      }
    );
  }

  profileHeader(userInfo, context){
    return Stack(
      children: <Widget>[
        Container(
          height: 120,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).secondaryHeaderColor,
        ),
        Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 35.0),
              child: IconButton(
                icon: Icon(Icons.exit_to_app, color: Colors.white),
                tooltip: 'LogOut',
                onPressed: _logOutAlert,
              ),
            ),
          ),
        Padding(  
          padding: const EdgeInsets.only(top: 53),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
                builder: (context) => ProfilePictureScreen(userInfo['id'], userInfo['imageUrl'])
              )),
              child: CircleAvatar(
                backgroundImage: (userInfo['imageUrl'] == '')
                ? AssetImage('assets/images/placeholder.png')
                : CachedNetworkImageProvider(userInfo['imageUrl']),
                radius: 50,
                backgroundColor: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  titleAndSubtitle(context, userInfo){
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(userInfo['userName'], 
            style: TextStyle(fontSize: 23, color: Color(0xFF101010), fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text.rich(
            TextSpan(
              text: userInfo['userTitle'],
              
              style: TextStyle(fontSize: 13.5, color: Color(0xFF5A5A5A)),
              children: <TextSpan>[
                TextSpan(text: userInfo['userCompany'], style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor), ),
              ],
            ),
            textAlign: TextAlign.center,
          )
        )
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
            onLongPress: () => removeTag(tag),
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
            !visibleTagField
            ?SizedBox()
            :Column(
              children: <Widget>[
                Text("(Para remover uma tag, toque nela e segure)", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, color: Color(0xFF787878))),
                AutoCompleteTextField<String>(
                  focusNode: _tagsFocusNode,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  key: acKey,
                  suggestions: suggestedTags,
                  itemSorter: (a, b) => a.compareTo(b),
                  itemFilter: (item, query) => item.toLowerCase().startsWith(query.toLowerCase()),
                  itemSubmitted: (item) => submitSuggested(item),
                  style: TextStyle(fontSize: 18),
                  textSubmitted: (item) => submitText(item),
                  decoration: InputDecoration(
                    hintText: "Digite aqui sua tag",
                    contentPadding: EdgeInsets.only(bottom: 5, top: 15),
                    enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Theme.of(context).primaryColor)),
                    labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                    suffixIcon: IconButton(
                      padding: EdgeInsets.zero, 
                      icon: Icon(Icons.check), 
                      color: Theme.of(context).primaryColor, 
                      onPressed: () => acKey.currentState.triggerSubmitted()
                    )
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
            ),
          ],
        );
      }
    ); 
  }

  submitSuggested(item){
    if(!userTags.contains(item)) userTags.add(item);
    updateTags();
  }

  submitText(item){
    if (item.trimRight().trimLeft().length > 2 && !userTags.contains(item.trimRight().trimLeft())) 
      userTags.add(item.trimRight());
    updateTags();
  }

  removeTag(tag) async {
    setState(() {
     userTags.remove(tag); 
    });
    Provider.of<User>(context).removeTag(tag);
  }

  updateTags() async {
    _tagsFocusNode.unfocus();  
    setState(() => visibleTagField = false);
    List<String> newTags = List<String>.from(userTags);
    newTags.removeWhere((tag) => suggestedTags.contains(tag));
    print("uploading new tags: " + userTags.toString());
    Firestore.instance.collection('general').document('userTags').updateData( {'tags' : FieldValue.arrayUnion(newTags)});
    Provider.of<User>(context).updateTags(userTags);
  }

  openTagTextField() async {
    setState(() => visibleTagField = true);
    await Future.delayed(Duration(milliseconds: 100));
    _tagsFocusNode.requestFocus();
  }

  extraInfoScrollHalfWayDown()async {
    await Future.delayed(Duration(milliseconds: 300));
    _profileScrollController.animateTo(_profileScrollController.position.maxScrollExtent/2, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  extraInfoScrollDown() async {
    print("SCROLL DOWNN");
    await Future.delayed(Duration(milliseconds: 300));
    _profileScrollController.animateTo(_profileScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  descriptionSection(userInfo, context){
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: <Widget>[
          Row( 
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text("Sobre " + userInfo['userName'],
                  style: TextStyle(fontSize: 17.3, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)
                ),
              ),
              SizedBox(
                width: 40,
                child: editingDescription 
                ?IconButton(
                  icon: Icon(Icons.check, color: Color(0xFF989898),),
                  onPressed: () => {
                    setState(() {
                       if (descriptionController.text != userInfo['about']) updateDescription(descriptionController.text);
                      editingDescription = !editingDescription;
                    })
                  }
                ,)
                :IconButton(
                  icon: Icon(Icons.edit, color: Color(0xFF989898),),
                  onPressed: () => setState(() {
                   editingDescription = !editingDescription;
                  })
                ,),
              )
            ],
          ),
          SizedBox(height: 15),

          !editingDescription
          ? Align(
            alignment: Alignment.centerLeft,
            child: (userInfo['about'].length > 0) 
            ? Text(userInfo['about'],
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, color: Color(0xFF989898)),  
              )
            : Column(
                children: <Widget>[
                  Text('Sem descrição.',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, color: Color(0xFF989898)),  
                  ),
                  
                ],
              ),
          )
          :
          TextField(
            textCapitalization: TextCapitalization.sentences,
            cursorColor: Color(0xFFB4B4B4),
            cursorWidth: 1.2,
            decoration: InputDecoration(
              fillColor: Color(0xFF707070),
              contentPadding: EdgeInsets.zero,
              enabledBorder: UnderlineInputBorder( borderSide: BorderSide( width: 2, color: Theme.of(context).primaryColor)),
            ),
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, color: Color(0xFF101010), height: 1.2),
            controller: descriptionController,
            focusNode: _descriptionFocusNode,
            maxLines: 10,
            minLines: 1,
            keyboardType: TextInputType.multiline,
          )
        ],
      ),
    );
  }

  void dispose() {
    descriptionController.dispose();
    _tagsFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _profileScrollController.dispose();
    super.dispose();
  }

  void updateDescription(String text){
    Provider.of<User>(context).editCurrentUserDescription(text);
  }
  
  Future<void> _logOutAlert() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deseja sair de sua conta?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar', style: TextStyle(color: Color(0xFF989898))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Sair', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<User>(context).signOut();
              },
            ),
          ],
        );
      },
    );
  }
}