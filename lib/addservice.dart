import 'dart:async';

import 'package:SetItUp/globalVariables.dart';
import 'package:SetItUp/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:string_validator/string_validator.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';

class AddService extends StatefulWidget {
  final String email;
  final String usern;

  AddService(this.email, this.usern);
  @override
  _AddServiceState createState() => _AddServiceState(email, usern);
}

class _AddServiceState extends State<AddService> {
  final String email;
  final String usern;
  _AddServiceState(this.email, this.usern);
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  //String username;

  int img_flag = 0,
      data_flag = 0,
      title_flag = 0,
      price_flag = 0,
      select_img_flag = 0,
      description_flag = 0,
      email_flag = 0,
      date_flag = 0,
      provider_name_flag = 0;
  String title_msg = '',
      price_msg = '',
      img_msg = '',
      email_msg = '',
      date_msg = '',
      desc_msg = '',
      provider_name_msg = '';
  File _image;
  var _uploadedImageURL;
  final title_controller = TextEditingController();
  final price_controller = TextEditingController();
  final product_description_controller = TextEditingController();
  final provider_name_controller = TextEditingController();

  String title = '', product_desc = '', slot_duration = '', provider_name = '';
  //String price = '';
  double price ;

  CalendarView _calendarView;
  List<TimeRegion> _specialTimeRegions = [];
  List<DateTime> _unAvailable = [];
  List<DateTime> _booked = [];
  List<DateTime> _unBooked = [];

  @override
  void initState() {
    _getTimeRegions();
    _calendarView = CalendarView.week;
    //RetrieveUser();
    super.initState();
  }

  final picker = ImagePicker();
  String dropdownValue = '1';

  void _getTimeRegions() {
    _specialTimeRegions = <TimeRegion>[];
    _specialTimeRegions.add(TimeRegion(
        startTime: DateTime(2020, 5, 29, 09, 0, 0),
        endTime: DateTime(2020, 5, 29, 10, 0, 0),
        recurrenceRule: 'FREQ=WEEKLY;INTERVAL=1;BYDAY=SAT,',
        text: 'Special Region',
        color: Colors.red,
        enablePointerInteraction: true,
        textStyle: TextStyle(
          color: Colors.black,
          fontStyle: FontStyle.italic,
          fontSize: 10,
        )));
  }

  void initialize(int slot) {
    _unAvailable.clear();
    _unBooked.clear();

    DateTime present = DateTime.now();
    DateTime date = DateTime(present.year, present.month, present.day);
    DateTime max = date.add(Duration(days: 7));
    //print('hiii');
    while (date.isBefore(max)) {
      _unAvailable.add(date);
      date = date.add(Duration(minutes: slot));
    }
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    DateTime dates;
    //print(DateTime.now().month);
    _specialTimeRegions.add(TimeRegion(
      startTime: calendarTapDetails.date,
      endTime: calendarTapDetails.date
          .add(Duration(minutes: (double.parse(dropdownValue) * 60).toInt())),
      //text: 'tap',
      color: Color(0xffbD3D3D3),
    ));
    setState(() {
      dates = calendarTapDetails.date;

      _unBooked.add(dates);
      _unAvailable.remove(dates);
    });
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void getServiceId() {
    var uuid = Uuid();
    String service_id = uuid.v4();
    Variables().setServiceID(service_id);
  }

  Future uploadFile() async {
    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('services/'+Variables().service_ID+'/${title}.png');
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_image);

    //var image_Url;
    uploadTask
        .then((tasksnapshot) async => {
              _uploadedImageURL = await storageReference.getDownloadURL(),
              addService()
            })
        .catchError((error) => {
              setState(() {
                img_flag = 1;
                print(error);
              })
            });
  }

