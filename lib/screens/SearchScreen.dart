import 'package:algolia/algolia.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:iris_flutter/services/search.dart';
import 'package:provider/provider.dart';
import 'package:iris_flutter/screens/ChatScreen.dart';
import 'package:iris_flutter/services/user.dart';

class SearchScreen extends StatefulWidget {

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
String searchTextField = '';



  @override
  Widget build(BuildContext context) {
  var search = Provider.of<Search>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).secondaryHeaderColor,
            height: 75,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: SizedBox(
                    height: 56,
                    width: 56,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: BackButton(color: Colors.white,)
                    )  
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text("Nova conversa", style: TextStyle(color: Colors.white, fontSize: 18.5, fontWeight: FontWeight.w900),),
                  ),
                )
              ],
            ),
          ),
          Container(
            color: Theme.of(context).secondaryHeaderColor,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 30, right: 30),
              child: TextField(
                textCapitalization: TextCapitalization.words,
                cursorColor: Color(0xFFB4B4B4),
                cursorWidth: 1.2,
                style: TextStyle(color: Colors.white, fontSize: 17, height: 1),
                onChanged: (val) => setState((){
                  searchTextField = val;
                }),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                  labelText: "Pesquise aqui para conversar",
                  hasFloatingPlaceholder: false,
                  labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Color(0xFFb4b4b4), height: 2),
                ),
              ),
            ),
          ),
          Flexible(
            child: Container(
              color: Color(0xFFF5F5F5),
              child: FutureBuilder(
                future: search.testAlgo(searchTextField),
                builder: (BuildContext context, AsyncSnapshot<AlgoliaQuerySnapshot> snapshot ) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(backgroundColor: Color(0xFFf55288),),
                          ],
                        ),
                      );
                    }
                  else if(searchTextField.length <= 1) return Container();
                  return ListView.builder(
                    itemCount: snapshot.data.hits.length,
                    itemBuilder: (BuildContext context, int index) {

                      String queryName = snapshot.data.hits[index].data['name'].toString().isNotEmpty && snapshot.data.hits[index].data['name'] != null ? snapshot.data.hits[index].data['name'] : 'Participante';
                      String queryPosition = snapshot.data.hits[index].data['position'].toString().isNotEmpty && snapshot.data.hits[index].data['position'] != null ? snapshot.data.hits[index].data['position']+' em ' : 'Visitante - ';
                      String queryCompany = snapshot.data.hits[index].data['company'].toString().isNotEmpty && snapshot.data.hits[index].data['company'] != null ? snapshot.data.hits[index].data['company'] : 'Gramado Summit';
                      String queryImage = snapshot.data.hits[index].data['picture'].toString().isNotEmpty && snapshot.data.hits[index].data['picture'] != null? snapshot.data.hits[index].data['picture'] : 'https://scontent.fpoa2-1.fna.fbcdn.net/v/t1.0-0/p370x247/41654574_716754288671534_4855720008577187840_n.png?_nc_cat=106&_nc_oc=AQmSgepAIMZTr-wV3AbJvRoLRwY4UQgwM_Wlg5-kIu8aNXlCbCBEono7gzmGaVkLHZw&_nc_ht=scontent.fpoa2-1.fna&oh=1ce63ce35551f007b6b0c73ed783c025&oe=5DABF9B3';

                      return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: GestureDetector(
                        onTap: () => openNewChat(snapshot.data.hits[index].data['userID'], queryName, context, queryImage, queryPosition+queryCompany),
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            children: <Widget>[
                              SizedBox(height: 85, width: 85, 
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                      image: NetworkImage(queryImage),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                                child: Container(
                                  width: normalizedWidth(context, 200),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(queryName, style: TextStyle(fontSize: 15.5, color: Color(0xFF666666), fontWeight: FontWeight.bold), maxLines: 1,),
                                      Text(queryPosition + queryCompany, style: TextStyle(fontSize: 10.5, color: Color(0xFFacacac), fontWeight: FontWeight.w300), maxLines: 1,),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ),
                      ),
                    );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

openNewChat(String otherUserID, String otherUserName, BuildContext context, String otherUserPicture, String otherUserPosition) async{
  var auth = Provider.of<User>(context);
  String _userID = auth.user.uid;

    print("SETUP CHAT: " + _userID.toString());
    print("SETUP CHAT: " + otherUserID.toString());


  Navigator.push(context, MaterialPageRoute<void>(
    builder: (context) => ChatScreen(otherUserID, _userID, context, otherUserName, otherUserPicture, otherUserPosition)
  ));
}

}
