import 'dart:async';

import 'package:SetItUp/signInOptions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'productDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:SetItUp/globalVariables.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

String userid;

getUserData() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('User') ?? null;
}

class _CartState extends State<Cart> {
  void convert(List<Timestamp> list_1, List<DateTime> list_2) {
    DateTime x;
    Timestamp y;

    for (int i = 0; i < list_1.length; i++) {
      y = list_1[i];
      x = y.toDate();
      list_2.add(x);
    }
  }

  bool service_exists;

  void updateservicestatus(DocumentSnapshot value) {
    if (value.exists == true) {
      setState(() {
        service_exists = true;
      });
    } else {
      setState(() {
        service_exists = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (Variables().firebaseuser != null && Variables().cart_updated != 1) {
      getUserData().then((value) => setUserData(value));

      Timer(Duration(seconds: 1), () {
        getCart();
      });
    }
  }

  void setUserData(List<String> data) {
    if (data != null) {
      setState(() {
        userid = data[0];
        //Fluttertoast.showToast(msg: userid);
        Variables().setUserId(userid);
        Fluttertoast.showToast(msg: Variables().userid);
      });
    } else {
      Fluttertoast.showToast(msg: 'null data');
    }
  }

  void getCart() {
    String path = 'carts/' + userid + '/cart_items';

    FirebaseFirestore.instance
        .collection('carts')
        .doc(Variables().session_ID)
        .collection('cart_items')
        .get()
        .then((QuerySnapshot data) {
      if (data.size != 0) {
        //print('Document data: ${data.data()}');
        updateCart(data, path);
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  updateCart(QuerySnapshot data, String path) {
    FirebaseFirestore.instance
        .collection('carts')
        .doc(userid)
        .set({'Dummy': 'dummy'});

    data.docs.forEach((element) {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(userid)
          .collection('cart_items')
          .doc(element.id)
          .set(element.data());
    });

    deleteCart();
  }

  deleteCart() {
    FirebaseFirestore.instance
        .collection('carts')
        .doc(Variables().session_ID)
        .collection('cart_items')
        .get()
        .then((value) => {value.docs.forEach((element) {
          element.reference.delete();
        })});
    //.catchError((error) => print("Error in deleting old cart document"));

    FirebaseFirestore.instance
        .doc('carts/' + Variables().session_ID)
        .delete()
        .then((value) => print("Deleted old cart doc"))
        .catchError((error) => print('failed to remove old cart doc'));

    Variables().setCartUpdateStatus(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(6, 13, 217, 1),
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff060DD9),
          title: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                Text("My Cart"),
                SizedBox(width: MediaQuery.of(context).size.width * 0.15)
              ],
            ),
          )),
      body: Variables().firebaseuser == null
          ? Column(children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.65,
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all(),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40))),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('carts')
                        .doc(Variables().session_ID)
                        .collection('cart_items')
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
                          "No items in your Cart !",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(6, 13, 217, 1)),
                        ));
                      }

                      Variables().cartstatus = 1;

                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot documentSnapshot = 
                                snapshot.data.docs[index];

                            String serviceid = documentSnapshot.id.toString();
                            String Image = documentSnapshot['Image'];
                            String Title = documentSnapshot['Title'];
                            String Name = documentSnapshot['Name'];
                            String Duration =
                                ((documentSnapshot['Duration']) / 60)
                                    .toString();
                            int Price = documentSnapshot['Price'];
                            String Email = documentSnapshot['Email'];
                            String Desc = documentSnapshot['Description'];
                            String Slot = documentSnapshot['Booked_Slot'];

                            String servicepath = 'services/' + serviceid;

                            if (FirebaseFirestore.instance.doc(servicepath) !=
                                null) {
                              return ServiceTile(
                                serviceImage: Image,
                                serviceName: Title,
                                providerName: Name,
                                defaultSlot: Duration,
                                price: Price,
                                documentSnapshot: documentSnapshot,
                                slot: Slot,
                              );
                            }
                          });
                    }),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('carts')
                          .doc(Variables().session_ID)
                          .collection('cart_items')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Something went wrong'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: Text("Loading"));
                        }

                        if (snapshot.data.size == 0) {
                          return Center();
                        }
                        int grand_total = 0;

                        snapshot.data.docs.forEach((element) {
                          grand_total += element.data()['Price'];
                        });

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Grand Total - ₹" + grand_total.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.045))
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              alignment: Alignment.bottomCenter,
                              child: ButtonTheme(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.25,
                                buttonColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SignInOptions()),
                                        (route) => false);
                                  },
                                  child: Text(
                                    "Proceed to Checkout",
                                    style: TextStyle(
                                        color: Color.fromRGBO(6, 13, 217, 1),
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.045),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ])
          : Column(children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.65,
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    border: Border.all(),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40))),
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('carts')
                        .doc(userid)
                        .collection('cart_items')
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
                          "No items in your Cart !",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(6, 13, 217, 1)),
                        ));
                      }

                      //Variables().cartstatus = 1;

                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot documentSnapshot =
                                snapshot.data.docs[index];

                            String serviceid = documentSnapshot.id.toString();
                            String Image = documentSnapshot['Image'];
                            String Title = documentSnapshot['Title'];
                            String Name = documentSnapshot['Name'];
                            String Duration =
                                ((documentSnapshot['Duration']) / 60)
                                    .toString();
                            int Price = documentSnapshot['Price'];
                            String Email = documentSnapshot['Email'];
                            String Desc = documentSnapshot['Description'];
                            String Slot = documentSnapshot['Booked_Slot'];

                            String servicepath = 'services/' + serviceid;

                            if (FirebaseFirestore.instance.doc(servicepath) !=
                                null) {
                              return ServiceTile(
                                serviceImage: Image,
                                serviceName: Title,
                                providerName: Name,
                                defaultSlot: Duration,
                                price: Price,
                                documentSnapshot: documentSnapshot,
                                slot: Slot,
                              );
                            }
                          });
                    }),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('carts')
                          .doc(userid)
                          .collection('cart_items')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Something went wrong'));
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: Text("Loading"));
                        }

                        if (snapshot.data.size == 0) {
                          return Center();
                        }
                        int grand_total = 0;

                        snapshot.data.docs.forEach((element) {
                          grand_total += element.data()['Price'];
                        });

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Grand Total - ₹" + grand_total.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.045))
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              alignment: Alignment.bottomCenter,
                              child: ButtonTheme(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.25,
                                buttonColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Proceed to Checkout",
                                    style: TextStyle(
                                        color: Color.fromRGBO(6, 13, 217, 1),
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.045),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ),
            ]),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String serviceImage;
  final String serviceName;
  final String providerName;
  final String defaultSlot;
  //final String productDesc;
  final int price;
  final String slot;
  final DocumentSnapshot documentSnapshot;
  // List<DateTime> unAvailable = [];
  // List<DateTime> booked = [];
  // List<DateTime> unBooked = [];

  ServiceTile(
      {@required this.serviceImage,
      @required this.serviceName,
      @required this.providerName,
      @required this.defaultSlot,
      @required this.price,
      @required this.documentSnapshot,
      @required this.slot
      // @required this.unAvailable,
      // @required this.booked,
      // @required this.unBooked
      });

  @override
  //
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
                      "Provider: " + providerName,
                      softWrap: true,
                      style: TextStyle(
                          color: Color.fromRGBO(6, 168, 217, 1),
                          fontSize: 12,
                          fontFamily: "Poppins"),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Text(
                      "Duration (in hrs) - " + defaultSlot,
                      softWrap: true,
                      style: TextStyle(
                          color: Color.fromRGBO(6, 13, 217, 1),
                          fontSize: 9,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Text(
                      slot,
                      softWrap: true,
                      style: TextStyle(
                          color: Color.fromRGBO(6, 13, 217, 1),
                          fontSize: 12,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.04,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.01,
                  // ),
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
                        " ₹  " + price.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => productDetails(
                                      documentSnapshot.id.toString(),
                                      documentSnapshot['Image'],
                                      documentSnapshot['Title'],
                                      documentSnapshot['Price'],
                                      documentSnapshot['Description'],
                                      ((documentSnapshot['Duration']) /
                                              60.toInt())
                                          .toString(),
                                      documentSnapshot['Name'],
                                      documentSnapshot['Email'],
                                      documentSnapshot['UnBookedSlot'],
                                      documentSnapshot['BookedSlot'],
                                      documentSnapshot['UnAvailableSlot'],
                                      documentSnapshot['Booked_Slot'])));
                        },
                        child: Text(
                          "Edit",
                          //softWrap: true,
                          style: TextStyle(
                              color: Color.fromRGBO(6, 13, 217, 1),
                              fontSize: 15,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Variables().firebaseuser == null
                          ? GestureDetector(
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection("carts")
                                    .doc(Variables().session_ID)
                                    .collection("cart_items")
                                    .doc(documentSnapshot.id)
                                    .delete();
                              },
                              child: Text(
                                "Remove",
                                //softWrap: true,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                FirebaseFirestore.instance
                                    .collection("carts")
                                    .doc(userid)
                                    .collection("cart_items")
                                    .doc(documentSnapshot.id)
                                    .delete();
                              },
                              child: Text(
                                "Remove",
                                //softWrap: true,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 15,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                    ],
                  ),
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
