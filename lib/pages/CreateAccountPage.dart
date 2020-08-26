import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hbgrams/widgets/HeaderWidget.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
    final _scafoldkey = GlobalKey<ScaffoldState>();
    final _formkey = GlobalKey<FormState>();

  String username;
  submitUsername(){
  final form = _formkey.currentState;
  if (form.validate()) {
    form.save();

    SnackBar snackBar = SnackBar(content: Text("Welcome "+ username),);
    _scafoldkey.currentState.showSnackBar(snackBar);
    Timer(Duration(seconds: 4),(){
      Navigator.pop(context,username);
    });
  }
  }

  @override
  Widget build(BuildContext parentContext) {
   return Scaffold(
     key: _scafoldkey,
     appBar: header(context,strTitle: "Settings",disappearedBackButton: true),
     body: ListView(
       children: [
         Container(
           child: Column(
             children: [
               Padding(
                 padding: EdgeInsets.only(top: 26.0),
                 child: Center(
                   child: Text("Set Up a username",style: TextStyle(fontSize: 26.0),),

                 ),
               ),
               Padding(
                 padding: EdgeInsets.all(17.0),
                 child: Container(
                   child: Form(
                     key: _formkey,
                     autovalidate: true,
                     child: TextFormField(
                       style: TextStyle(color:Colors.white),
                       validator: (val){
                         if(val.trim().length < 5 || val.isEmpty){
                           return 'Usernam is too short';
                         }
                        else if(val.trim().length < 5 || val.isEmpty){
                           return 'Usernam is too short';
                         }
                        else{
                          return null;
                         }
                       },
                       onSaved: (val) => username = val,
                       decoration: InputDecoration(
                         enabledBorder: UnderlineInputBorder(
                           borderSide: BorderSide(color: Colors.grey)
                         ),
                         focusedBorder: UnderlineInputBorder(
                             borderSide: BorderSide(color: Colors.white),
                         ),
                         border: OutlineInputBorder(),
                         labelText: "Username",
                         labelStyle: TextStyle(
                           fontSize: 16.0
                         ),
                         hintText: 'Must be atleast 5 characters',
                         hintStyle: TextStyle(color: Colors.grey),
                       ),
                     ),
                   ),
                 ),
               ),
               RaisedButton(
                 child: Text('Create Username',style: TextStyle(color: Colors.white,backgroundColor: Colors.lightGreen,fontSize: 20.0),),
                 color: Colors.lightGreen,
                 elevation: 4.0,
                 onPressed: (){
                    submitUsername();
                 },

               ),
             ],
           ),
         )
       ],
     )
   );
  }
}
