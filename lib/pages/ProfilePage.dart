import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hbgrams/models/user.dart';
import 'package:hbgrams/pages/EditProfilePage.dart';
import 'package:hbgrams/pages/HomePage.dart';
import 'package:hbgrams/widgets/HeaderWidget.dart';
import 'package:hbgrams/widgets/PostTileWidget.dart';
import 'package:hbgrams/widgets/PostWidget.dart';
import 'package:hbgrams/widgets/ProgressWidget.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = 'grid';

  void initState() {
    getAllProfilePosts();
  }

  createProfileTopView() {
    return FutureBuilder(
      future: usersReference.document(widget.userProfileId).get(),
      builder: (context, dataSnapShot) {
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
                              createColumns("Followers", 3),
                              createColumns("Following", 76),
                              createColumns("Posts", 45),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              createButton(),
                            ],
                          )
                        ],
                      )),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 13.0),
                child: Text(
                  user.profileName,
                  style: TextStyle(fontSize: 14.0, color: Colors.white),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 13.0),
                child: Text(
                  user.bio,
                  style: TextStyle(fontSize: 14.0, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
          title: "Edit Profile", performFunction: editUserProfile);
    }
  }

  Container createButtonTitleAndFunction(
      {String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: 245.0,
          height: 26.0,
          child: Text(title,
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  editUserProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        strTitle: "Profile",
      ),
      body: ListView(
        children: [
          createProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(
            height: 0.0,
          ),
          displayProfilePost(),
        ],
      ),
    );
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(
                Icons.photo_library,
                color: Colors.grey,
                size: 200.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'No Posts',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      );
    }
    else if(postOrientation == 'grid')
    {
      List<GridTile> gridTilesList = [];
      postsList.forEach((eachPost) {
        gridTilesList.add(GridTile(child: PostTile(eachPost,)));
      });
      return GridView.count(crossAxisCount: 3,
      childAspectRatio: 1.0,
      mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    }
    else if(postOrientation == 'list')
    {
      return Column(
        children: postsList,
      );
    }

    return Column(
      children: postsList,
    );
  }

  void getAllProfilePosts() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postsReference
        .document(widget.userProfileId)
        .collection('usersPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents
          .map((documentSnapShot) => Post.fromDocument(documentSnapShot))
          .toList();
    });
  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            icon: Icon(
              Icons.grid_on,
              color: postOrientation == 'grid'
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            onPressed: () => setOrientation('grid')),
        IconButton(

            icon: Icon(
              Icons.list,
              color: postOrientation == 'list'
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            onPressed: setOrientation('list')),
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}
