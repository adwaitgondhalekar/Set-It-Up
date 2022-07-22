import 'dart:async';

//import './providerEmailVerification.dart';
import 'package:SetItUp/providerEmailVerification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:string_validator/string_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'globalVariables.dart';
import 'package:uuid/uuid.dart';

class ProviderSignUp extends StatefulWidget {
  @override
  _ProviderSignUpState createState() => _ProviderSignUpState();
}

class _ProviderSignUpState extends State<ProviderSignUp> {
  var uuid = Uuid();
  User user;
  int email_flag = 0, username_flag = 0, password_flag = 0;
  String email_msg = '', username_msg = '', password_msg = '';
  int register_flag = 0;
  String email = '', username = '', password = '';
  final email_controller = TextEditingController();
  final username_controller = TextEditingController();
  final password_controller = TextEditingController();

  FirebaseAuth providerauth = FirebaseAuth.instance;
  String provider_id;

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

    if (username == '') {
      setState(() {
        username_flag = 1;
        username_msg = 'Field Required';
      });
    } else if (!(RegExp(r'^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$')
        .hasMatch(username))) {
      setState(() {
        username_flag = 1;
        username_msg = 'Invalid Username';
      });
    } else {
      setState(() {
        username_flag = 0;
        //Fluttertoast.showToast(msg: username);
      });
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
        password_msg = 'Password is too weak!';
      });
    } else {
      password_flag = 0;
    }
  }

  createUser() async {
    try {
      UserCredential userCredential = await providerauth
          .createUserWithEmailAndPassword(email: email, password: password);

      //user = userCredential.user;

      Variables().setProvider(userCredential.user);

      Variables().setProviderAuth(providerauth);

      Fluttertoast.showToast(
          msg: "Sign Up Succesful!",
          textColor: Colors.white,
          backgroundColor: Colors.green);

      await Variables().provider.sendEmailVerification();
      provider_id = uuid.v4();

      await Fluttertoast.showToast(
          msg: "Verification link has been sent to your email");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: 'The account already exists for that email.');
      }
    } catch (e) {
      print(e);
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
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/images/setitup_final.png",
                  fit: BoxFit.contain,
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "Create Provider Account",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(6, 13, 217, 1)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Email",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: Color.fromRGBO(6, 13, 217, 1)),
                  ),
                  TextField(
                    controller: email_controller,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(6, 13, 217, 1)),
                            borderRadius: BorderRadius.circular(50)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(6, 13, 217, 1)),
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
                    "Username",
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: Color.fromRGBO(6, 13, 217, 1)),
                  ),
                  TextField(
                    controller: username_controller,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(6, 13, 217, 1)),
                            borderRadius: BorderRadius.circular(50)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(6, 13, 217, 1)),
                            borderRadius: BorderRadius.circular(50))),
                  ),
                  username_flag == 0
                      ? SizedBox(height: 0)
                      : Container(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.01),
                          child: Text('*' + username_msg,
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
                            borderSide: BorderSide(
                                color: Color.fromRGBO(6, 13, 217, 1)),
                            borderRadius: BorderRadius.circular(50)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromRGBO(6, 13, 217, 1)),
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
                  )
                ],
              ),
            ),
            ButtonTheme(
              height: MediaQuery.of(context).size.height * 0.05,
              minWidth: MediaQuery.of(context).size.width * 0.25,
              buttonColor: Color.fromRGBO(6, 13, 217, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: RaisedButton(
                onPressed: () async {
                  setState(() {
                    email = email_controller.text;
                    username = username_controller.text;
                    password = password_controller.text;
                  });
                  Validator();
                  if (email_flag == 0 &&
                      username_flag == 0 &&
                      password_flag == 0) {
                    await createUser();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProviderEmailVerification(
                                provider_id, email, username, password)));
                    //sendEmail();

                    // if (Variables().firebaseuser!=null) {
                    //   //print("inside if");
                    //   Timer(Duration(seconds: 10), () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) =>
                    //                 emailVerificationProgress()));
                    //   });
                    // }
                  }
                },
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
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
            //         "Already a User?",
            //         style: TextStyle(
            //             fontFamily: "Poppins",
            //             fontSize: MediaQuery.of(context).size.width * 0.035,
            //             color: Color.fromRGBO(6, 13, 217, 1)),
            //       ),
            //       GestureDetector(
            //         onTap: () {
            //           Navigator.pop(context);
            //         },
            //         child: Text(" SignIn",
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
      ),
    );
  }
}
