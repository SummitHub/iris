import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iris_flutter/components/loadingSpinner.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:iris_flutter/services/search.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:iris_flutter/screens/ProfileScreen.dart';
import 'package:provider/provider.dart';

class SearchScreenWidget extends StatelessWidget {
  SearchScreenWidget(this.searchTextField, this._homeTabController);
  CupertinoTabController _homeTabController = CupertinoTabController();
  final String searchTextField;

  @override
  Widget build(BuildContext context) {
  var search = Provider.of<Search>(context);
    print('text: $searchTextField');

    return Container(
      height: MediaQuery.of(context).size.height,
      child: (searchTextField.length > 2)
        ?FutureBuilder( 
          future: search.testAlgo(searchTextField),
          builder: (BuildContext context, AsyncSnapshot<AlgoliaQuerySnapshot> snapshot ) {
      
            if (!snapshot.hasData) {
                return Center(
                    child: LoadingSpinner(false)
                  );
              }
            if (snapshot.data.hits.length < 1) return noResultsMessage();
            return ListView(children: listUsers(snapshot, context) );
          },
        )
        :fewCharsMessage(),
    );
  }
  
  noResultsMessage(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Text("Sem resultados para sua pesquisa", style: TextStyle(color: Color(0xFF707070)),)
    );
  }
  fewCharsMessage(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Text(". . .", style: TextStyle(color: Color(0xFF707070), fontSize: 20),)
    );
  }
  openInnerPage(String id, BuildContext context){
    var user = Provider.of<User>(context);
    id == user.id
    ? _homeTabController.index = 4
    : Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(
      builder: (context) => ProfileScreen(id)
    ));

  }

  List<Widget> listUsers(AsyncSnapshot<AlgoliaQuerySnapshot> snapshot, BuildContext context){
    var result= snapshot.data.hits
        .map((doc) {
          String queryName = doc.data['name'].toString().isNotEmpty && doc.data['name'] != null ? doc.data['name'] : 'Participante';
          String queryPosition = doc.data['position'].toString().isNotEmpty && doc.data['position'] != null ? doc.data['position']+' em ' : 'Visitante - ';
          String queryCompany = doc.data['company'].toString().isNotEmpty && doc.data['company'] != null ? doc.data['company'] : 'Gramado Summit';
          String queryImage = doc.data['picture'].toString().isNotEmpty && doc.data['picture'] != null? doc.data['picture'] : 'https://scontent.fpoa2-1.fna.fbcdn.net/v/t1.0-0/p370x247/41654574_716754288671534_4855720008577187840_n.png?_nc_cat=106&_nc_oc=AQmSgepAIMZTr-wV3AbJvRoLRwY4UQgwM_Wlg5-kIu8aNXlCbCBEono7gzmGaVkLHZw&_nc_ht=scontent.fpoa2-1.fna&oh=1ce63ce35551f007b6b0c73ed783c025&oe=5DABF9B3';

          return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: GestureDetector(
            onTap: () => openInnerPage(doc.data['userID'], context),
            child: Container(
              height: 85,
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
                      width: normalizedWidth(context, 220),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(queryName, style: TextStyle(fontSize: 15.5, color: Color(0xFF666666), fontWeight: FontWeight.bold),maxLines: 1,),
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
      }).toList();  
    result.add( Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),child: SizedBox(height: MediaQuery.of(context).size.height/2)));
    return result;
  }
}




