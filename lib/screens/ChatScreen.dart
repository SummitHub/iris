import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/components/chatWidgets.dart';
import 'package:iris_flutter/services/chat.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';
import 'package:iris_flutter/screens/CreateMeetingScreen.dart';
import 'package:iris_flutter/screens/ProfileScreen.dart';
import 'package:iris_flutter/screens/MyProfileScreen.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(this._otherUserID, this._userID, this.context, this._otherUserName, this._otherUserPicture, this._otherUserPosition);
  final String _otherUserID;
  final String _userID;
  final BuildContext context;
  final String _otherUserName;
  final String _otherUserPicture;
  final String _otherUserPosition;
  @override
  ChatScreenState createState() => ChatScreenState(_otherUserID, _userID, context, _otherUserName, _otherUserPicture, _otherUserPosition);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  @override

  ChatScreenState(this._otherUserID, this._userID, this.context, this._otherUserName, this._otherUserPicture, this._otherUserPosition);
  final String _otherUserID;
  final String _userID;
  String _otherUserName;
  String _otherUserPicture;
  BuildContext context;
  String _chatRoomID;
  String _otherUserPosition;
  ScrollController _scrollController;

  setupchat(BuildContext context) async {
    print('setup chat');
    var user = Provider.of<User>(context);
    var chat = Provider.of<Chat>(context);
    _chatRoomID = await chat.confirmChatRoom(user.activeChats, _userID, _otherUserID, _chatRoomID);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setupchat(context);
  }

  moveDown(context) {
    _scrollController.animateTo(500,
    curve: Curves.linear, duration: Duration (milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute<void>(
            builder: (context) => _otherUserID ==_userID ? MyProfileScreen() : ProfileScreen(_otherUserID)
          )),
          child: Row( 
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        width: 1,
                        color: Theme.of(context).primaryColor
                      )
                    )
                  ),
                  height: 35, 
                  width: 35,
                  child: CachedNetworkImage(
                    imageUrl: _otherUserPicture, 
                    fit: BoxFit.cover
                  ), 
                ),
              ),
              Container(
                constraints: BoxConstraints(maxWidth: normalizedWidth(context, 210)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_otherUserName, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
                    Text(_otherUserPosition, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w300, color: Color(0xFFACACAC)))
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.calendarPlus, color: Color(0xFFFFFFFF),),
            tooltip: 'Create Meeting',
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
                builder: (context) => CreateMeetingScreen(_otherUserID, _otherUserName)
                )),
          ),
        ],
      ),
      body: Consumer<User>(
          builder: (context, user, _) {
          return Consumer<Chat>(
              builder: (context, chat, _) {
                return Column(
                  children: <Widget>[
                    Expanded(child: chat.messagesBuilder(_userID, _otherUserID, _scrollController)),
                    Container(
                      color: Colors.white,
                      child: buildRow(context, _userID, _otherUserID, _chatRoomID),
                    )
                  ],
                );
              },
            );
          },
      ),
    );
  }
}
