import 'package:SetItUp/adminSignin.dart';
import 'package:SetItUp/userSignIn.dart';
import 'package:flutter/material.dart';
import './userSignIn.dart';
import './providerSignIn.dart';
import './productDisplay.dart';

class SignInOptions extends StatefulWidget {
  @override
  _SignInOptionsState createState() => _SignInOptionsState();
}

class _SignInOptionsState extends State<SignInOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          child: ButtonTheme(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              minWidth: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.05,
              child: RaisedButton(
                color: Color.fromRGBO(6, 13, 217, 1),
                child: Text(
                  'Sign in as a User',
                  style: TextStyle(color: Colors.white,fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                 Navigator.push(
                    context, MaterialPageRoute(builder: (context) => userSignIn()));
                },
              )),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        ),
        Container(
          alignment: Alignment.center,
          child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.05,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: RaisedButton(
                color: Color.fromRGBO(6, 13, 217, 1),
                child: Text(
                  'Sign in as a Service Provider',
                  style: TextStyle(color: Colors.white,fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
                ),
                onPressed: () {

                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => ProviderSignIn()));
                },
              )),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        ),
        Container(
          alignment: Alignment.center,
          child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.05,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: RaisedButton(
                color: Color.fromRGBO(6, 13, 217, 1),
                child: Text(
                  'Sign in as an Administrator',
                  style: TextStyle(color: Colors.white,fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => adminSignIn ()));
                },
              )),
        ),
        
      ],
    ));
  }
}
