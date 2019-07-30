import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password, String name);
  Future<String> currentUser();
  Future<String> getDisplayName();
  Future<Map<String, dynamic>> getCurrentUserInfo();
  Future<void> signOut();
  Future<void> setDisplayName(String fullName);
  
  //Funçoes para preencher o banco
  Future<void> copyUserToDB();
  Future<void> pushUser(Map<String, dynamic> object);
  Future<void> pushCompany(Map<String, dynamic> object);
}

class Auth implements BaseAuth{

  @override
  Stream<String> get onAuthStateChanged {
    print("AUTH STATE CHANGED");
    return FirebaseAuth.instance.onAuthStateChanged.map((user)=> user?.uid);
  }

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    print("SIGNIN IN");
    FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password, String name) async {
    print("CREATING USER");
    FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    if (name.isNotEmpty) await setDisplayName(name);
    await Firestore.instance.collection('users').document(user.uid).setData({'email': email,'fullName': name});
    return user.uid;
  }

  Future<String> currentUser() async {
    print("GETTING CURRENT USER ID");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user?.uid;
  }

  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    print("GETTING CURRENT USER INFO");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    var userDoc = await Firestore.instance.collection('users').document(user.uid).get();
    String imageUrl = userDoc['picture'];
    String userName = userDoc['name'];
    String userTitle = userDoc['gender'];
    String userCompany = userDoc['company'];
    List<String> tags = List<String>.from(userDoc['tags']);
    return {
      'userName' : userName,
      'userTitle' : userTitle + ' em ',
      'userCompany' : userCompany, 
      'tags' : tags,
      'imageUrl' : imageUrl
    };
  }

  Future<String> getDisplayName() async {
    print("GETTING DISPLAY NAME");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user?.displayName;
  }

  Future<void> signOut() async {
    print("SIGNIN OUT");
    return FirebaseAuth.instance.signOut();
  }


  Future<void> setDisplayName(String fullName) async {
    print("GETTING USER NAME FROM AUTH");
    return FirebaseAuth.instance.currentUser().then((val){
      UserUpdateInfo updateUser = UserUpdateInfo();
      updateUser.displayName = fullName;
      val.updateProfile(updateUser);
    });
  }
  Future<void> copyUserToDB() async{
    print("GETTING USER FROM AUTH");
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await Firestore.instance.collection('users').document(user.uid).setData({'email': user.email,'fullName': user.displayName});
  }

  Future<void> pushUser(Map<String, dynamic> object) async{
    print("PUSHING USERS TO DB");
    FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: object['email'], password: '123456');
    await Firestore.instance.collection('users').document(user.uid).setData(object);
  } 
  
  Future<void> pushCompany(Map<String, dynamic> object) async{
    print("PUSHING COMPANIES TO DB");
    await Firestore.instance.collection('companies').document().setData(object);
  } 
}