import 'dart:async';

import 'package:SetItUp/addservice.dart';
import 'package:SetItUp/globalVariables.dart';
import 'providerSignUp.dart';
import 'package:SetItUp/signInOptions.dart';
import 'productDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './events_model.dart';
import './data.dart';
import 'cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:SetItUp/userSignIn.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var uuid = Uuid();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String email = null,
      password = null,
      user_type = null,
      username = null,
      user_id = null;
  bool funcstatus = false;

  Future<List> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('User') ?? null;
  }

  // getUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getStringList('User') ?? null;
  // }

  @override
  void initState() {
    super.initState();

    if (Variables().session_ID == null) {
      String session_id = uuid.v1();
      Variables().setSessionId(session_id);
    }

    if (Variables().provider != null) {
      Variables().provider_auth.signOut();

      Variables().setProvider(null);
    }

    // if (Variables().firebaseuser == null) {
    //   getUser().then((value) => setUserData(value));
    // } else {
    //   getUser().then((value) => setUserData(value));
    // }
    if (Variables().firebaseuser == null) {
      getUserInfo();
    }
    if (Variables().firebaseuser != null) {
      if (Variables().firebaseuser.email == 'admin@setitup.com') {
        funcstatus = true;
        username = 'Administrator';
      } else {
        getUserInfo();
      }
    }
  }

  getUserInfo() async {
    List User_Info = await getUser();

    if (User_Info != null) {
      if (User_Info[3] != 'admin') {
        setState(() {
          email = User_Info[1];
          password = User_Info[2];
          username = User_Info[3];
          user_type = User_Info[4];
        });
      } else {
        email = User_Info[0];
        password = User_Info[1];
        username = User_Info[2];
        user_type = User_Info[3];
      }

      if (Variables().firebaseuser == null) {
        await signinuser(email, password);
      }

      setState(() {
        funcstatus = true;
      });
    } else {
      setState(() {
        funcstatus = true;
      });
    }
  }

  Future<void> signinuser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      Variables().setFIrebaseUser(userCredential.user);
      Variables().setUsertype(user_type);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  // void setUserData(List<String> data) {
  //   if (data != null) {
  //     setState(() {
  //       email = data[1];
  //       password = data[2];
  //       username = data[3];
  //       user_type = data[4];
  //       Fluttertoast.showToast(msg: username);
  //     });
  //   }
  //   //Fluttertoast.showToast(msg: email + password);

  //   if (email != null && password != null) {
  //     signinuser(email, password);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (funcstatus == false) {
      return Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Color.fromRGBO(6, 13, 217, 1)),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Color.fromRGBO(6, 13, 217, 1),
        drawer: new AppDrawer(username),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff060DD9),
          title: Text("Set It Up"),
          actions: Variables().user_type != "admin"
              ? <Widget>[
                  IconButton(
                    color: Colors.white,
                    onPressed: () {
                      // if (Variables().firebaseuser == null) {
                      //   Fluttertoast.showToast(
                      //       msg: "Dude Please sign in before proceeding to cart");

                      //   Timer(Duration(seconds: 2), () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => userSignIn()));
                      //   });
                      // } else
                      //   Navigator.push(context,
                      //       MaterialPageRoute(builder: (context) => Cart()));
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Cart()));
                    },
                    icon:
                        Icon(Icons.shopping_cart_rounded, color: Colors.white),
                  )
                ]
              : null,
        ),
        body: Column(
          children: <Widget>[
            Variables().user_type != "admin"
                ? Container(
                    alignment: Alignment.topRight,
                    padding: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.030,
                        top: MediaQuery.of(context).size.width * 0.032,
                        bottom: MediaQuery.of(context).size.width * 0.032),
                    child: Icon(
                      Icons.filter_list,
                      color: Colors.white,
                    ),
                  )
                : SizedBox(),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('services')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Something went wrong'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: Text("Loading"));
                      }

                      if (snapshot.data.size == 0) {
                        return Center(
                            child: Text(
                          "Currently no service is available !",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ));
                      }

                      // return new ListView(

                      //   children:
                      //       snapshot.data.docs.map((DocumentSnapshot document) {
                      //     return ServiceTile(

                      //         serviceImage: document.data()['Image'],
                      //         serviceName:document.data()['Title'],
                      //         providerName: document.data()['Description'],
                      //         defaultSlot: document.data()['Duration'],
                      //         price: document.data()['Price']);
                      //   }).toList(),
                      // );
                      //Fluttertoast.showToast(msg: Variables().firebaseuser.email);

                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot documentSnapshot =
                                snapshot.data.docs[index];
                            String Image = documentSnapshot['Image'];
                            String Title = documentSnapshot['Title'];
                            String Name = documentSnapshot['Name'];
                            String Duration = documentSnapshot['Duration'];
                            int Price = documentSnapshot['Price'];
                            String Email = documentSnapshot['Email'];
                            String Desc = documentSnapshot['Description'];
                            String serviceid = documentSnapshot.id.toString();

                            List UnAvailableSlot =
                                documentSnapshot['UnAvailableSlot'];
                            List BookedSlot = documentSnapshot['BookedSlot'];
                            List UnBookedSlot =
                                documentSnapshot['UnBookedSlot'];

                            return GestureDetector(
                                child: ServiceTile(
                                    serviceImage: Image,
                                    serviceName: Title,
                                    providerName: Name,
                                    defaultSlot: Duration,
                                    price: Price),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => productDetails(
                                            serviceid,
                                            Image,
                                            Title,
                                            Price,
                                            Desc,
                                            Duration,
                                            Name,
                                            Email,
                                            UnBookedSlot,
                                            BookedSlot,
                                            UnAvailableSlot,
                                            null))));

                            //else {
                            //   return GestureDetector(
                            //       child: ServiceTile(
                            //           serviceImage: Image,
                            //           serviceName: Title,
                            //           providerName: Name,
                            //           defaultSlot: Duration,
                            //           price: Price),
                            //       onTap: () => Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //               builder: (context) => productDetails(
                            //                   serviceid,
                            //                   Image,
                            //                   Title,
                            //                   Price,
                            //                   Desc,
                            //                   Duration,
                            //                   Name,
                            //                   Email,
                            //                   UnBookedSlot,
                            //                   BookedSlot,
                            //                   UnAvailableSlot,
                            //                   null))));
                            // }
                          });
                    }),
              ),
            )
          ],
        ),
      );
    }
  }
}

