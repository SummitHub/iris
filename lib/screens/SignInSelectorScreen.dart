import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/screens/LoginScreen.dart';
import 'package:iris_flutter/screens/QrScreen.dart';


class SignInSelectorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).secondaryHeaderColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            titleAndSubtitle(context),
            SizedBox(height: 40,),
            buttons(context)
          ],
        ),
      )
    );
  }

  titleAndSubtitle(context){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30,),
      child: Column(
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 25,
              height: 25,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor
                  
                )
              )
            ),
          ),
          SizedBox(height:10,),
          Text('Bem vindo(a) à'.toUpperCase(), textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: 24),),
          Text('Gramado Summit'.toUpperCase(), textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: 24),),

        ],
      ),
    );
  }

  
  buttons(BuildContext context){
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlatButton(
            onPressed:  () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => LoginScreen()
            )),
            child: Container(
              width: (244/360)*MediaQuery.of(context).size.width,
              height: 65,
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 2,),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                        ),
                        height: 60,
                        width: (242/360)*MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 4,),
                      Container(
                        height: 60  ,
                        width: (240/360)*MediaQuery.of(context).size.width,
                        color: Theme.of(context).primaryColor,
                        child: Center(child: Text("ENTRAR", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlatButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => QrScreen()
            )),
            child: Container(
              width: (244/360)*MediaQuery.of(context).size.width,
              height: 65,
              child: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 2,),
                      Container(
                        decoration: BoxDecoration(
                                                    color: Colors.white,
                          border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                        ),
                        height: 60,
                        width: (242/360)*MediaQuery.of(context).size.width,
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 4,),
                      Container(
                        height: 60  ,
                        width: (240/360)*MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                        ),
                        child: Center(child: Text("REGISTRAR", style: TextStyle(fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor, fontSize: 13.8))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}