  Future<void> addService() {
    String path = 'services/' + Variables().service_ID;
    FirebaseFirestore.instance
        .doc(path)
        .set({
          'Image': _uploadedImageURL.toString(),
          'Title': title, // John Doe
          'Price': price.toInt(), // Stokes and Sons
          'Description': product_desc,
          'UnAvailableSlot': _unAvailable,
          'UnBookedSlot': _unBooked,
          'BookedSlot': _booked,
          'Duration': slot_duration,
          'Email': email,
          'Name': usern,
        })
        .then((value) => print("Service Added" + _uploadedImageURL))
        .catchError((error) => {
              print("Failed to add user: $error"),
              setState(() {
                data_flag = 1;
              })
            });

    // Call the user's CollectionReference to add a new user
    /* return services
        .add({
          'Image': _uploadedImageURL.toString(),
          'Title': title, // John Doe
          'Price': price, // Stokes and Sons
          'Description': product_desc,
          'UnAvailableSlot': _unAvailable,
          'UnBookedSlot': _unBooked,
          'BookedSlot': _booked,
          'Duration': slot_duration,
          'Email': email,
          'Name': usern,
        })
        .then((value) => print("Service Added" + _uploadedImageURL))
        .catchError((error) => {
              print("Failed to add user: $error"),
              setState(() {
                data_flag = 1;
              })
            });*/
  }

