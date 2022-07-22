import 'dart:async';

import 'package:SetItUp/globalVariables.dart';
import 'package:SetItUp/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:string_validator/string_validator.dart';
import 'userSignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';

FirebaseAuth admiauth = FirebaseAuth.instance;

class adminSignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<adminSignIn> {
  int email_flag = 0, password_flag = 0;
  String email_msg = '', password_msg = '';
  String email = '', password = '', username = '';
  final email_controller = TextEditingController();
  final password_controller = TextEditingController();

  checkAdmin() async {
    if (email != "admin@setitup.com") {
      setState(() {
        email_flag = 1;
        email_msg = 'Invalid Email';
      });
    }
  }

  SetUser(email, password, username, user_type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('User', [email, password, username, user_type]);
  }

  void signinUser(String email, String password) async {
    try {
      UserCredential userCredential = await admiauth.signInWithEmailAndPassword(
          email: email, password: password);

      SetUser(email, password, "Administrator", "admin");

      Variables().setFIrebaseUser(userCredential.user);

      Variables().setAdminAuth(admiauth);

      Variables().setUsertype("admin");

      Fluttertoast.showToast(
          msg: "Logged In",
          textColor: Colors.white,
          backgroundColor: Colors.green);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
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
                await checkAdmin();
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
          // Container(
          //   margin: EdgeInsets.symmetric(
          //       vertical: MediaQuery.of(context).size.height * 0.04),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       Text(
          //         "Not a User?",
          //         style: TextStyle(
          //             fontFamily: "Poppins",
          //             fontSize: MediaQuery.of(context).size.width * 0.035,
          //             color: Color.fromRGBO(6, 13, 217, 1)),
          //       ),
          //       GestureDetector(
          //         onTap: () {

          //           Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp(),));

          //         },
          //         child: Text(" SignUp",
          //             style: TextStyle(
          //                 fontFamily: "Poppins",
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: MediaQuery.of(context).size.width * 0.035,
          //                 color: Color.fromRGBO(6, 13, 217, 1))),
          //       )
          //     ],
          //   ),
          // ),
        ],
      ),
    ));
  }
}
