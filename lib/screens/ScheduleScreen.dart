import 'package:flutter/material.dart';
import 'package:iris_flutter/components/scheduleWidgets.dart';


class ScheduleScreen extends StatefulWidget {

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

  PageController _pageController;
  int currentPage;
  int nextPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: getInitialDay());
    currentPage = getInitialDay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      body: Column(
        children: <Widget>[
          header(currentPage, _pageController),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                pageChanged(index);
              },
              children: <Widget>[
                firstDay(context),
                secondDay(context),
                thirdDay(context)
              ],
            ),
          ),
        ],
      ),
    );
  }

  void pageChanged(int index) {
    setState(() {
      currentPage = index;
    });
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

}

