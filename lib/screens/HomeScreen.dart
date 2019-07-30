import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iris_flutter/components/loadingSpinner.dart';
import 'package:iris_flutter/models/message.dart';
import 'package:iris_flutter/screens/SignInSelectorScreen.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:iris_flutter/screens/MyScheduleScreen.dart';
import 'package:iris_flutter/screens/MyProfileScreen.dart';
import 'package:iris_flutter/screens/ScheduleScreen.dart';
import 'package:iris_flutter/screens/ListOfChats.dart';
import 'package:iris_flutter/screens/ChatScreen.dart';
import 'package:iris_flutter/components/SearchScreenWidget.dart';
import 'package:iris_flutter/components/eventMap.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:iris_flutter/components/nextLectures.dart';


class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Message> messages = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  CupertinoTabController _tabController = CupertinoTabController();
  bool firstLoad = true;
  Map userInfo = {
      'userName' : 'userName',
      'userTitle' : 'userTitle' + ' em ',
      'userCompany' : 'userCompany', 
      'tags' : ['tags'],
      'imageUrl' : 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_960_720.png'
    };

  navigateToChatScreen(message, context) {
      return Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            var user = Provider.of<User>(context);
            return ChatScreen(message['senderID'], user.id, context, message['senderName'], message['senderImage'], message['senderPosition']);
          } 
        )
      );
  }

  navigateToScheduleScreen(context) {
    setState(() {
      _tabController.index =  3;
    });
  }

  @override
  void initState() { 
    super.initState();

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.subscribeToTopic('allDevices');
    bool isIOS = Platform.isIOS;
    if (isIOS) {
      _firebaseMessaging.configure(
          onMessage: (Map<String, dynamic> message) async {
            final notification = message;
            setState(() {
              messages.add(Message(
                  title: notification['title'], body: notification['body']));
            });
            if (message['type'] == 'chat') {
              navigateToChatScreen(notification, context);
            }
            if (message['type'] == 'meeting') {
              print('type meeting');
              navigateToScheduleScreen(context);
            }
          },
          onLaunch: (Map<String, dynamic> message) async {
            if (message['type'] == 'chat') {
              print('type chat');
              navigateToChatScreen(message, context);
            }
            if (message['type'] == 'meeting') {
              print('type meeting');
              navigateToScheduleScreen(context);
            }
          },
          onResume: (Map<String, dynamic> message) async {
            if (message['type'] == 'chat') {
              print('type chat');
              navigateToChatScreen(message, context);
            }
            if (message['type'] == 'meeting') {
              print('type meeting');
              navigateToScheduleScreen(context);
            }
          },
        );        
    } else {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('onMessage: ' + message['notification']);
          final notification = message['notification'];
          setState(() {
            messages.add(Message(
                title: notification['title'], body: notification['body']));
          });
          if (message['data']['type'] == 'chat') {
            print('type chat');
            navigateToChatScreen(message['data'], context);
          }
          if (message['data']['type'] == 'meeting') {
            print('type meeting');
            navigateToScheduleScreen(context);
          }
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('onLaunch: ' + message['notification']);
          if (message['data']['type'] == 'chat') {
            print('type chat');
            navigateToChatScreen(message['data'], context);
          }
          if (message['data']['type'] == 'meeting') {
            print('type meeting');
            navigateToScheduleScreen(context);
          }
        },
        onResume: (Map<String, dynamic> message) async {
          print('onResume: ' + message['notification']);
          if (message['data']['type'] == 'chat') {
            print('type chat');
            navigateToChatScreen(message['data'], context);
          }
          if (message['data']['type'] == 'meeting') {
            print('type meeting');
            navigateToScheduleScreen(context);
          }
        },
      );
    }
    
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    
  }

  navigateToIndex(int index){
    setState(() {
      _tabController.index=index;
    });
  }

  @override

  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, _) {
        print("currentStatus: " + user.status.toString());
        switch (user.status) {
          case Status.Uninitialized: return Scaffold(backgroundColor: Colors.white,body: Center(child: LoadingSpinner(false),),);
          case Status.Unauthenticated: return SignInSelectorScreen();
          case Status.Authenticating: return Scaffold(backgroundColor: Colors.white,body: Center(child: LoadingSpinner(false),),);
          case Status.Authenticated: return bottomBar(); 
        }
         return null;
      }
    );
  }

  bottomBar(){
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar:  CupertinoTabBar(
        border: Border(top: BorderSide(color: Color(0x9000000))),
        backgroundColor: Colors.white,
        inactiveColor: Color(0xFF8E8E93),
        activeColor: Theme.of(context).secondaryHeaderColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 24,), title: Text("Home", style: TextStyle(fontSize: 9.6))),
          BottomNavigationBarItem(icon: Icon(Icons.event, size: 24,), title: Text("Evento", style: TextStyle(fontSize: 9.6))),
          BottomNavigationBarItem(icon: Icon(Icons.chat, size: 24,), title: Text("Chat", style: TextStyle(fontSize: 9.6))),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today, size: 24,), title: Text("Agenda", style: TextStyle(fontSize: 9.6))),
          BottomNavigationBarItem(icon: Icon(Icons.person, size: 24,), title: Text("Perfil", style: TextStyle(fontSize: 9.6))),
        ],
      ),
      tabBuilder: (context, index) {
         switch (index) {
          case 0: 
            return CupertinoTabView(
              builder: (context) => MainHomeScreen(_tabController)
            );
            case 1: 
            return CupertinoTabView(
              builder: (context) => ScheduleScreen()
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => ListOfChats()
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => MyScheduleScreen(_tabController)
            ); 
          case 4:
            return CupertinoTabView(
              builder: (context) => MyProfileScreen()
            ); 
        }
        return null;
      }
    );
  }
}


