// import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:iris_flutter/components/searchAndSelectUser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/services/MySchedule.dart';
// import 'package:iris_flutter/services/search.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';

// import 'SearchScreen.dart';

class CreateMeetingScreen extends StatefulWidget {
  CreateMeetingScreen(this.mainGuestID, this.mainGuestName);
  final String mainGuestID;
  final String mainGuestName;
  _CreateMeetingScreenState createState() => _CreateMeetingScreenState(mainGuestID, mainGuestName);
}


class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  _CreateMeetingScreenState(this.mainGuestID, this.mainGuestName);
  final _formKey = GlobalKey<FormState>();
  String mainGuestID;
  String mainGuestName;
  String location;
  String selectedDay;
  String selectedStartTime;
  String selectedEndTime;
  String selectedStartHour;
  String selectedStartMinute;
  int meetingDuration = 15;
  Map<String, String> dayOptions = {'2019-07-31' : '31 de Julho - Quarta-Feira', 
  '2019-08-01': '1º de Agosto - Quinta-Feira', 
  '2019-08-02' : '2 de Agosto - Sexta-Feira'};
  
  List<String> dropdownOptions = [""];

  List<String> startHour = ['07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20'];
  List<String> startMinute = ['00', '15', '30','45'];

  List<Map<String, String>> selectedUsers = [];
  List<Widget> usersToShow = [];

  @override
  void initState() { 
    super.initState();
    selectedUsers.add({'id': mainGuestID, 'name': mainGuestName});
  }
  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var user = Provider.of<User>(context);
    dropdownOptions = user.places;
    }

  addUser(BuildContext context) async {
    var returned = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => SearchAndSelectUserWidget(selectedUsers)),
    );
    if (returned != null) selectedUsers = returned; 
  }

  createMeeting(context){
    var user = Provider.of<User>(context);

    String startTime = selectedStartHour + ":" + selectedStartMinute + ":00";
    DateTime startDateTime = DateTime.parse( selectedDay + ' ' + startTime );
    DateTime endDateTime = startDateTime.add(Duration(minutes: meetingDuration));
    String endTime = endDateTime.hour.toString().padLeft(2, '0') + ":" + endDateTime.minute.toString().padLeft(2, '0') + ":00";

    List<String> allNames = [user.userName];
    selectedUsers.forEach((obj) => allNames.add(obj['name']));

    if (_formKey.currentState.validate()) {
      
      Map<String,dynamic> meetingObject = {
        'startTime' : startTime,
        'startDate' : selectedDay,
        'endTime' : endTime,
        'location' : location,
        'hostId' : user.id,
        'hostName': user.userName,
        'names' : allNames,
        'confirmed': false,
      };

      Map<String,dynamic> meetingInfo = {
        'startTime' : startTime,
        'startDate' : selectedDay,
        'endTime' : endTime,
        'location' : location,
        'hostId' : user.id,
        'hostName': user.userName,
        'names' : allNames,
        'confirmed': false,
        'type': 'invitation'
      };

      List<Map<String,dynamic>> meetingInfos = [meetingObject, meetingInfo]; 

      var mySchedule = Provider.of<MySchedule>(context);
      mySchedule.addMeeting(context, meetingInfos, selectedUsers, user.userName);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    usersToShow = [];
    selectedUsers.forEach((guest) => usersToShow.add( 
      Text(selectedUsers.indexOf(guest) != selectedUsers.length-1 ? guest['name'].split(' ')[0] + ", " : guest['name'].split(' ')[0] + (selectedUsers.length<2 ? '' : '.'),
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)),)
    ));

  print('--- CREATE MEETING SCREEN - ID 1: ' + mainGuestID);
    return Container(
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
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
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/sideLines2.png'),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Form(
                        key: _formKey,
                        child: DropdownButtonHideUnderline(
                          child: Column(
                            children: <Widget>[

/*                               Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: Text("Reunião com " + mainGuestName, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Theme.of(context).primaryColor),),
                              ),
 */
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: Text("Selecione o horário da reunião", style: TextStyle(fontSize: 17.3, fontWeight: FontWeight.w800),),
                              ),

                              Container(
                                width: (300/360)*MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).secondaryHeaderColor, width: 1.1)
                                ),
                                child: DropdownButton<String>(
                                  style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11
                                  ),
                                  icon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(FontAwesomeIcons.chevronDown, size: 12, color: Theme.of(context).secondaryHeaderColor),
                                  ),
                                  value: selectedDay,
                                  hint: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text("Dia da reunião".toUpperCase(), style: TextStyle(color: Theme.of(context).secondaryHeaderColor )),
                                  ),
                                  onChanged: (String newValue) => setState(() {
                                    selectedDay = newValue;
                                  }),    
                                  items: dayOptions.keys
                                    .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Text(dayOptions[value].toUpperCase(), style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
                                        ),
                                      );
                                    })
                                    .toList(),
                                ),
                              ),

                              SizedBox(height: 15),
                              
                              Container(
                                width: (300/360)*MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: (145/360)*MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Theme.of(context).secondaryHeaderColor, width: 1.1)
                                      ),
                                      child: DropdownButton<String>( 
                                        style: TextStyle(
                                          color: Theme.of(context).secondaryHeaderColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11
                                        ),
                                        icon: Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Icon(FontAwesomeIcons.chevronDown, size: 12, color: Theme.of(context).secondaryHeaderColor),
                                        ),
                                        value: selectedStartHour,
                                        hint: Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Text("Hora".toUpperCase(), style: TextStyle(color: Theme.of(context).secondaryHeaderColor )),
                                        ),
                                        onChanged: (String newValue) => setState(() {
                                          selectedStartHour = newValue;
                                        }),    
                                        items: startHour
                                          .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text(value.toUpperCase(), style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
                                              ),
                                            );
                                          })
                                          .toList(),
                                      ),
                                    ),
                                    Text(":"),
                                    Container(
                                      width: (145/360)*MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Theme.of(context).secondaryHeaderColor, width: 1.1)
                                      ),
                                      child: DropdownButton<String>( 
                                        style: TextStyle(
                                          color: Theme.of(context).secondaryHeaderColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11
                                        ),
                                        icon: Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Icon(FontAwesomeIcons.chevronDown, size: 12, color: Theme.of(context).secondaryHeaderColor),
                                        ),
                                        value: selectedStartMinute,
                                        hint: Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Text("Minutos".toUpperCase(), style: TextStyle(color: Theme.of(context).secondaryHeaderColor )),
                                        ),
                                        onChanged: (String newValue) => setState(() {
                                          selectedStartMinute = newValue;
                                        }),    
                                        items: startMinute
                                          .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text(value.toUpperCase(), style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
                                              ),
                                            );
                                          })
                                          .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 15,),

                              Container(
                                width: (300/360)*MediaQuery.of(context).size.width, //ARRUMAR
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).secondaryHeaderColor, width: 1.1)
                                ),
                                child: DropdownButton<String>( 
                                  style: TextStyle(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11
                                  ),
                                  icon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(FontAwesomeIcons.chevronDown, size: 12, color: Theme.of(context).secondaryHeaderColor),
                                  ),
                                  value: location,
                                  hint: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text("Local da reunião".toUpperCase(), style: TextStyle(color: Theme.of(context).secondaryHeaderColor )),
                                  ),
                                  onChanged: (String newValue) => setState(() {
                                    location = newValue;
                                  }),    
                                  items: dropdownOptions
                                    .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Text(value.toUpperCase(), style: TextStyle(color: Theme.of(context).secondaryHeaderColor)),
                                        ),
                                      );
                                    })
                                    .toList(),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 34.0),
                                child: Text("Convidado(s)", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),),
                              ),

                              Divider(),

                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0, top: 12),
                                child: Container(
                                  width: MediaQuery.of(context).size.width-60,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 0,
                                    runSpacing: 0,
                                    children: usersToShow
                                  )      
                                ),
                              ),
                              FlatButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => addUser(context),
                                child: Container(
                                  height: 55,
                                  width: (296/360)*MediaQuery.of(context).size.width,
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
                                            child: Center(child: Text('ADICIONAR MAIS CONVIDADOS', style: TextStyle(fontWeight: FontWeight.w800, color:Theme.of(context).primaryColor, fontSize: 13.8))),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(width: 4,),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(width: 1, color: Theme.of(context).primaryColor)
                                            ),
                                            height: 50,
                                            width: (290/360)*MediaQuery.of(context).size.width,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),


                              SizedBox(height: 100,)

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
                                    
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: FlatButton(
                    onPressed: () => createMeeting(context),
                    child: Container(
                      width: (296/360)*MediaQuery.of(context).size.width,
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
                                width: (293/360)*MediaQuery.of(context).size.width,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(width: 4,),
                              Container(
                                height: 60  ,
                                width: (290/360)*MediaQuery.of(context).size.width,
                                color: Theme.of(context).primaryColor,
                                child: Center(child: Text('CONVIDAR PARA REUNIÃO', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
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
      )
    );
  }
}