class ServiceTile extends StatelessWidget {
  final String serviceImage;
  final String serviceName;
  final String providerName;
  final String defaultSlot;
  //final String productDesc;
  final int price;
  ServiceTile({
    @required this.serviceImage,
    @required this.serviceName,
    @required this.providerName,
    @required this.defaultSlot,
    @required this.price,
    //@required this.productDesc
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 1),
          ),
          //margin: EdgeInsets.symmetric(vertical: 16),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.030),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  serviceImage,
                  height: MediaQuery.of(context).size.height *
                      MediaQuery.of(context).size.width *
                      0.00019,
                  width: MediaQuery.of(context).size.height *
                      MediaQuery.of(context).size.width *
                      0.00019,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      serviceName,
                      softWrap: true,
                      style: TextStyle(
                          color: Color.fromRGBO(6, 13, 217, 1),
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.005,
                    ),
                    Text(
                      providerName,
                      softWrap: true,
                      style: TextStyle(
                          color: Color.fromRGBO(6, 168, 217, 1),
                          fontSize: 15,
                          fontFamily: "Poppins"),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.04,
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(6, 13, 217, 1),
                        borderRadius: BorderRadius.circular(40)),
                    width: MediaQuery.of(context).size.width *
                        MediaQuery.of(context).size.height *
                        0.00020,
                    height: MediaQuery.of(context).size.width *
                        MediaQuery.of(context).size.height *
                        0.00012,
                    child: FittedBox(
                      child: Text(
                        " ₹  $price",
                        style: TextStyle(color: Colors.white),
                      ),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.005,
                  ),
                  Text(
                    "Slot - " + defaultSlot + " hr",
                    style: TextStyle(fontFamily: 'Poppins'),
                  )
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
      ],
    );
  }
}

class AppDrawer extends StatefulWidget {
  String username;

  AppDrawer(String username) {
    this.username = username;
  }

