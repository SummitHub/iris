import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iris_flutter/components/loadingSpinner.dart';
import 'package:iris_flutter/screens/HomeScreen.dart';
import 'package:iris_flutter/services/user.dart';
import 'package:provider/provider.dart';

enum FormType { login, register }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = new GlobalKey<FormState>();
  final signInPageController = PageController(initialPage: 0);
  FocusNode _accountFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  TextEditingController _accountController = TextEditingController();
  MaskedTextController _passwordController = MaskedTextController(mask: '000.000.000-00');
  ScrollController _accountScrollController = ScrollController();
  ScrollController _passwordScrollController = ScrollController();

  bool isLoading = false;


  @override
  void dispose() {
    _accountController.dispose();
    _accountFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _accountScrollController.dispose();
    _passwordScrollController.dispose();
    signInPageController.dispose();
    super.dispose();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    form.save();
    return form.validate();
  }

  

  void validateAndSubmit() async {
    var auth = Provider.of<User>(context);
    if (validateAndSave()){
      try {
        setState(() {
         isLoading = true; 
        });
        print("Loggin In. Account: <" + _accountController.text.trimRight() + ">, Password: <" + _passwordController.text.replaceAll('-', '').replaceAll('.', '').replaceAll(' ', '') + ">");
        bool loggedin = await auth.signInWithEmailAndPassword(_accountController.text.trimRight(), _passwordController.text.replaceAll('-', '').replaceAll('.', '').replaceAll(' ', ''));
        print("Logged? $loggedin");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomeScreen();
            } 
          ),
        );
      }
      catch(e) { 
        setState(() {
          isLoading = true; 
        });
        print("Error: $e"); 
      }
    }
  }
  
  @override
  void initState() {
    _accountFocusNode.addListener(((){
      if (_accountFocusNode.hasFocus) { 
        accountScrollDown();  
      }
    }));
    super.initState();
  }

  accountScrollDown() async {
    await Future.delayed(Duration(milliseconds: 300));
    _accountScrollController.animateTo(_accountScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }
  toPasswordPage() async {
    signInPageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease,);
    await Future.delayed(Duration(milliseconds: 300));
    _passwordScrollController.animateTo(_passwordScrollController.position.maxScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }


  @override
  Widget build(BuildContext context) {
    print('ACCTEXT: ' + _accountController.text);
    print('cpfTEXT: ' + _passwordController.text);
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
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
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/whitearrow.png'),
                          )
                        )
                      )
                    )
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: formKey,
              child: PageView(
                controller: signInPageController,
                children: <Widget>[
                  accountScreen(),
                  passwordScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  accountScreen(){
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            controller: _accountScrollController,
            child: Padding(
              padding: EdgeInsets.only(top: 10.0, left: 35, right: 35, bottom: 95),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text("Bem-vindo ao maior brainstorming do brasil".toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: Colors.white, fontSize: 36.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                      height: 65,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 2,
                            color: Color(0xFFE1EC49)
                          )
                        )
                      ),
                      child: TextFormField(
                        controller: _accountController,
                        focusNode: _accountFocusNode,
                        style: TextStyle(fontSize: 18, color: Color(0xFFE1EC49)),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: "E-mail",
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          icon: Icon(FontAwesomeIcons.ticketAlt, color: Color(0xFFE1EC49),)),
                        validator: (value) => value.isEmpty ? 'Insira um e-mail válido' : null,
                        onSaved: (value) => _accountController.text = value,
                      )
                    ),
                  ),
                  Text("Use o mesmo e-mail usado para adquirir o seu ingresso.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFFDBDBDB))),
                ],
              ),
            )
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
                onPressed: () => toPasswordPage(), 
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
                            child: Center(child: Text("CONTINUAR", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
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
    );
  }

  passwordScreen(){
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            controller: _passwordScrollController,
            child: Padding(
              padding: EdgeInsets.only(top: 25.0, left: 35, right: 35, bottom: 95),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text("Confirme o seu CPF".toUpperCase(), style: TextStyle(fontFamily: 'Druk', color: Colors.white, fontSize: 36.5, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                      height: 65,
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 2,
                            color: Color(0xFFE1EC49)
                          )
                        )
                      ),
                      child: TextFormField(
                        focusNode: _passwordFocusNode,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 18, color: Color(0xFFE1EC49)),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: "Insira o seu CPF",
                          labelStyle: TextStyle(color: Color(0xFFE1EC49)),
                          icon: Icon(FontAwesomeIcons.addressCard, color: Color(0xFFE1EC49),)),
                        validator: (value) => value.isEmpty ? 'Insira o CPF usado na compra da sua credencial' : null,
                      )
                    ),
                  ),
                  Text("O CPF solicita é o mesmo utilizado para a compra dos ingressos no Sympla.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFFDBDBDB))),
                ],
              ),
            )
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: isLoading 
              ? SizedBox(
                width: (296/360)*MediaQuery.of(context).size.width,
                height: 65,
                child: LoadingSpinner(true)
              )
              : FlatButton(
                onPressed: () {
                  if (signInPageController.page == 0) {
                    signInPageController.nextPage(curve: Curves.easeInOutSine, duration: Duration(milliseconds: 200));
                    formKey.currentState.save();
                  }
                  else if (signInPageController.page == 1) {
                    validateAndSubmit();
                  }
                  
                },
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
                            child: Center(child: Text("ENTRAR", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13.8))),
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
    );
  }
}