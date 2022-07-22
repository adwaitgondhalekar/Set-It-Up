import 'dart:async';
import 'package:SetItUp/cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'globalVariables.dart';
import 'homescreen.dart';

class UserEmailVerification extends StatelessWidget {
  final String user_id;
  final String email;
  final String username;
  final String password;

  UserEmailVerification(this.user_id, this.email, this.username, this.password);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: userProgressPage(user_id, email, username, password),
    );
  }
}

class userProgressPage extends StatefulWidget {
  final String user_id;
  final String email;
  final String username;
  final String password;

  userProgressPage(this.user_id, this.email, this.username, this.password);
  @override
  _userProgressPageState createState() =>
      _userProgressPageState(user_id, email, username, password);
}

class _userProgressPageState extends State<userProgressPage> {
  final String user_id;
  final String email;
  final String username;
  final String password;

  _userProgressPageState(
      this.user_id, this.email, this.username, this.password);
  bool isEmailVerified = false;
  Timer timer;

  void checkStatus() async {
    User user = FirebaseAuth.instance.currentUser;
    await user.reload();

    Variables().setFIrebaseUser(user);


    setState(() {
      isEmailVerified = user.emailVerified;
    });
  }

  Future<void> addUser() {
    String path = 'users/' + user_id;
    FirebaseFirestore.instance
        .doc(path)
        .set({'Email': email, 'Username': username, 'Password': password})
        .then((value) => print("User Added"))
        .catchError((error) => {
              print("Failed to add user: $error"),
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
  // void updateCart()
  // {

  // }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 4), (timer) {
      checkStatus();

      if (isEmailVerified == true) {
        
        addUser();
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
                Variables().cartstatus!=1?
                ButtonTheme(
                  buttonColor: Color.fromRGBO(6, 13, 217, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: ElevatedButton(
                    child: Text(
                      "Proceed to Home Screen",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomeScreen()));
                    },
                  ),
                ):ButtonTheme(
                  buttonColor: Color.fromRGBO(6, 13, 217, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: ElevatedButton(
                    child: Text(
                      "Proceed to Cart",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => Cart()));
                    },
                  ),
                )

              ],
      ),
    );
  }
}