  @override
  _AppDrawerState createState() => new _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new ListView(
          children: Variables().firebaseuser != null
              ? Variables().user_type != "admin"
                  ? Variables().user_type != "provider"
                      ? <Widget>[
                          Container(
                            child: Text(
                              widget.username,
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold),
                            ),
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.025),
                          ),
                          new DrawerHeader(
                            decoration: BoxDecoration(
                                //color: Color.fromRGBO(6, 13, 217, 1),
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/setitup_final.png'))),
                            //child: new Text(Variables().firebaseuser.email),
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.account_circle,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "View Profile",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.calendar_today,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Scheduled Meets",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.history,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Meet History",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Divider(),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.bug_report_sharp,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Report Bugs",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.rate_review,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Rate Us",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.share,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Share",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.info_outline,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "About",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.logout,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Log Out",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              Variables().setFIrebaseUser(null);
                              final prefs =
                                  await SharedPreferences.getInstance();

                              prefs.remove('User');

                              Navigator.pop(context);
                              Fluttertoast.showToast(msg: "Logged Out");
                            },
                          ),
                        ]
                      : <Widget>[
                          Container(
                            child: Text(
                              widget.username,
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold),
                            ),
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.height * 0.025),
                          ),
                          new DrawerHeader(
                            decoration: BoxDecoration(
                                //color: Color.fromRGBO(6, 13, 217, 1),
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/setitup_final.png'))),
                            //child: new Text(Variables().firebaseuser.email),
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.add_to_photos_rounded,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Add Service",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.view_agenda_outlined,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "View Service",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.calendar_today,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Scheduled Meets",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.history,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Meet History",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Divider(),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.bug_report_sharp,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Report Bugs",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.rate_review,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Rate Us",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.share,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Share",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.info_outline,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "About",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          ListTile(
                            title: Row(
                              children: <Widget>[
                                Padding(padding: EdgeInsets.all(5)),
                                Icon(
                                  Icons.logout,
                                  size: MediaQuery.of(context).size.width *
                                      MediaQuery.of(context).size.height *
                                      0.00008,
                                ),
                                Padding(padding: EdgeInsets.all(5)),
                                Text(
                                  "Log Out",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              Variables().setFIrebaseUser(null);
                              final prefs =
                                  await SharedPreferences.getInstance();

                              prefs.remove('User');

                              Navigator.pop(context);
                              Fluttertoast.showToast(msg: "Logged Out");
                            },
                          ),
                        ]
                  : <Widget>[
                      Container(
                        child: Text(
                          widget.username,
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold),
                        ),
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                            vertical:
                                MediaQuery.of(context).size.height * 0.025),
                      ),
                      new DrawerHeader(
                        decoration: BoxDecoration(
                            //color: Color.fromRGBO(6, 13, 217, 1),
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/setitup_final.png'))),
                        //child: new Text(Variables().firebaseuser.email),
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5)),
                            Icon(
                              Icons.person_add_alt_1,
                              size: MediaQuery.of(context).size.width *
                                  MediaQuery.of(context).size.height *
                                  0.00008,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "Add Service Provider",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProviderSignUp()));
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5)),
                            Icon(
                              Icons.highlight_remove_sharp,
                              size: MediaQuery.of(context).size.width *
                                  MediaQuery.of(context).size.height *
                                  0.00008,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "Remove Service",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5)),
                            Icon(
                              Icons.person_remove_sharp,
                              size: MediaQuery.of(context).size.width *
                                  MediaQuery.of(context).size.height *
                                  0.00008,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "Remove Service Provider",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Divider(),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5)),
                            Icon(
                              Icons.bug_report_sharp,
                              size: MediaQuery.of(context).size.width *
                                  MediaQuery.of(context).size.height *
                                  0.00008,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "Report Bugs",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5)),
                            Icon(
                              Icons.rate_review,
                              size: MediaQuery.of(context).size.width *
                                  MediaQuery.of(context).size.height *
                                  0.00008,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "Rate Us",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5)),
                            Icon(
                              Icons.share,
                              size: MediaQuery.of(context).size.width *
                                  MediaQuery.of(context).size.height *
                                  0.00008,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "Share",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5)),
                            Icon(
                              Icons.info_outline,
                              size: MediaQuery.of(context).size.width *
                                  MediaQuery.of(context).size.height *
                                  0.00008,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "About",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5)),
                            Icon(
                              Icons.logout,
                              size: MediaQuery.of(context).size.width *
                                  MediaQuery.of(context).size.height *
                                  0.00008,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "Log Out",
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Variables().setFIrebaseUser(null);
                          final prefs = await SharedPreferences.getInstance();

                          prefs.remove('User');
                          Variables().session_ID = null;

                          Navigator.pop(context);
                          Timer(Duration(seconds: 1), () {
                            print('Hello');
                          });

                          Variables().user_type = 'user';
                          Fluttertoast.showToast(msg: "Logged Out");
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HomeScreen()));
                        },
                      ),
                    ]
              : <Widget>[
                  Container(
                    child: Text(
                      "Guest User",
                      style: TextStyle(
                          fontFamily: "Poppins", fontWeight: FontWeight.bold),
                    ),
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.025),
                  ),
                  new DrawerHeader(
                    //child: new Text("SetItUp"),
                    decoration: BoxDecoration(

                        //color: Color.fromRGBO(6, 13, 217, 1),
                        image: DecorationImage(
                      image: AssetImage('assets/images/setitup_final.png'),
                    )),
                  ),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(5)),
                        Icon(
                          Icons.account_circle,
                          size: MediaQuery.of(context).size.width *
                              MediaQuery.of(context).size.height *
                              0.0001,
                        ),
                        Padding(padding: EdgeInsets.all(5)),
                        Text(
                          "Sign In",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignInOptions()));
                    },
                  ),
                ]),
    );
  }
}

/*
class Tasks extends StatelessWidget {
  //FirebaseFirestore firestore = FirebaseFirestore.instance;
  //CollectionReference users = FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.docs.map((DocumentSnapshot document) {
            return new ListTile(
              title: new Text(document['title']),
              subtitle: new Text(document['type']),
            );
          }).toList(),
        );
      },
    );
  }
}*/