  void validator() {
    if (_image == null) {
      setState(() {
        select_img_flag = 1;
        img_msg = 'Upload Image';
      });
    }

    if (title == '') {
      setState(() {
        title_flag = 1;
        title_msg = 'Field Required';
      });
    } else if (!(isAlphanumeric(title))) {
      if (title.contains(' ')) {
        setState(() {
          title_flag = 0;
        });
      } else {
        setState(() {
          title_flag = 1;
          title_msg = 'Invalid Title';
        });
      }
    }
    // if (provider_name == '') {
    //   setState(() {
    //     provider_name_flag = 1;
    //     provider_name_msg = 'Full Name Required';
    //   });
    // } else if (!(isAlpha(provider_name))) {
    //   if (provider_name.contains(' ')) {
    //     setState(() {
    //       provider_name_flag = 0;
    //     });
    //   } else {
    //     setState(() {
    //       provider_name_flag = 1;
    //       provider_name_msg = 'Invalid Name';
    //     });
    //   }
    // }

    if (price == '') {
      setState(() {
        price_flag = 1;
        price_msg = 'Field Required';
      });
    } else if (price < 0) {
      setState(() {
        price_flag = 1;
        price_msg = 'Invalid Price';
      });
    }

    if (product_desc == '') {
      setState(() {
        description_flag = 1;
        desc_msg = 'Field Required';
      });
    } else if (isNumeric(product_desc)) {
      setState(() {
        description_flag = 1;
        desc_msg = 'Invalid Description';
      });
    }

    if (_unBooked.isEmpty) {
      setState(() {
        date_flag = 1;
        date_msg = 'Date Required';
      });
    }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),

            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    //padding: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.02),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: getImage,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            child: _image == null
                                ? Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'No image selected.',
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : FittedBox(
                                    child: Image.file(_image),
                                    fit: BoxFit.fill,
                                  ),
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.11),
                            decoration: BoxDecoration(
                                border: Border.all(), shape: BoxShape.circle),
                            height: MediaQuery.of(context).size.height * 0.15,
                            width: MediaQuery.of(context).size.width * 0.32,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        select_img_flag == 0
                            ? SizedBox(height: 0)
                            : Container(
                                child: Text('*' + img_msg,
                                    style: TextStyle(color: Colors.red)),
                              ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: Column(
                      children: <Widget>[
                        TextField(
                          minLines: 1,
                          maxLines: 3,
                          maxLength: 70,
                          textAlign: TextAlign.center,
                          controller: title_controller,
                          decoration: InputDecoration(hintText: 'Set Title'),
                        ),
                        title_flag == 0
                            ? SizedBox(height: 0)
                            : Container(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.01),
                                child: Text('*' + title_msg,
                                    style: TextStyle(color: Colors.red))),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        TextField(
                          textAlign: TextAlign.center,
                          controller: price_controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: 'Set Price'),
                        ),
                        price_flag == 0
                            ? SizedBox(height: 0)
                            : Container(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.01),
                                child: Text('*' + price_msg,
                                    style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              alignment: Alignment.center,
              //height: MediaQuery.of(context).size.height * 0.20,
              width: MediaQuery.of(context).size.width * 0.75,
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.width * 0.035),
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(60)),
              child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: product_description_controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add Product Description',
                  )),
            ),
            description_flag == 0
                ? SizedBox(height: 0)
                : Container(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.01),
                    child: Text('*' + desc_msg,
                        style: TextStyle(color: Colors.red))),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),

            Container(
                height: MediaQuery.of(context).size.height * 0.03,
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Select Slot Duration(in hrs)'),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                    DropdownButton<String>(
                      underline: Container(),
                      value: dropdownValue,
                      icon: Icon(
                        Icons.arrow_drop_down,
                      ),

                      // style: TextStyle(color: Colors.deepPurple),

                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                          // ignore: unnecessary_statements
                          initialize(
                              (double.parse(dropdownValue) * 60).toInt());
                          print(dropdownValue);
                        });
                      },
                      items: <String>['0.5', '1', '2']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                )),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),

            Container(
              child: SfCalendar(
                view: CalendarView.week,
                specialRegions: _specialTimeRegions,
                minDate: DateTime.now(),
                maxDate: DateTime.now().add(Duration(days: 6)),
                // onViewChanged: viewChanged,
                onTap: calendarTapped,
                //onLongPress: longPressed,
                timeSlotViewSettings: TimeSlotViewSettings(
                    timeInterval: Duration(
                        minutes: (double.parse(dropdownValue) * 60).toInt()),
                    timeFormat: 'hh:mm a'),
              ),
            ),

            date_flag == 0
                ? SizedBox(height: 0)
                : Container(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.01),
                    child: Text('*' + date_msg,
                        style: TextStyle(color: Colors.red))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),

            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05),
              //decoration: BoxDecoration(border: Border.all()),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.email_outlined),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.03,
                        // decoration: BoxDecoration(border: Border.all()),
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            email,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                //fontSize: 1,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.person),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.03,
                        // decoration: BoxDecoration(border: Border.all()),
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            usern,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                //fontSize: 1,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     Icon(Icons.person_pin_outlined),
                  //     SizedBox(
                  //       width: MediaQuery.of(context).size.width * 0.02,
                  //     ),
                  //     Container(
                  //       alignment: Alignment.center,
                  //       height: MediaQuery.of(context).size.height * 0.04,
                  //        //decoration: BoxDecoration(border: Border.all()),
                  //       width: MediaQuery.of(context).size.width * 0.65,
                  //       child:  TextField(
                  //         textAlign: TextAlign.center,

                  //         decoration: InputDecoration(

                  //           border: InputBorder.none,
                  //           hintText: "Add Your Full Name",
                  //         ),
                  //       ),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            ),
            // SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.05,
            //       ),

            // provider_name_flag == 0
            //                 ? SizedBox(height: 0)
            //                 : Container(
            //                     padding: EdgeInsets.all(
            //                         MediaQuery.of(context).size.width * 0.01),
            //                     child: Text('*' + provider_name_msg,
            //                         style: TextStyle(color: Colors.red))),
            //                          SizedBox(
            //         height: MediaQuery.of(context).size.height * 0.05,
            //       ),

            ButtonTheme(
              height: MediaQuery.of(context).size.height * 0.05,
              minWidth: MediaQuery.of(context).size.width * 0.25,
              buttonColor: Color.fromRGBO(6, 13, 217, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: RaisedButton(
                onPressed: () {
                  setState(() {
                    title = title_controller.text;
                    price = double.parse(price_controller.text);
                    product_desc = product_description_controller.text;
                    provider_name = provider_name_controller.text;

                    slot_duration = dropdownValue;
                    title_flag = 0;
                    price_flag = 0;
                    email_flag = 0;
                    description_flag = 0;
                    select_img_flag = 0;
                    date_flag = 0;
                  });
                  getServiceId();
                  validator();
                  if (email_flag == 0 &&
                      date_flag == 0 &&
                      select_img_flag == 0 &&
                      title_flag == 0 &&
                      price_flag == 0 &&
                      description_flag == 0) {
                    uploadFile();
                    if (img_flag == 0 && data_flag == 0) {
                      Timer(Duration(seconds: 4), () {
                        Fluttertoast.showToast(
                            msg: "Service added Successfully!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      });
                      Timer(Duration(seconds: 6), () {
                        //Variables().provider_auth.signOut();

                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                      });
                    } else {
                      Timer(Duration(seconds: 4), () {
                        Fluttertoast.showToast(
                            msg: "Error adding Service! Try Again.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      });
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: "Fill all the required Fields!!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: Text(
                  "Add Service",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.045),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            //_image == null ? Text('null') : Text('${_image.absolute}')
          ],
        ),
      ),
    );
  }
}
