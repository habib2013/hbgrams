import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hbgrams/pages/CreateAccountPage.dart';
import 'package:hbgrams/pages/NotificationsPage.dart';
import 'package:hbgrams/pages/ProfilePage.dart';
import 'package:hbgrams/pages/SearchPage.dart';
import 'package:hbgrams/pages/TimeLinePage.dart';
import 'package:hbgrams/pages/UploadPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn gSignIn =  GoogleSignIn();
final usersReference = Firestore.instance.collection("users");

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;

  void initState(){
    super.initState();
    pageController = PageController();

    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSigninIn(gSignInAccount);
    },onError: (gError){
      print('error message' + gError);
    });


    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount) {
      controlSigninIn(gSignInAccount);
    }).catchError((gError) {
      print('error message' + gError);
    });

  }

  controlSigninIn(GoogleSignInAccount signInAccount) async{
    if (signInAccount != null)
    {
//      await saveUserInfoToFirestore();
      setState(() {
        isSignedIn = true;
      });
    }
    else{
      setState(() {
        isSignedIn = false;
      });
    }

  }

  void dispose(){
    pageController.dispose();
    super.dispose();

  }

//  saveUserInfoToFirestore() async{
//    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
//    DocumentSnapshot documentSnapShot = await usersReference.document(gCurrentUser.id).get();
//
//    if(!documentSnapShot.exists){
//      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
//    }
//  }

  loginUser(){
    gSignIn.signIn();
  }

  logoutUser(){
    gSignIn.signOut();
  }

  whenPageChanges(int pageIndex){
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }
  onTapChangePage(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut,);
  }

  Scaffold buildHomeScreen() {
//    return RaisedButton.icon(onPressed: logoutUser, icon: Icon(Icons.close), label: Text("Sign Out User"));
    return Scaffold(
      body: PageView(
        children: [
          TimeLinePage(),
          SearchPage(),
          UploadPage(),
          NotificationsPage(),
          ProfilePage()
        ],
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: whenPageChanges,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        backgroundColor: Theme.of(context).accentColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 37.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Theme.of(context).accentColor,Theme.of(context).primaryColor],
            )
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('HbGrams',style: TextStyle(fontSize: 82.0,color: Colors.white,fontFamily: "Signatra"),
            ),
            RaisedButton(
              child: Text("Login with Google"),
              onPressed: (){
                loginUser();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();

    } else {
      return buildSignInScreen();
    }
  }
}
