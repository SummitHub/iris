import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/components/tagBox.dart';
import 'package:iris_flutter/services/MySchedule.dart';
import 'package:iris_flutter/models/lecture.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:iris_flutter/models/appointments.dart';

class LectureScreen extends StatefulWidget {
  LectureScreen(this.lecture);
  final Lecture lecture;

  @override
  _LectureScreenState createState() => _LectureScreenState(lecture);
}

class _LectureScreenState extends State<LectureScreen> {
  _LectureScreenState(this.lecture);
  final Lecture lecture;
  int buttonState = 2;
  bool isOnMySchedule = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkAppointment();
  }

  checkAppointment() async {
    var mySchedule = Provider.of<MySchedule>(context);
    isOnMySchedule = await mySchedule.checkAppointment(lecture.id, context);
    setState(() => buttonState = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                innerImagesReady(widget.lecture.getSpeakersImages(widget.lecture.speakers), context),
                Container(
                  color: Theme.of(context).secondaryHeaderColor,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      titleAndSubtitle(context),
                      Divider(
                        color: Color(0xFF707070),
                      ),
                      detailsSection(context),
                      tagsSection(context),
                    ],
                  ),
                ),
                descriptionSection(context),
                SizedBox(height: 100,)
              ],
            )
          ),

          if (buttonState == 1) buttonOverlay(context, isOnMySchedule),
          if (buttonState == 2) loadingOverlay() ,
          
          Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 5),
          child: BackButton(color: Colors.white),
        ),
        ],
      )
    );
  }


  Widget innerImagesReady(List images, context) {
    if (images.length == 1) {
      return SizedBox(
        height: 245,
        width: MediaQuery.of(context).size.width,
        child: CachedNetworkImage(
          imageUrl: images[0], 
          fit: BoxFit.fitWidth,
          alignment: Alignment(-0.5, -0.5),
          ),
      );
    } 
    else if (images.length == 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
              child: CachedNetworkImage(
                imageUrl: images[0],
                width: MediaQuery.of(context).size.width,
                height: 122.5,
                fit: BoxFit.cover,
                placeholder: (context, url) => LinearProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(topRight: Radius.circular(0.0),),
              child: CachedNetworkImage(
                imageUrl: images[1],
                width: MediaQuery.of(context).size.width,
                height: 122.5,
                fit: BoxFit.cover,
                placeholder: (context, url) => LinearProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ],
      );
    } else if (images.length == 3) {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: (0.5)*MediaQuery.of(context).size.width,
                height: 122.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
                    child: CachedNetworkImage(
                      imageUrl: images[0],
                      width: (0.5)*MediaQuery.of(context).size.width,
                      height: 122.5,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => LinearProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              SizedBox(
                width: (0.5)*MediaQuery.of(context).size.width,
                height: 122.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(0.0),),
                    child: CachedNetworkImage(
                      imageUrl: images[1],
                      width: (0.5)*MediaQuery.of(context).size.width,
                      height: 122.5,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => LinearProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 122.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
                    child: CachedNetworkImage(
                      imageUrl: images[2],
                      width: MediaQuery.of(context).size.width,
                      height: 122.5,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => LinearProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ],
          ),  
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: (0.5)*MediaQuery.of(context).size.width,
                height: 122.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
                    child: CachedNetworkImage(
                      imageUrl: images[0],
                      width: (0.5)*MediaQuery.of(context).size.width,
                      height: 122.5,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => LinearProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              SizedBox(
                width: (0.5)*MediaQuery.of(context).size.width,
                height: 122.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(0.0),),
                    child: CachedNetworkImage(
                      imageUrl: images[1],
                      width: (0.5)*MediaQuery.of(context).size.width,
                      height: 122.5,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => LinearProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: (0.5)*MediaQuery.of(context).size.width,
                height: 122.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
                    child: CachedNetworkImage(
                      imageUrl: images[2],
                      width: (0.5)*MediaQuery.of(context).size.width,
                      height: 122.5,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => LinearProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              SizedBox(
                width: (0.5)*MediaQuery.of(context).size.width,
                height: 122.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(0.0),),
                    child: CachedNetworkImage(
                      imageUrl: images[3],
                      width: (0.5)*MediaQuery.of(context).size.width,
                      height: 122.5,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => LinearProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  String allNames(){
    List<String> listOfNames = [];
    widget.lecture.speakers.forEach((speaker) => listOfNames.add(speaker['title']));
    listOfNames.sort();
    return listOfNames.join(", ");
  }

  titleAndSubtitle(context){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 0.0,),
            child: Text(widget.lecture.title.toString().toUpperCase(), 
              style: TextStyle(fontSize: 36, color: Theme.of(context).primaryColor)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Text((widget.lecture.speakers.length > 1) 
            ? allNames().toUpperCase()
            : (widget.lecture.speakers[0]['title'].toString() + ' - ' + widget.lecture.speakers[0]['position'] + "/" + widget.lecture.speakers[0]['company']), 
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 8, color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  detailsSection(context){
    String dia;
    switch (widget.lecture.startDate) {
      case '2019-07-31':
        dia = "31 de Julho";
        break;
      case '2019-08-01':
        dia = "1º de Agosto";
        break;
      case '2019-08-02':
        dia = "2 de Agosto";
        break;
      default:
        dia = "--";
    }
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center ,
            children: <Widget>[
              Icon(FontAwesomeIcons.calendarAlt, color: Theme.of(context).primaryColor,size: 10),
              Text(" " + dia, style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor))
            ] 
          ),
          Row(
            children: <Widget>[
              Icon(FontAwesomeIcons.clock, color: Theme.of(context).primaryColor, size: 10),
              Text(" " + widget.lecture.startTime.substring(0,5) + " - " + widget.lecture.endTime.substring(0,5), style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor))
            ] 
          ),
          Row(
            children: <Widget>[
              Icon(FontAwesomeIcons.mapMarkerAlt, color: Theme.of(context).primaryColor, size: 10),
              Text(widget.lecture.location == 'principal'
                  ? ' Palco Getnet'
                  : ' Palco ' + widget.lecture.location[0].toUpperCase() + widget.lecture.location.substring(1),
              style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor))
            ] 
          ),
        ],
      ),
    );
  }

  tagsSection(BuildContext context){
    List<Widget> tags =[];
    for (String tag in widget.lecture.speakers[0]['tags']) {
      tags.add(tagBox(tag[0].toUpperCase() + tag.substring(1), context, Theme.of(context).primaryColor, Theme.of(context).secondaryHeaderColor));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Container(
        width: MediaQuery.of(context).size.width-60,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: -4,
          children: tags
        )      
      ),
    );
  }

  descriptionSection(context){
    return Padding(
      padding: EdgeInsets.only(left: 30, right: 30, top: 40),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              (widget.lecture.speakers.length > 1) 
            ? Text("Sobre os Painelistas",
                style: TextStyle(fontSize: 17.3, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))
            : Text("Sobre o(a) Palestrante",
                style: TextStyle(fontSize: 17.3, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            ],
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: speakersDescription(context),
          )
        ],
      ),
    );
  }

  speakersDescription(context) {
    print(widget.lecture.speakers.toString());
    return (widget.lecture.speakers.length > 1) 
    ? Column(
      children: <Widget>[
        allSpeakersDescriptions()
      ], 
    ) : (widget.lecture.speakers[0]['description'].length > 0) 
    ? Text(widget.lecture.speakers[0]['description'],
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, color: Color(0xFF989898)),  
      )
    : Column(
        children: <Widget>[
          Text('Sem descrição.',
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.5, color: Color(0xFF989898)),  
          ),
        ],
      );
  }

  allSpeakersDescriptions(){
    List<Widget> descriptions = [];
    for (var speaker in widget.lecture.speakers){
      descriptions.add(
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.lecture.speakers[widget.lecture.speakers.indexOf(speaker)]['title'],
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0, color: Color(0xFF989898)),  
              ),
            ),
            (widget.lecture.speakers[widget.lecture.speakers.indexOf(speaker)]['description'].length > 0) 
            ? Text(widget.lecture.speakers[widget.lecture.speakers.indexOf(speaker)]['description'],
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
          ],
        ),
      );
    }
    return Column(children: descriptions);
  }

  loadingOverlay(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(height: 70, child: CircularProgressIndicator()),
      ),
    );
  }

  buttonOverlay(BuildContext context, bool isOnMySchedule){
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FlatButton(
          padding: EdgeInsets.zero,
          onPressed: () => !isOnMySchedule ? addToMySchedule(context) : removeFromMySchedule(widget.lecture.id, context),
          child: Container(
            height: 65,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 2,),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                        ),
                        height: 60,
                        width: normalizedWidth(context, 292),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 4,),
                    Container(
                      height: 60  ,
                      width: normalizedWidth(context, 290),
                      color: Theme.of(context).primaryColor,
                      child: Center(child: Text(!isOnMySchedule ? 'ADICIONAR A AGENDA': 'REMOVER DA AGENDA', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  addToMySchedule(context)async{
    setState(() => buttonState = 2);
    var mySchedule = Provider.of<MySchedule>(context);
    await mySchedule.addLecture(widget.lecture, context);
    setState(() {
      isOnMySchedule = true;
      buttonState = 1;
    });
    _scaffoldKey.currentState.showSnackBar( SnackBar( content: Text("Adicionado à agenda")));
  }

  removeFromMySchedule(String appointmentId, context) async {
    setState(() => buttonState = 2);
    var mySchedule = Provider.of<MySchedule>(context);
    await mySchedule.removeAppointment(appointmentId, context, Type.Lecture);
    setState(() {
      isOnMySchedule = false;
      buttonState = 1;
    });
    _scaffoldKey.currentState.showSnackBar( SnackBar( content: Text("Removido da agenda")));
  }
}