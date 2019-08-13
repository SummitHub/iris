import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/services/MySchedule.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';
import 'package:iris_flutter/components/myScheduleWidgets.dart';

class MyScheduleScreen extends StatefulWidget {
  MyScheduleScreen(this._tabController);
  CupertinoTabController _tabController;
  @override
  _MyScheduleScreenState createState() => _MyScheduleScreenState(_tabController);
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  _MyScheduleScreenState(this._tabController);
  CupertinoTabController _tabController;
  PageController _pageController;
  int currentPage;
  int nextPage;
  bool snapshotPrepared = false;
  String currentDay = '2019-07-31';
  List<List<DocumentSnapshot>> filteredSnapshot = [[],[],[]];
  bool appointmentsReady = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: getInitialDay());
    currentPage = getInitialDay();
  }

  void pageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  String getCurrentDay(currentPage) {
    switch (currentPage){
      case 0: 
        return '2019-07-31';
        break;
      case 1: 
        return '2019-08-01';
        break;
      case 2:  
        return '2019-08-02';
        break;
      default:
        return '2019-07-31';
        break;
    } 
  }

  int getInitialDay() {
    int today = DateTime.now().day.toInt();
    switch (today){
      case 31: 
        return 0;
        break;
      case 1: 
        return 1;
        break;
      case 2:  
        return 2;
        break;
      default:
        return 0;
        break;
    } 
  }

 @override
  Widget build(BuildContext context) {
    print(getCurrentDay(currentPage));
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      body: Column(
        children: <Widget>[
          headerSchedule(currentPage, _pageController),
          Expanded(
            child: Container(
              color: Color(0xFFF2F2F2),
              child: Consumer<MySchedule>(
                builder: (BuildContext context, mySchedule, Widget child) {
                  return PageView.builder(
                    controller: _pageController,
                    physics: AlwaysScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      pageChanged(index);
                    },
                    itemCount: 3,
                    itemBuilder: (context, position){
                      return dayStream(context, position); 
                    },
                  );
                }
              ),
            ),
          )
        ],
      )
    );
  }
  
  dayStream(BuildContext context, int position) {
    var user = Provider.of<User>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').document(user.id).collection('schedule').orderBy('startTime').where('startDate', isEqualTo: getCurrentDay(position)).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }
        return ListView(
          children: appointmentList(snapshot, context, _pageController, _tabController),
        );
      }
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}