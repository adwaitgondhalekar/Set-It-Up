import 'dart:async';

import 'package:SetItUp/globalVariables.dart';
import 'package:SetItUp/userSignIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'cart.dart';
import 'package:intl/intl.dart';

class productDetails extends StatefulWidget {
  String serviceid;
  String productImage;
  String productTitle;
  int productPrice;
  String productDesc;
  String providerName;
  String providerEmail;
  int productDuration;
  String booked_slot;
  List<dynamic> _unBooked_nc = [];
  List<dynamic> _booked_nc = [];
  List<dynamic> _unAvailable_nc = [];

  productDetails(
      String serviceid,
      String image,
      String title,
      int price,
      String desc,
      String productDuration,
      String name,
      String email,
      List<dynamic> _unBooked_nc,
      List<dynamic> _booked_nc,
      List<dynamic> _unAvailable_nc,
      String booked_slot) {
    this.serviceid = serviceid;
    this.productImage = image;
    this.productTitle = title;
    this.productPrice = price;
    this.productDesc = desc;
    this.providerName = name;
    this.providerEmail = email;
    this._unBooked_nc = _unBooked_nc;
    this._booked_nc = _booked_nc;
    this._unAvailable_nc = _unAvailable_nc;
    this.productDuration = (double.parse(productDuration) * 60).toInt();
    this.booked_slot = booked_slot;
  }

  @override
  _productDetailsState createState() => _productDetailsState();
}

class _productDetailsState extends State<productDetails> {
  String dropdownvalue;
  List<String> converted = [];
  List<DateTime> _unAvailable = [];
  List<DateTime> _booked = [];
  List<DateTime> _unBooked = [];

  void convert(List<Timestamp> list_1, List<DateTime> list_2) {
    DateTime x;
    Timestamp y;

    for (int i = 0; i < list_1.length; i++) {
      y = list_1[i];
      x = y.toDate();
      if (x.isAfter(DateTime.now())) {
        list_2.add(x);
      }
    }
  }

  void convertDateTime() {
    _unBooked.forEach((element) {
      converted.add("Date : " +
          DateFormat('dd-MM-yyyy – kk:mm').format(element) +
          " to " +
          (DateFormat('kk:mm')
              .format(element.add(Duration(minutes: widget.productDuration)))));
    });
  }

