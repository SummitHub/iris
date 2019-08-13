import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/models/lecture.dart';
import 'package:iris_flutter/screens/LectureScreen.dart';

Widget lectureCard(BuildContext context, Lecture lecture) {
  return GestureDetector(
    onTap: () => {Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      builder: (context) => LectureScreen(lecture)))},
    child: speakerCard( lecture, imagesReady(lecture.getSpeakersImages(lecture.speakers), context), context),
  );
}

Widget imagesReady(List images, context) {
  if (images.length == 1) {
    return SizedBox(
      height: 152.0,
      width: (300/360)*MediaQuery.of(context).size.width,
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0), topRight: Radius.circular(0.0),),
          child: CachedNetworkImage(
            imageUrl: images[0],
            width: (300/360)*MediaQuery.of(context).size.width,
            height: 152.0,
            fit: BoxFit.cover,
            placeholder: (context, url) => LinearProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
        ),
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
              width: (300/360)*MediaQuery.of(context).size.width,
              height: 60.0,
              fit: BoxFit.cover,
              placeholder: (context, url) => LinearProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(0.0),),
            child: CachedNetworkImage(
              imageUrl: images[1],
              width: (300/360)*MediaQuery.of(context).size.width,
              height: 60.0,
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
              width: (0.147)*MediaQuery.of(context).size.width,
              height: 60.0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
                  child: CachedNetworkImage(
                    imageUrl: images[0],
                    width: (0.147)*MediaQuery.of(context).size.width,
                    height: 60.0,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => LinearProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(
              width: (0.147)*MediaQuery.of(context).size.width,
              height: 60.0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topRight: Radius.circular(0.0),),
                  child: CachedNetworkImage(
                    imageUrl: images[1],
                    width: (0.147)*MediaQuery.of(context).size.width,
                    height: 60.0,
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
              width: (106.5/360)*MediaQuery.of(context).size.width,
              height: 60.0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
                  child: CachedNetworkImage(
                    imageUrl: images[2],
                    width: (106.5/360)*MediaQuery.of(context).size.width,
                    height: 60.0,
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
              width: (0.147)*MediaQuery.of(context).size.width,
              height: 60.0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
                  child: CachedNetworkImage(
                    imageUrl: images[0],
                    width: (0.147)*MediaQuery.of(context).size.width,
                    height: 60.0,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => LinearProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(
              width: (0.147)*MediaQuery.of(context).size.width,
              height: 60.0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topRight: Radius.circular(0.0),),
                  child: CachedNetworkImage(
                    imageUrl: images[1],
                    width: (0.147)*MediaQuery.of(context).size.width,
                    height: 60.0,
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
            width: (0.147)*MediaQuery.of(context).size.width,
            height: 60.0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: const Radius.circular(0.0)),
                child: CachedNetworkImage(
                  imageUrl: images[2],
                  width: (0.147)*MediaQuery.of(context).size.width,
                  height: 60.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => LinearProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
          SizedBox(
            width: (0.147)*MediaQuery.of(context).size.width,
            height: 60.0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topRight: Radius.circular(0.0),),
                child: CachedNetworkImage(
                  imageUrl: images[3],
                  width: (0.147)*MediaQuery.of(context).size.width,
                  height: 60.0,
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

Widget speakerCard(Lecture lecture, Widget imagesReady, context) {
  Color bgColor;
  Color fontColor;
  switch (lecture.location){
    case 'principal': 
      bgColor = Theme.of(context).primaryColor;
      fontColor = Colors.white;
      break;
    case 'share': 
      bgColor = Theme.of(context).secondaryHeaderColor;
      fontColor = Color(0xFFFFFFFF);
      break;
    case 'comunidade': 
      bgColor = Color(0xFFD2D2D2);
      fontColor = Theme.of(context).primaryColor;
      break;
    default:  
      bgColor = Color(0xFF000BC0);
      fontColor = Color(0xFFFFFFFF);
      break;
  }
  return SizedBox(
    height: 120,
    child: Row(
      children: <Widget>[
        Flexible(
          flex: 111,
          child: imagesReady),
        Flexible(
          flex: 239,
          child: Container(
            color: bgColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 17.5, right: 17.5, top: 12, bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0,),
                          child: Text(
                            lecture.title.toString().toUpperCase(), maxLines: 3,
                            style: TextStyle(fontSize: 21, color: fontColor, height: 0.85)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Text((lecture.speakers.length > 1) 
                            ? allNames(lecture).toUpperCase()
                            : (lecture.speakers[0]['title'].toString() + ' - ' + lecture.speakers[0]['position'] + "/" + lecture.speakers[0]['company']).toUpperCase(), 
                            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 6, color: fontColor, height: 1.4), 
                            maxLines: 2
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Divider(
                        height: 12,
                        color: Color(0x1F000000),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.clock, color: fontColor, size: 10),
                              Text(" " + lecture.startTime.substring(0,5) + " - " + lecture.endTime.substring(0,5), style: TextStyle(fontSize: 8.7, color: fontColor))
                            ] 
                          ),
                          Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.mapMarkerAlt, color: fontColor, size: 10),
                              Text(lecture.location == 'principal'
                                ? ' Palco Getnet'
                                : ' Palco ' + lecture.location[0].toUpperCase() + lecture.location.substring(1),
                                style: TextStyle(fontSize: 8.7, color: fontColor))
                            ] 
                          ),
                        ]
                      )
                    ],
                  )
                 ],
               ),
            ),
          ),
         )
       ],
     ),
   );
}

  String allNames(lecture){
  List<String> listOfNames = [];
  lecture.speakers.forEach((speaker) => listOfNames.add(speaker['title']));
  listOfNames.sort();
  return listOfNames.join(", ");
  }
