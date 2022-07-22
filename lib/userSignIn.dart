import 'dart:async';

import 'package:SetItUp/cart.dart';
import 'package:SetItUp/globalVariables.dart';
import 'package:SetItUp/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:string_validator/string_validator.dart';
import 'userSignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';

class userSignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<userSignIn> {
  int email_flag = 0, password_flag = 0, user_found = 0;
  String email_msg = '', password_msg = '';
  String email = '', password = '', username = '', userid = '';
  final email_controller = TextEditingController();
  final password_controller = TextEditingController();

  List<String> ret_userids = [];
  List<String> ret_emails = [];
  List<String> ret_usernames = [];

  SetUser(userid, email, password, username, user_type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .setStringList('User', [userid, email, password, username, user_type]);
  }

  void signinUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      SetUser(userid, email, password, username, "user");

      Variables().setFIrebaseUser(userCredential.user);

      Variables().setUsertype("user");

      Variables().setUserId(userid);

      Fluttertoast.showToast(
          msg: "Logged In",
          textColor: Colors.white,
          backgroundColor: Colors.green);

      Variables().cartstatus != 1
          ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ))
          : Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Cart(),
              ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
            msg: 'No user found for that email.',
            textColor: Colors.white,
            backgroundColor: Colors.red);
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
            msg: 'Wrong password provided for that user.',
            textColor: Colors.white,
            backgroundColor: Colors.red);
      }
    }
  }

  // void checkData(DocumentSnapshot value) {
  //   //Fluttertoast.showToast(msg: value);
  //   if (value.data() == null) {
  //     //Fluttertoast.showToast(msg: value+'2');

  //     setState(() {
  //       email_flag = 1;
  //       email_msg = 'No User found for this email';
  //       // print('test');
  //     });
  //   } else {
  //     setState(() {
  //       username = value.data()['Username'].toString();
  //     });
  //   }
  // }

  // void RetrieveUser() {
  //   String path = 'users/' + email;
  //   FirebaseFirestore.instance.doc(path).get().then((value) => {
  //         //String uname = value.data()['Usename']
  //         checkData(value),
  //         //Fluttertoast.showToast(msg: value.data().toString()+'1')
  //       });
  // }

  RetrieveUser() async {
    // List<String> ret_userids = [];
    // List<String> ret_emails = [];
    // List<String> ret_usernames = [];
    // FirebaseFirestore.instance
    //     .collection('users')
    //     .get()
    //     .then((querySnapshot) => {
    //           querySnapshot.docs.forEach((document) {
    //             String userid = document.id.toString();
    //             String ret_email = document.data()['Email'].toString();
    //             String ret_usern = document.data()['Username'].toString();
    //             ret_emails.add(ret_email);
    //             ret_usernames.add(ret_usern);
    //             ret_userids.add(userid);
    //             print(ret_emails);
    //             print(ret_usernames);
    //             print(ret_userids);
    //           }),
    //           checkUser(ret_emails, ret_usernames, ret_userids)
    //         })
    //     .catchError(
    //         (error) => print('Error occured while retrieving user $error'));

    try {
      ret_userids = [];
      ret_emails = [];
      ret_usernames = [];
      QuerySnapshot data =
          await FirebaseFirestore.instance.collection('users').get();
      data.docs.forEach((document) {
        String userid = document.id.toString();
        String ret_email = document.data()['Email'].toString();
        String ret_usern = document.data()['Username'].toString();
        ret_emails.add(ret_email);
        ret_usernames.add(ret_usern);
        ret_userids.add(userid);
      });

      await checkUser();
    } catch (error) {
      print("Error occured while retrieving user DATA" + error.toString());
    }
  }

  // checkUserInfo() async {
  //   checkUser(ret_emails, ret_usernames, ret_userids);
  // }

  checkUser() async {
    for (int i = 0; i < ret_emails.length; i++) {
      print("HELLO");
      if (email == ret_emails[i]) {
        setState(() {
          user_found = 1;
          username = ret_usernames[i];
          userid = ret_userids[i];
        });
        break;
      }
    }
    if (user_found == 0) {
      setState(() {
        email_flag = 1;
        email_msg = 'No User found for this email';
        // print('test');
      });
    }
  }

  void Validator() {
    if (email == '') {
      setState(() {
        email_flag = 1;
        email_msg = 'Field Required';
      });
    } else if (!(RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email))) {
      setState(() {
        email_flag = 1;
        email_msg = 'Invalid Email';
      });
    } else {
      email_flag = 0;
    }

    if (password == '') {
      setState(() {
        password_flag = 1;
        password_msg = 'Field Required';
      });
    } else if (!(RegExp(
            "^(?=.{8,32}\$)(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?:{}|<>]).*")
        .hasMatch(password))) {
      setState(() {
        password_flag = 1;
        password_msg = 'Invalid Password';
      });
    } else {
      password_flag = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.11,
          ),
          Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "assets/images/setitup_final.png",
                fit: BoxFit.contain,
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "Welcome Back!",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: MediaQuery.of(context).size.width * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(6, 13, 217, 1)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Username",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Color.fromRGBO(6, 13, 217, 1)),
                ),
                TextField(
                  controller: email_controller,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color.fromRGBO(6, 13, 217, 1)),
                          borderRadius: BorderRadius.circular(50)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color.fromRGBO(6, 13, 217, 1)),
                          borderRadius: BorderRadius.circular(50))),
                ),
                email_flag == 0
                    ? SizedBox(height: 0)
                    : Container(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.01),
                        child: Text('*' + email_msg,
                            style: TextStyle(color: Colors.red))),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.035,
                ),
                Text(
                  "Password",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Color.fromRGBO(6, 13, 217, 1)),
                ),
                TextField(
                  controller: password_controller,
                  obscureText: true,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color.fromRGBO(6, 13, 217, 1)),
                          borderRadius: BorderRadius.circular(50)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color.fromRGBO(6, 13, 217, 1)),
                          borderRadius: BorderRadius.circular(50))),
                ),
                password_flag == 0
                    ? SizedBox(height: 0)
                    : Container(
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.width * 0.01),
                        child: Text('*' + password_msg,
                            style: TextStyle(color: Colors.red))),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
              ],
            ),
          ),
          ButtonTheme(
            height: MediaQuery.of(context).size.height * 0.05,
            minWidth: MediaQuery.of(context).size.width * 0.25,
            buttonColor: Color.fromRGBO(6, 13, 217, 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: RaisedButton(
              onPressed: () async {
                setState(() {
                  email = email_controller.text;
                  password = password_controller.text;
                });

                Validator();
                await RetrieveUser();

                if (email_flag == 0 && password_flag == 0) {
                  signinUser(email, password);
                }
              },
              child: Text(
                "Sign In",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.045),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Not a User?",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      color: Color.fromRGBO(6, 13, 217, 1)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUp(),
                        ));
                  },
                  child: Text(" SignUp",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          color: Color.fromRGBO(6, 13, 217, 1))),
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
