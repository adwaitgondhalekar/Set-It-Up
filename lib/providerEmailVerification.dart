import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'globalVariables.dart';
import './addservice.dart';

import './addservice.dart';

class ProviderEmailVerification extends StatelessWidget {
  final String provider_id;
  final String email;
  final String username;
  final String password;

  ProviderEmailVerification(this.provider_id,this.email, this.username, this.password);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: providerProgressPage(provider_id,email, username, password),
    );
  }
}

class providerProgressPage extends StatefulWidget {
  final String provider_id;
  final String email;
  final String username;
  final String password;

  providerProgressPage(this.provider_id,this.email, this.username, this.password);
  @override
  _providerProgressPageState createState() =>
      _providerProgressPageState(provider_id,email, username, password);
}

class _providerProgressPageState extends State<providerProgressPage> {
  final String provider_id;
  final String email;
  final String username;
  final String password;
  String usern;

  _providerProgressPageState(this.provider_id,this.email, this.username, this.password);
  bool isEmailVerified = false;
  Timer timer;

  void setData(String uname) {
    setState(() {
      usern = uname;
      //Fluttertoast.showToast(msg: username);
    });

    //Fluttertoast.showToast(msg: username);
  }

  

  void RetrieveUser() {
    String path = 'service_provider/' + provider_id;
    FirebaseFirestore.instance.doc(path).get().then((value) => {
          //String uname = value.data()['Usename']
          //Fluttertoast.showToast(msg: value.data()['Username'].toString()),

          setData(value.data()['Username'].toString())
        });
  }

  void checkStatus() async {
    User user = FirebaseAuth.instance.currentUser;
    await user.reload();

    //Variables().setFIrebaseUser(user);

    setState(() {
      isEmailVerified = user.emailVerified;
    });
  }

 Future<void> addServiceProvider() {

    String path = 'service_provider/'+provider_id;
    FirebaseFirestore.instance
        .doc(path)
        .set({'Email': email, 'Username': username, 'Password': password})
        .then((value) => print("Provider Added"))
        .catchError((error) => {
              print("Failed to add provider: $error"),
            });
    ;
    // Call the user's CollectionReference to add a new user
    // return users
    //     .set({'Email': email, 'Username': username, 'Password': password})
    //     .then((value) => print("User Added"))
    //     .catchError((error) => {
    //           print("Failed to add user: $error"),
    //         });
  }

  @override
  void initState() {

    super.initState();

    timer = Timer.periodic(Duration(seconds: 4), (timer) {
      checkStatus();

      if (isEmailVerified == true) {
        addServiceProvider();
        RetrieveUser();
        timer.cancel();
      }
    });
  }

  @override
  void dipose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: isEmailVerified != true
            ? <Widget>[
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(6, 13, 217, 1)),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Text("Verify email to proceed")
              ]
            : <Widget>[
                Center(
                    child: Icon(
                  Icons.check,
                  color: Color.fromRGBO(6, 13, 217, 1),
                  size: MediaQuery.of(context).size.width * 0.20,
                )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Text("Email verified Successfully!"),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                ButtonTheme(
                  buttonColor: Color.fromRGBO(6, 13, 217, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: RaisedButton(
                    child: Text(
                      "Add Service",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Timer(Duration(seconds: 3), (){
                         Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => AddService(email,usern)));
                      });
                     
                    },
                  ),
                )
              ],
      ),
    );
  }
}
