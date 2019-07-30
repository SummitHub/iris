import 'package:flutter/material.dart';
// import 'package:iris_flutter/components/inviteCard.dart';
// import 'package:iris_flutter/services/Lectures.dart';
// import 'package:provider/provider.dart';
// import '../components/lectureWidgets.dart';


class InvitationScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text("Solicitações de Reunião"),
        ),
        body: Column(
          children: <Widget>[

          ],
        )
      ),
    );
  }
}