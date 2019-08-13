import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/components/lectureWidgets.dart';
import 'package:iris_flutter/services/Lectures.dart';
import 'package:provider/provider.dart';

handleDayChange(String direction, PageController pageController, currentPage) {
  if (direction == 'right') {
    if (currentPage == 2) {
      pageController.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      pageController.nextPage(duration: Duration(milliseconds: 400), curve: Curves.ease);
    }
  }
  if (direction == 'left') {
    if (currentPage == 0) {
      pageController.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      pageController.previousPage(duration: Duration(milliseconds: 400), curve: Curves.ease);
    }
  }
}

prettyDayByPage(BuildContext context, lectures, currentPage){
    String month, mday, wday;
    switch (currentPage){
      case 0 : 
        month = "de Julho";
        mday = "31";
        wday = "Quarta";
        break;
      case 1 : 
        month = "de Agosto";
        mday = "1º";
        wday = "Quinta";
        break;
      case 2 :  
        month = "de Agosto";
        mday = "02";
        wday = "Sexta";
        break;
      default:
        month = "ERRO";
        mday = "XX";
        wday = "404";
        break;
    } 
    return Container(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(mday, style: TextStyle(fontSize: 46, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700,)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(month.toUpperCase(), style: TextStyle(fontSize: 17.3, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700, height: 0.8)),
              Text(wday.toUpperCase(), style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700,height: 0.8)),
            ],
          )
        ],
      ),
    );
  }

prettyDay(BuildContext context, lectures){
    String month, mday, wday;
    switch (lectures.currentDay){
      case '2019-07-31' : 
        month = "de Julho";
        mday = "31";
        wday = "Quarta";
        break;
      case '2019-08-01' : 
        month = "de Agosto";
        mday = "01º";
        wday = "Quinta";
        break;
      case '2019-08-02' :  
        month = "de Agosto";
        mday = "02";
        wday = "Sexta";
        break;
      default:
        month = "ERRO";
        mday = "XX";
        wday = "404";
        break;
    } 
    return Container(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(mday, style: TextStyle(fontSize: 46, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700,)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(month.toUpperCase(), style: TextStyle(fontSize: 17.3, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700, height: 0.8)),
              Text(wday.toUpperCase(), style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700,height: 0.8)),
            ],
          )
        ],
      ),
    );
  }

Widget firstDay(context) {
  return Column(
    children: <Widget>[
      Expanded(
        child: Container(
          color: Color(0xFFF2F2F2),
          child: Consumer<Lectures>(
            builder: (BuildContext context, lectures, Widget child) {
              if (lectures.shouldFetchData) {
                lectures.fetchInitialData();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: lectures.filteredGroupedLectures[0].length,
                  itemBuilder: (context, position) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 7.5),
                      child: lectureCard(context,
                        lectures.filteredGroupedLectures[0][position]
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

Widget secondDay(context) {
  return Column(
    children: <Widget>[
      Expanded(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Color(0xFFF2F2F2),
          child: Consumer<Lectures>(
            builder: (BuildContext context, lectures, Widget child) {
              if (lectures.shouldFetchData) {
                lectures.fetchInitialData();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: lectures.filteredGroupedLectures[1].length,
                  itemBuilder: (context, position) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 7.5),
                      child: lectureCard( 
                        context,
                        lectures.filteredGroupedLectures[1][position]
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

Widget thirdDay(context) {
  return Column(
    children: <Widget>[
      Expanded(
        child: Container(
          color: Color(0xFFF2F2F2),
          child: Consumer<Lectures>(
            builder: (BuildContext context, lectures, Widget child) {
              if (lectures.shouldFetchData) {
                lectures.fetchInitialData();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: lectures.filteredGroupedLectures[2].length,
                  itemBuilder: (context, position) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 7.5),
                      child: lectureCard( 
                        context,
                        lectures.filteredGroupedLectures[2][position]
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

Widget header(currentPage, PageController pageController) {
  return Column(
      children: <Widget>[
        SizedBox(
          height: 75,
          child: Stack(
            children: <Widget>[              
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text("Agenda do Evento", style: TextStyle(color: Colors.white, fontSize: 18.5, fontWeight: FontWeight.w900),),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Container(
            child: Consumer<Lectures>(
              builder: (context, lectures , _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => handleDayChange('left', pageController, currentPage),
                    child: Container(
                      color: Colors.transparent,
                      width: 95,
                      child: Center(
                        child: Text("<", 
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  prettyDayByPage(context, lectures, currentPage),
                  GestureDetector(
                    onTap: () => handleDayChange('right', pageController, currentPage),
                    child: Container(
                      width: 95,
                      color: Colors.transparent,
                      child: Center(
                        child: Text(">", 
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            width: 280,
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color:  Color(0xFF8E8E8E), width: 1)
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.5),
            child: DropdownButtonHideUnderline(
                child: Consumer<Lectures>(
                builder: (BuildContext context, lectures, Widget child) => 
                DropdownButton<String>(
                  style: TextStyle(
                    color: Color(0xFFE1EC49),
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5
                  ),
                  icon: Icon(FontAwesomeIcons.chevronDown, size: 12, color:  Color(0xFF8E8E8E)),
                  value: lectures.dropdownValue,
                  onChanged: (String newValue) => newValue==lectures.dropdownValue ? null : lectures.filterByStage(newValue),
                  items: lectures.dropdownOptions.keys.toList()
                    .map<DropdownMenuItem<String>>((String menuItemText) {
                      return DropdownMenuItem<String>(                          
                        value: menuItemText,
                        child: Container(
                          child: Text(menuItemText.toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor),)),
                      );
                    })
                  .toList(),
                )
              ),
            ),
          ),
        )
      ],
    );
}