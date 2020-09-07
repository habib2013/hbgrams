import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hbgrams/models/user.dart';
import 'package:hbgrams/pages/EditProfilePage.dart';
import 'package:hbgrams/pages/HomePage.dart';
import 'package:hbgrams/widgets/HeaderWidget.dart';
import 'package:hbgrams/widgets/ProgressWidget.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,strTitle: "Profile",),
      body: ListView(
        children: [
          createProfileTopView(),
        ],
      ),
    );
  }

  createProfileTopView() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context,dataSnapShot){
        if (!dataSnapShot.hasData) {
          circularProgress();
        }
        User user = User.fromDocument(dataSnapShot.data);
        return Padding(
          padding: EdgeInsets.all(17.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),

                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                         children: [
                           Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               createColumns("Followers",3),
                               createColumns("Following",76),
                               createColumns("Posts",45),
                             ],
                           ),
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               createButton(),
                             ],
                           )
                         ],
                      )
                  ),
                ],
              )
            ],
          ),
        );
      },

    );
  }

  Column createColumns(String title,int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count.toString(),style: TextStyle(fontSize: 20.0,color: Colors.white,fontWeight: FontWeight.bold),),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(title,style: TextStyle(fontSize: 16.0,color: Colors.grey,fontWeight: FontWeight.w400

          ),),
        )
      ],
    );

  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(title: "Edit Profile",performFunction: editUserProfile);
    }  
  }

  Container createButtonTitleAndFunction({String title,Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        child: Container(
          width: 245.0,
          height: 26.0,
          child: Text(title,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.black,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6.0),
          ),

        ),
      ),
    );
  }

  editUserProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentOnlineUserId:currentOnlineUserId)));
  }
}