  void checkbookedslot() {
    if (widget.booked_slot != "null") {
      setState(() {
        dropdownvalue = widget.booked_slot;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget._unBooked_nc.isNotEmpty) {
      List<Timestamp> a = widget._unBooked_nc.cast();
      print("Converted" + a[0].toDate().toString());
      convert(a, _unBooked);
      print(_unBooked);
    }

    if (widget._booked_nc.isNotEmpty) {
      List<Timestamp> b = widget._booked_nc.cast();
      print("Converted" + b[0].toDate().toString());
      convert(b, _booked);
      print(_booked);
    }

    if (widget._unAvailable_nc.isNotEmpty) {
      List<Timestamp> c = widget._unAvailable_nc.cast();
      print("Converted" + c[0].toDate().toString());
      convert(c, _unAvailable);
      print(_unAvailable);
    }
    convertDateTime();
    checkbookedslot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                //alignment: Alignment.topLeft,

                //decoration: BoxDecoration(border: Border.all()),
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.02),
                child: Icon(
                  Icons.arrow_back_ios_sharp,
                  color: Color.fromRGBO(6, 13, 217, 1),
                  size: MediaQuery.of(context).size.height *
                      MediaQuery.of(context).size.width *
                      0.00011,
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.035,
          ),
          // Container(
          //   decoration: BoxDecoration(border: Border.all()),
          // )
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            //decoration: BoxDecoration(border: Border.all()),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.05,
                // ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(60)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      widget.productImage,
                      height: MediaQuery.of(context).size.height *
                          MediaQuery.of(context).size.width *
                          0.00032,
                      width: MediaQuery.of(context).size.height *
                          MediaQuery.of(context).size.width *
                          0.00032,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.08,
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height * 0.01,
                      // ),
                      Text(
                        widget.productTitle,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(6, 13, 217, 1),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(6, 13, 217, 1),
                            borderRadius: BorderRadius.circular(40)),
                        width: MediaQuery.of(context).size.width *
                            MediaQuery.of(context).size.height *
                            0.00025,
                        height: MediaQuery.of(context).size.width *
                            MediaQuery.of(context).size.height *
                            0.00012,
                        child: FittedBox(
                          child: Text(
                            " ₹  " + widget.productPrice.toString(),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),

          Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.10),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.02),
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(35)),
              child: Text(
                widget.productDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppinns',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(6, 13, 217, 1),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Container(
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.10),
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.02),
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(35)),
              child: Column(
                children: [
                  Text(
                    'Provider : ' + widget.providerName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppinns',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(6, 13, 217, 1),
                    ),
                  ),
                  Text(
                    widget.providerEmail,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppinns',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(6, 13, 217, 1),
                    ),
                  ),
                ],
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            "Duration (in hrs) -  " +
                (widget.productDuration / 60).toInt().toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppinns',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(6, 13, 217, 1),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),

          DropdownButton<String>(
              hint: Text("Select a slot"),
              value: dropdownvalue,
              items: converted.map<DropdownMenuItem<String>>((String slot) {
                return DropdownMenuItem<String>(
                  value: slot,
                  child: Row(
                    children: <Widget>[
                      // Text("Date : "+DateFormat('dd-MM-yyyy – kk:mm').format(slot)  +
                      //     " to " +
                      //     (DateFormat('kk:mm').format(slot.add(Duration(minutes: widget.productDuration )))))
                      Text(slot)
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String dateTime) {
                setState(() {
                  dropdownvalue = dateTime;
                });
                print(dropdownvalue);
              }),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Variables().firebaseuser==null
              ? ButtonTheme(
                  height: MediaQuery.of(context).size.height * 0.05,
                  minWidth: MediaQuery.of(context).size.width * 0.25,
                  buttonColor: Color.fromRGBO(6, 13, 217, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: ElevatedButton(
                    onPressed: () {
                      // if (Variables().firebaseuser == null) {
                      //   Fluttertoast.showToast(
                      //       msg: "Please sign in before proceeding to cart");

                      //   Timer(Duration(seconds: 2), () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => userSignIn()));
                      //   });
                      // } else if (dropdownvalue == null) {
                      //   Fluttertoast.showToast(msg: "Please Select a Slot !!");
                      // } else
                      //   addProduct();
                      if (dropdownvalue == null) {
                        Fluttertoast.showToast(msg: "Please Select a Slot !!");
                      } else
                        addProduct();
                    },
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                )
              : Variables().user_type!='admin'?
              Variables().firebaseuser.email!=widget.providerEmail?
              ButtonTheme(
                  height: MediaQuery.of(context).size.height * 0.05,
                  minWidth: MediaQuery.of(context).size.width * 0.25,
                  buttonColor: Color.fromRGBO(6, 13, 217, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: ElevatedButton(
                    onPressed: () {
                      // if (Variables().firebaseuser == null) {
                      //   Fluttertoast.showToast(
                      //       msg: "Please sign in before proceeding to cart");

                      //   Timer(Duration(seconds: 2), () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => userSignIn()));
                      //   });
                      // } else if (dropdownvalue == null) {
                      //   Fluttertoast.showToast(msg: "Please Select a Slot !!");
                      // } else
                      //   addProduct();
                      if (dropdownvalue == null) {
                        Fluttertoast.showToast(msg: "Please Select a Slot !!");
                      } else
                        addProduct();
                    },
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ):
                SizedBox():
                SizedBox(),
        ],
      ),
    );
  }

  Future<void> addProduct() {
    if (Variables().firebaseuser == null) {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(Variables().session_ID)
          .set({'Dummy': 'dummy'});

      //String docpath = 'carts/' + Variables().session_ID;
      FirebaseFirestore.instance
          .collection('carts')
          .doc(Variables().session_ID)
          .collection('/cart_items')
          .doc(widget.serviceid)
          //.update({'Booked_Slot':dropdownvalue})

          .set({
            'Image': widget.productImage,
            'Title': widget.productTitle, // John Doe
            'Price': widget.productPrice, // Stokes and Sons
            'Description': widget.productDesc,
            'UnAvailableSlot': widget._unAvailable_nc,
            'UnBookedSlot': widget._unBooked_nc,
            'BookedSlot': widget._booked_nc,
            'Duration': widget.productDuration,
            'Email': widget.providerEmail,
            'Name': widget.providerName,
            'Booked_Slot': dropdownvalue
          })
          .then((value) => Navigator.push(
              context, MaterialPageRoute(builder: (context) => Cart())))

          // Fluttertoast.showToast(msg: "added to cart"))

          .catchError((error) => {
                Fluttertoast.showToast(
                    msg: "Failed to add product: $error",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0),
                setState(() {
                  //data_flag = 1;
                })
              });
    } else {
      FirebaseFirestore.instance
          .collection('carts')
          .doc(Variables().session_ID)
          .set({'Dummy': 'dummy'});

      //String docpath = 'carts/' + Variables().userid;
      FirebaseFirestore.instance
          .collection('carts')
          .doc(Variables().userid)
          .collection('/cart_items')
          .doc(widget.serviceid)
          //.update({'Booked_Slot':dropdownvalue})
          .set({
            'Image': widget.productImage,
            'Title': widget.productTitle, // John Doe
            'Price': widget.productPrice, // Stokes and Sons
            'Description': widget.productDesc,
            'UnAvailableSlot': widget._unAvailable_nc,
            'UnBookedSlot': widget._unBooked_nc,
            'BookedSlot': widget._booked_nc,
            'Duration': widget.productDuration,
            'Email': widget.providerEmail,
            'Name': widget.providerName,
            'Booked_Slot': dropdownvalue
          })
          .then((value) => Navigator.push(
              context, MaterialPageRoute(builder: (context) => Cart())))

          // Fluttertoast.showToast(msg: "added to cart"))

          .catchError((error) => {
                Fluttertoast.showToast(
                    msg: "Failed to add product: $error",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0),
                setState(() {
                  //data_flag = 1;
                })
              });
    }
  }
}
