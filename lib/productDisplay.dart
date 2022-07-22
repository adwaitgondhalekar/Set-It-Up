import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:string_validator/string_validator.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';



class ProductDisplay extends StatefulWidget {
  @override
  _ProductDisplayState createState() => _ProductDisplayState();
}

class _ProductDisplayState extends State<ProductDisplay> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _onPressed() {
    firestore.collection("services").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        print(result.data());
      });
    });
  }

  int img_flag = 0,
      data_flag = 0,
      title_flag = 0,
      price_flag = 0,
      select_img_flag = 0,
      description_flag = 0,
      about_flag = 0,
      date_flag = 0;
  String title_msg = '',
      price_msg = '',
      img_msg = '',
      about_msg = '',
      date_msg = '',
      desc_msg = '';
  File _image;
  String _uploadedImageURL;
  final title_controller = TextEditingController();
  final price_controller = TextEditingController();
  final product_description_controller = TextEditingController();
  final about_controller = TextEditingController();
  String title = '', about = '', product_desc = '', slot_duration = '';
  //String price = '';
  double price = 0;

  CalendarView _calendarView;
  List<TimeRegion> _specialTimeRegions = [];
  List<DateTime> _unAvailable = [];
  List<DateTime> _booked = [];
  List<DateTime> _unBooked = [];

  @override
  void initState() {
    _getTimeRegions();
    _calendarView = CalendarView.week;
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
    print('hiii');
    while (date.isBefore(max)) {
      _unAvailable.add(date);
      date = date.add(Duration(minutes: slot));
    }
    print(date);
    print('hola');
    print(_unAvailable);
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

      print(dates);
      _unBooked.add(dates);
      _unAvailable.remove(dates);
      print(_unBooked);
      print('TEST');
      print(_unAvailable);
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

  Future uploadFile() async {
    firebase_storage.Reference storageReference = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('services/${title}/display_image_${title}.png');
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.whenComplete(() => {
          print('File Uploaded'),
          storageReference.getDownloadURL().then((fileURL) {
            setState(() {
              _uploadedImageURL = fileURL;
              // print('I am here!!!!!'+_uploadedImageURL);
            });
          })
        });
    await uploadTask.catchError((error) => {
          setState(() {
            img_flag = 1;
            print(error);
          })
        });
  }

  CollectionReference services =
      FirebaseFirestore.instance.collection('services');

  Future<void> addService() {
    // Call the user's CollectionReference to add a new user
    return services
        .add({
          'Image': _uploadedImageURL.toString(),
          'Title': title, // John Doe
          'Price': price, // Stokes and Sons
          'Description': product_desc,
          'UnAvailableSlot': _unAvailable,
          'UnBookedSlot': _unBooked,
          'BookedSlot': _booked,
          'Duration': slot_duration,
          'About': about,
        })
        .then((value) => print("Service Added"))
        .catchError((error) => {
              print("Failed to add user: $error"),
              setState(() {
                data_flag = 1;
              })
            });
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

    if (price == 0) {
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

    if (about == '') {
      setState(() {
        about_flag = 1;
        about_msg = 'Field Required';
      });
    } else if (isNumeric(about)) {
      setState(() {
        about_flag = 1;
        about_msg = 'Invalid About';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: [
                        GestureDetector(
                          //onTap: getImage,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            child: _image == null
                                ? Align(
                                    child: Text(
                                      'No image selected.',
                                      style: TextStyle(fontFamily: "Poppins"),
                                    ),
                                    alignment: Alignment.center,
                                  )
                                : FittedBox(
                                    //child: Image.file(_image),
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
              height: MediaQuery.of(context).size.height * 0.20,
              width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(60)),
              child: TextField(
                  controller: product_description_controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
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

            // Container(
            //   height: MediaQuery.of(context).size.height * 0.30,
            //   width: MediaQuery.of(context).size.width * 0.80,
            //   child: FittedBox(
            //     fit: BoxFit.contain,
            //     child: SfDateRangePicker(
            //       onSelectionChanged: _onSelectionChanged,
            //       selectionMode: DateRangePickerSelectionMode.multiple,
            //       enablePastDates: false,
            //     ),
            //   ),
            // ),
            Container(
                height: MediaQuery.of(context).size.height * 0.03,
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Select Slot Duration(in hrs)'),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: Icon(Icons.arrow_downward_rounded),
                      iconSize: 17,
                      elevation: 16,
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
              height: MediaQuery.of(context).size.height * 0.20,
              width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(60)),
              child: TextField(
                  controller: about_controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'About ',
                  )),
            ),
            about_flag == 0
                ? SizedBox(height: 0)
                : Container(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.01),
                    child: Text('*' + about_msg,
                        style: TextStyle(color: Colors.red))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ButtonTheme(
              height: MediaQuery.of(context).size.height * 0.05,
              minWidth: MediaQuery.of(context).size.width * 0.25,
              buttonColor: Color.fromRGBO(6, 13, 217, 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: Row(
                children: <Widget>[
                  RaisedButton(child: Text('Back'), onPressed: null),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        title = title_controller.text;
                        price = double.parse(price_controller.text);
                        product_desc = product_description_controller.text;
                        about = about_controller.text;
                        slot_duration = dropdownValue;
                        title_flag = 0;
                        price_flag = 0;
                        about_flag = 0;
                        description_flag = 0;
                        select_img_flag = 0;
                        date_flag = 0;
                      });
                      validator();
                      if (about_flag == 0 &&
                          date_flag == 0 &&
                          select_img_flag == 0 &&
                          title_flag == 0 &&
                          price_flag == 0 &&
                          description_flag == 0) {
                        uploadFile();
                        addService();
                        if (img_flag == 0 && data_flag == 0) {
                          Fluttertoast.showToast(
                              msg: "Service added Successfully!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Error adding Service! Try Again.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
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
                      "Add to Cart",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.045),
                    ),
                  ),
                ],
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
