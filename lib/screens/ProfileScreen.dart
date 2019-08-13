import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/components/tagBox.dart';
import 'package:iris_flutter/screens/ChatScreen.dart';
import 'package:iris_flutter/screens/CreateMeetingScreen.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';
import 'package:iris_flutter/screens/ProfilePictureScreen.dart';
import 'package:iris_flutter/services/normalize.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen(this.id);
  final String id;

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
        return FutureBuilder<Object>(
          future: user.getOtherUserInfo(id),
          builder: (context, snapshot) {
            Map userInfo = snapshot.data;
            if (!snapshot.hasData){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }
            return Stack(
              children: <Widget>[
                SingleChildScrollView(
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
                              child: tagsSection(context, userInfo['tags']),
                            ),
                            Divider(height: 0),
                            descriptionSection(userInfo, context),
                            SizedBox(height: 95)
                          ],
                        ),
                      ),
                    ],
                  )
                ),
                overlayButtons(context, userInfo),
              ],
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
          color: Theme.of(context).secondaryHeaderColor
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: BackButton(color: Colors.white),
          ),
        ),
        Padding(  
          padding: const EdgeInsets.only(top: 53),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
                builder: (context) => UneditableProfilePictureScreen(userInfo['imageUrl'])
              )),
              child: CircleAvatar(
                backgroundImage: 
                CachedNetworkImageProvider(userInfo['imageUrl']),
                //NetworkImage(userInfo['imageUrl']),
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
            textAlign: TextAlign.center,),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text.rich(
            TextSpan(
              text: userInfo['userTitle'],
              style: TextStyle(fontSize: 13.5, color: Color(0xFF5A5A5A)),
              children: <TextSpan>[
                TextSpan(text: userInfo['userCompany'], style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
              ],
            ),
            textAlign: TextAlign.center,
          )
        )
      ],
    );
  }

  tagsSection(BuildContext context, userTags){
    List<Widget> tags =[];
    for (String tag in userTags) {
      tags.add(tagBox(tag[0].toUpperCase() + tag.substring(1), context, Theme.of(context).primaryColor, Colors.white));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: -4,
          children: tags
        )      
      ),
    );
  }

  descriptionSection(userInfo, context){
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Sobre " + userInfo['userName'],
              style: TextStyle(fontSize: 17.3, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700)
            ),
          ),
          SizedBox(height: 15),

          Align(
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
        ],
      ),
    );
  }

  overlayButtons(context, userInfo){
    String userPosition = userInfo['userTitle'] + userInfo['userCompany'];
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15, right: 25, left: 25),
        child: Row( 
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () => openChat(id, userInfo['userName'], context, userInfo['imageUrl'], userPosition),
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
                          width: normalizedWidth(context, 145),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 4,),
                        Container(
                          height: 50,
                          width: normalizedWidth(context, 143),
                          color: Theme.of(context).primaryColor,
                          child: Center(child: Text('CONVERSAR', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            FlatButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
                builder: (context) => CreateMeetingScreen(id, userInfo['userName'])
                )),
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
                          width: normalizedWidth(context, 145),
                          child: Center(child: Text('AGENDAR', style: TextStyle(fontWeight: FontWeight.w800, color:Theme.of(context).primaryColor, fontSize: 13.8))),
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
                          width: normalizedWidth(context, 143),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

openChat(String otherUserID, String otherUserName, BuildContext context, String otherUserPicture, String otherUserPosition) async{
  var auth = Provider.of<User>(context);
  String _userID = auth.user.uid;

  Navigator.push(context, MaterialPageRoute<void>(
    builder: (context) => ChatScreen(otherUserID, _userID, context, otherUserName, otherUserPicture, otherUserPosition)
  ));
}