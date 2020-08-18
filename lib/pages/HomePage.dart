import 'package:hbgrams/pages/NotificationsPage.dart';
import 'package:hbgrams/pages/ProfilePage.dart';
import 'package:hbgrams/pages/SearchPage.dart';
import 'package:hbgrams/pages/TimeLinePage.dart';
import 'package:hbgrams/pages/UploadPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hbgrams/pages/splash.dart';
import 'package:hbgrams/utils/firebase_auth.dart';

final GoogleSignIn gSignIn =  GoogleSignIn();

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
  }


  loginUser() async{
    bool res = await AuthProvider().loginWithGoogle();
    if(!res)
      print("error logging in with google");
  }


  void dispose(){
    pageController.dispose();
    super.dispose();

  }

//  loginUser(){
//    gSignIn.signIn();
//  }
//
//  logoutUser(){
//    gSignIn.signOut();
//  }

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
              onPressed: () async {
                bool res = await AuthProvider().loginWithGoogle();
                if(!res)
                  print("error logging in with google");
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context,AsyncSnapshot<FirebaseUser> snapshot) {
//        if(snapshot.connectionState == ConnectionState.waiting)
//          return SplashPage();
        if(!snapshot.hasData || snapshot.data == null)
          return buildSignInScreen();
        return buildHomeScreen();
      },
    );
  }
}
