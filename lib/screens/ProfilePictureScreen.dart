import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iris_flutter/services/normalize.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';


class ProfilePictureScreen extends StatefulWidget {
  ProfilePictureScreen(this.id, this.image);
  String image;
  String id;
  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  File _image;
  bool uploading = false;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1080);
    setState(() {
      _image = image;
      uploading = true;
    });
    uploadPic(context);
  }

  Future uploadPic(BuildContext context) async{
    if (_image==null){
      widget.image = '';
    } else {
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('userPics').child(widget.id + DateTime.now().toIso8601String());
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
      var downUrl = await taskSnapshot.ref.getDownloadURL();
      Firestore.instance.collection('users').document(widget.id).updateData({'picture' : downUrl});
      setState(() {
        widget.image = downUrl;
        uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Container(
            child: !uploading?
            PhotoView(
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained*3,
              imageProvider: CachedNetworkImageProvider(widget.image),
            )
            : Center(child: CircularProgressIndicator())
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    BackButton(color: Theme.of(context).primaryColor,),
                    IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).primaryColor,),
                    onPressed: () => getImage(),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


class UneditableProfilePictureScreen extends StatefulWidget {
  UneditableProfilePictureScreen(this.image);
  final String image;
  @override
  _UneditableProfilePictureScreenState createState() => _UneditableProfilePictureScreenState();
}

class _UneditableProfilePictureScreenState extends State<UneditableProfilePictureScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Container(
            child: PhotoView(
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained*3,
              imageProvider: CachedNetworkImageProvider(widget.image),
            )
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    BackButton(color: Theme.of(context).primaryColor,),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}