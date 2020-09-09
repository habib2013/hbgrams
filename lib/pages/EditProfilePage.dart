import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:hbgrams/models/user.dart';
import 'package:hbgrams/pages/HomePage.dart';
import 'package:hbgrams/widgets/ProgressWidget.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _profileIsValid = true;
  bool _bioIsValid = true;

  void initState() {
    super.initState();
    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot =
        await usersReference.document(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);

    profileTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  void logoutUser() async{
  await gSignIn.signOut();
  Navigator.push(context, MaterialPageRoute(builder: (context) =>HomePage()));
  }

  updateUserData() {
    setState(() {
      profileTextEditingController.text.trim().length < 3 ||
              profileTextEditingController.text.isEmpty
          ? _profileIsValid = false
          : _profileIsValid = true;

      bioTextEditingController.text.trim().length > 110
          ? _bioIsValid = false
          : _bioIsValid = true;
    });

    if (_bioIsValid && _profileIsValid) {
      usersReference.document(widget.currentOnlineUserId).updateData({
        "profileName": profileTextEditingController.text,
        "bio": bioTextEditingController.text,
      });
      SnackBar successSnackBar =
          SnackBar(content: Text("profile has been updated successsfully"));
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
              icon: Icon(
                Icons.done_outline,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () => Navigator.pop(context))
        ],
      ),
      body: loading
          ? circularProgress()
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 7.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.green,
                          backgroundImage: CachedNetworkImageProvider(user.url),
                          radius: 52.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            createProfileTextFormNameField(),
                            createBioTextFormNameField(),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 29.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                          onPressed: updateUserData,
                          child: Text(
                            '       Update      ',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(top: 29.0, left: 50.0, right: 50.0),
                        child: RaisedButton(
                          color: Colors.red,
                          onPressed: logoutUser,
                          child: Text(
                            'Logout',
                            style:
                            TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  createProfileTextFormNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            'Profile Name',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: profileTextEditingController,
          decoration: InputDecoration(
              hintText: 'write Profile Name here ...',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _profileIsValid ? null : 'Profile name is very short'),
        )
      ],
    );
  }

  createBioTextFormNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            'Bio',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: bioTextEditingController,
          decoration: InputDecoration(
              hintText: 'write Bio here ...',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              errorText: _bioIsValid ? null : 'Bio is too Long'),
        )
      ],
    );
  }


}
