import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hbgrams/models/user.dart';
import 'package:hbgrams/pages/HomePage.dart';
import 'package:hbgrams/widgets/CImageWidget.dart';
import 'package:hbgrams/widgets/ProgressWidget.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;

  Post({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot['postId'],
      ownerId: documentSnapshot['ownerId'],
      likes: documentSnapshot['likes'],
      username: documentSnapshot['username'],
      description: documentSnapshot['description'],
      location: documentSnapshot['location'],
      url: documentSnapshot['url'],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }
    int counter = 0;
    likes.values.foreach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });

    return counter;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        likes: this.likes,
        username: this.username,
        description: this.description,
        location: this.location,
        url: this.url,
        likeCount: getTotalNumberOfLikes(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;

  _PostState(
      {this.postId,
      this.ownerId,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url,
      this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
        future: usersReference.document(ownerId).get(),
        builder: (context, dataSnapShot) {
          if (!dataSnapShot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapShot.data);
          bool isPostOwner = currentOnlineUserId == ownerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.url),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => print('show profile'),
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              location,
              style: TextStyle(color: Colors.white),
            ),
            trailing: isPostOwner
                ? IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    onPressed: () => print('Deleted'))
                : Text(""),
          );
        });
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => print('Post Liked'),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(url),
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => print('Liked Post'),
              child: Icon(
                Icons.favorite,color: Colors.grey,
//                isLiked ? Icons.favorite : Icons.favorite_border,
//                size: 28.0,
//                color: Colors.pink,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => print('Show Comments'),
              child: Icon(
              Icons.chat_bubble_outline,
              size: 28.0,
              color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 20.0
              ),
              child: Text(
                "$likeCount likes",
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
               "$username " ,
                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Text(description,style: TextStyle(color: Colors.white),)),
          ],
        ),
      ],
    );
  }
}