class MainHomeScreen extends StatefulWidget {
  MainHomeScreen(this._tabController);
  CupertinoTabController _tabController = CupertinoTabController();

  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  var _searchFocus = new FocusNode();
  TextEditingController _searchController = TextEditingController();
  bool openedSearch = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus) setState(() => openedSearch = true);
      if (!_searchFocus.hasFocus) {
        _searchController.clear();
        setState(() => openedSearch = false);
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
  if (widget._tabController.index != 0) openedSearch = false;
  print('openedsearch? $openedSearch, text: ${_searchController.text}');
    return  Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            homeScreenHeader(),
            openedSearch
            ? SearchScreenWidget(_searchController.text, widget._tabController)
            : homeScreenDashboard()
          ]
        ) 
      )
    );
  }

  homeScreenHeader(){
    return Container(
      color: Theme.of(context).secondaryHeaderColor,
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          children: <Widget>[
            Padding(
              padding:  EdgeInsets.only(top: 40),
              child: Row(
                children: <Widget>[ 
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/whitearrow.png'),
                        )
                      )
                    )
                  )
                ],
              ),
            ),
            Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 2),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(()=>{}),
                    focusNode: _searchFocus,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: Color(0xFFB4B4B4),
                    cursorWidth: 1.2,
                    style: TextStyle(color: Colors.white, fontSize: 16, height: 1.2, decoration: TextDecoration.none),
                    
                    decoration: InputDecoration(
                      
                      contentPadding: EdgeInsets.only(top: 0, right: 35, bottom: 3),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xB4FF3E88), width: 2)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                      labelText: "Pesquise pessoas por nome, empresa, cargo ou tags",
                      hasFloatingPlaceholder: false,
                      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Color(0xFFb4b4b4), height: 1.2),
                    )
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: (_searchFocus.hasFocus)
                    ? IconButton(icon: Icon(Icons.close, color: Color(0xFFb4b4b4), size: 22,),
                      onPressed: () => setState(() => _searchFocus.unfocus())
                    )
                    : IconButton(icon: Icon(Icons.search, color: Color(0xFFb4b4b4), size: 22,),
                      onPressed: () => setState(() => _searchFocus.requestFocus())
                    ),
                  )
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  homeScreenDashboard(){
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.8), 
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Mapa do Evento", style: TextStyle(fontSize: 17, fontFamily: 'Circular', fontWeight: FontWeight.w900)),
                ],
              )
            ),
            EventMapWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("A Seguir", style: TextStyle(fontSize: 17, fontFamily: 'Circular', fontWeight: FontWeight.w900)),
                ],
              )
            ),
            NextLecturesWidget(2),
            SizedBox(height: 20,)
          ],
        ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    _searchFocus.dispose();
    _searchController.dispose() ;
  }

}