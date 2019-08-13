import 'package:flutter/material.dart';
// import 'package:iris_flutter/databaseSync.dart';
import 'package:iris_flutter/screens/HomeScreen.dart';
import 'package:iris_flutter/services/Invititations.dart';
import 'package:iris_flutter/services/chat.dart';
import 'services/Lectures.dart';
import 'package:provider/provider.dart';
import 'services/MySchedule.dart';
import 'services/user.dart';
import 'package:iris_flutter/services/search.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

 @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Lectures>(builder: (context) => Lectures()),
        ChangeNotifierProvider<User>(builder: (context) => User.instance()),
        ChangeNotifierProvider<Search>(builder: (context) => Search()),
        ChangeNotifierProvider<MySchedule>(builder: (context) => MySchedule()),
        ChangeNotifierProvider<Chat>(builder: (context) => Chat()),
        ChangeNotifierProvider<Invitations>(builder: (context) => Invitations()),
        // ChangeNotifierProvider<DatabaseSync>(builder: (context) => DatabaseSync()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gramado Summit',
        theme: ThemeData(
          primaryColor: Color(0xFF8E8E8E),
          secondaryHeaderColor: Color(0xFFB4B4B4),
          scaffoldBackgroundColor: Color(0xFFF2F2F2),//Color(0xFFF5F5F5),
          ),
        home: HomeScreen(),
      ),
    );
  }
}