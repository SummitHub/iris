import 'package:algolia/algolia.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:iris_flutter/services/search.dart';
import 'package:provider/provider.dart';
import 'package:iris_flutter/services/user.dart';

class SearchAndSelectUserWidget extends StatefulWidget {
  SearchAndSelectUserWidget(this.selectedUsers);
  final List<Map<String, String>> selectedUsers;

  @override
  _SearchAndSelectUserWidgetState createState() => _SearchAndSelectUserWidgetState(selectedUsers);
}

class _SearchAndSelectUserWidgetState extends State<SearchAndSelectUserWidget> {
_SearchAndSelectUserWidgetState(this.selectedUsers);
String searchTextField = '';
List<Map<String, String>> selectedUsers = [];
String ownId = '';


  @override
  void didChangeDependencies() {
    ownId = Provider.of<User>(context).id;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
  var search = Provider.of<Search>(context);
  print('height: ' + MediaQuery.of(context).size.height.toString() + "  width: " + MediaQuery.of(context).size.width.toString());
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
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
                        child: Text("Agendar Reunião", style: TextStyle(color: Colors.white, fontSize: 18.5, fontWeight: FontWeight.w900),),
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
                    style: TextStyle(color: Colors.white, fontSize: 17, height: 1),
                    onChanged: (val) => setState((){
                      searchTextField = val;
                    }),
                    cursorColor: Color(0xFFB4B4B4),
                    cursorWidth: 1.2,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 0, bottom: 0),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(width: 2)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                      labelText: "Pesquise aqui para convidar",
                      hasFloatingPlaceholder: false,
                      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Color(0xFFb4b4b4), height: 1),
                      suffixIcon: Icon(Icons.search, color: Color(0xFFb4b4b4), size: 25,)
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
                                CircularProgressIndicator(),
                              ],
                            ),
                          );
                        }
                      else if(searchTextField.length <= 1) return Container();
                      return ListView.builder(
                        padding: EdgeInsets.only(top: 10, bottom: 80),
                        itemCount: snapshot.data.hits.length,
                        itemBuilder: (BuildContext context, int index) {
                          String queryName = snapshot.data.hits[index].data['name'].toString().isNotEmpty && snapshot.data.hits[index].data['name'] != null ? snapshot.data.hits[index].data['name'] : 'Participante';
                          String queryPosition = snapshot.data.hits[index].data['position'].toString().isNotEmpty && snapshot.data.hits[index].data['position'] != null ? snapshot.data.hits[index].data['position']+' em ' : 'Visitante - ';
                          String queryCompany = snapshot.data.hits[index].data['company'].toString().isNotEmpty && snapshot.data.hits[index].data['company'] != null ? snapshot.data.hits[index].data['company'] : 'Gramado Summit';
                          Map<String, String> userDetails = {
                            'id' : snapshot.data.hits[index].data['userID'],
                            'name' : snapshot.data.hits[index].data['name'],
                          };
                          bool unselected = !selectedUsers.toString().contains(snapshot.data.hits[index].data['userID']);
                          return snapshot.data.hits[index].data['userID'] != ownId
                          ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 5),
                            child: GestureDetector(
                              onTap: unselected ? () => addInvitee(userDetails) : () => removeInvitee(userDetails),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                  height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: unselected ? null : Border.all(width: 1.8, color: Theme.of(context).primaryColor)
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          height: 90, 
                                          width: 91, 
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                width: 1,
                                                color: Theme.of(context).primaryColor
                                              )
                                            )
                                          ),
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) => LinearProgressIndicator(), 
                                            imageUrl: snapshot.data.hits[index].data['picture'].isNotEmpty ? snapshot.data.hits[index].data['picture'] : null, 
                                            fit: BoxFit.fitWidth
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                                          child: Container(
                                            width: normalizedWidth(context, 162),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(queryName, style: TextStyle(fontSize: 16, color: Color(0xFF666666), fontWeight: FontWeight.bold),maxLines: 1,),
                                                Text(queryPosition + queryCompany, style: TextStyle(fontSize: 10.5, color: Color(0xFFACACAC), fontWeight: FontWeight.w300 ), maxLines: 1,),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]
                                    ),
                                  ),
                                  unselected ? SizedBox() : Positioned(
                                    top: 5,
                                    left: 5,
                                    child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor,),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : SizedBox();
                        
                        
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: FlatButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                      width: (296/360)*MediaQuery.of(context).size.width,
                      height: 55,
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(height: 2,),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                                ),
                                height: 50,
                                width: (293/360)*MediaQuery.of(context).size.width,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(width: 4,),
                              Container(
                                height: 50  ,
                                width: (290/360)*MediaQuery.of(context).size.width,
                                color: Theme.of(context).primaryColor,
                                child: Center(child: Text('VOLTAR PARA O AGENDAMENTO', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  addInvitee(userDetails){

    if (!selectedUsers.toString().contains(userDetails['id'])){
      setState(() {
      selectedUsers.add(userDetails);
      });
    }
    print("SELECTED USERS: " + selectedUsers.toString());
  }
  removeInvitee(userDetails){
    setState(() {
      print(userDetails.toString());
      selectedUsers.removeWhere((guest) => guest['id'] == userDetails['id']);
    });
  }


}
