import 'dart:async';
import 'dart:core' as prefix0;
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class User with ChangeNotifier {
  FirebaseUser _user;
  FirebaseAuth _auth;
  Status _status = Status.Uninitialized;
  String _userID;
  String _userPosition;
  String messagingToken;
  List<List<String>> _mySchedule = [[],[], []];
  List<String> _activeChats;
  Map<String, dynamic> _userInfo;

  String userName;
  Status get status => _status;
  FirebaseUser get user => _user;
  List<List<String>> get mySchedule => _mySchedule;
  List<String> get activeChats => _activeChats;
  String get id => _userID;
  String get position => _userPosition;
  Map<String, dynamic> get userInfo => _userInfo;
  List<String> places = [];

  User.instance() : _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    print("user.dart: AUTH STATE CHANGED - REFETCHING ALL THE DATA OF THIS USER RIGHT NOW");
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _status = Status.Authenticating;
      notifyListeners();
      _user = firebaseUser;
      _userID = _user.uid;
      getTokenFCM();
      _status = Status.Authenticated;
      getCurrentUserInfo();

      await Firestore.instance.collection('general').document('eventLocations').get().then((doc) => places = List<String>.from(doc.data['places']));
      print("PLACES :" + places.toString());
      notifyListeners();
    }
    notifyListeners();
  }

  getTokenFCM() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String tokenFcm = await _firebaseMessaging.getToken();
    messagingToken = tokenFcm;
    await Firestore.instance.collection('users').document(_user.uid).updateData({ 'messagingToken' : tokenFcm.toString() }); 
    print('user.dart: token FCM:' + tokenFcm);
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    print("user.dart: SIGNIN IN");
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = Status.Authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<String> createUserWithEmailAndPassword(String email, String password, String name, String company, String position, String segment, String image, List<String> tags, String description, bool exhibitor) async {
    print("user.dart: CREATING USER");
    await _auth.createUserWithEmailAndPassword(email: email, password: password).then((newuser) {
      Firestore.instance.collection('users').document(newuser.uid).setData({
        'email': email,
        'name': name,
        'company': company,
        'position': position,
        'segment': segment,
        'picture': image,
        'tags': tags,
        'about': description,
        'exhibitor': exhibitor,
        'messagingToken': '',
      });
    });
    return user.uid;
  }

  Future<void> signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  getCurrentUserInfo() async {
    print("user.dart: GETTING CURRENT USER INFO");
    if (_status == Status.Authenticated) {
      await Firestore.instance.collection('users').document(_user.uid).get().then((userDoc){
        userName = userDoc['name'];
        _userInfo = {
          'id' : userDoc.documentID,
          'userName' : userDoc['name'],
          'userTitle' :userDoc['position'] + ' em ',
          'userCompany' : userDoc['company'], 
          'tags' : List<String>.from(userDoc['tags']),
          'imageUrl' : userDoc['picture'],
          'about' : userDoc['about'],
          'exhibitor': userDoc['exhibitor'] == null ? false : userDoc['exhibitor']
        };
      });
    print("user.dart: GOT CURRENT USER INFO, $userName");
    return _userInfo;
    }
    else return {'error': 'user not authenticated'};
  }

  getOtherUserInfo(String otherUserId) async {
    print("user.dart: --- GETTING THE OTHER USER INFO");
      var userDoc = await Firestore.instance.collection('users').document(otherUserId).get();
      String otherUserImageUrl = userDoc['picture'];
      String otherUserName = userDoc['name'];
      String otherUserTitle = userDoc['position'];
      String otherUserCompany = userDoc['company'];
      List<String> tags = List<String>.from(userDoc['tags']); 

      Map _otherUserInfo = {
        'userName' : otherUserName,
        'userTitle' : otherUserTitle + ' em ',
        'userCompany' : otherUserCompany, 
        'tags' : tags,
        'imageUrl' : otherUserImageUrl,
        'about' : userDoc['about']
      };
    print("user.dart: --- GOT OTHER USER INFO");
    print(_otherUserInfo.toString());
    return _otherUserInfo;
  }

  editCurrentUserDescription(String description) async {
    print("user.dart: Updating user description");
    await Firestore.instance.collection('users').document(_user.uid).updateData( {'about' : description});
  }

  updateTags(List<String> tags) async {
    print("user.dart: Updating tags:" + tags.toString());
    await Firestore.instance.collection('users').document(_user.uid).updateData( {'tags' : FieldValue.arrayUnion(tags)}); 
  }
  
  removeTag(String tag) async {
    print("user.dart: Removing tags:" + tag.toString());
    await Firestore.instance.collection('users').document(_user.uid).updateData( {'tags' : FieldValue.arrayRemove([tag])});
    notifyListeners();
  }
  
/*   Future<void> pushUser(Map<String, dynamic> object) async{
    print("user.dart: PUSHING USERS TO DB");
    FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: object['email'], password: object['password']);
    await Firestore.instance.collection('users').document(user.uid).setData(object);
  }  */
  // Future<void> pushCompany(Map<String, dynamic> object) async{
  //   print("user.dart: PUSHING COMPANIES TO DB");
  //   await Firestore.instance.collection('companies').document().setData(object);
  // }

  // Future<void> pushMyUser(Map<String, dynamic> object) async{
  //   print("user.dart: PUSHING THIS USER TO DB");
  //  // FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: object['email'], password: '123456');
  //   await Firestore.instance.collection('users').document(_user.uid).setData(object);
  // } 
}