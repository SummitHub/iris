import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:photo_view/photo_view.dart';

class EventMapWidget extends StatefulWidget {
  _EventMapWidgetState createState() => _EventMapWidgetState();
}

class _EventMapWidgetState extends State<EventMapWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openMap(context),
        child: Stack(
          children: <Widget>[
            Container(
              color: Color(0xFFE5E5E5),
              height: normalizedWidth(context, 185.6),
              width: normalizedWidth(context, 185.6*(180/100)),
            ),
            Container(
              color: Color(0xFF1EAAF4),
              height: normalizedWidth(context, 185.6),
              child: SvgPicture.asset('assets/images/fullmap.svg'),
            ),
          ],
        ),
    );
  }


  openMap(context){
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      builder: (context) => MapScreen()
    ));
  }
}


class MapScreen extends StatelessWidget {
  const MapScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: PhotoView.customChild(
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained*15,
              childSize: MediaQuery.of(context).size,
              child: Container(
                color: Color(0xFF1EAAF4),
                child: SvgPicture.asset('assets/images/fullmap.svg'),
              )
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            
            child: Align(
              alignment: Alignment.topLeft  ,
              child: Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: BackButton(color: Color(0xFFE1EC49),),
              ),
            ),
          )
        ],
      ),
    );
  }
}