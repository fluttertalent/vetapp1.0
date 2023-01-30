import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vetapp/LocationScreen.dart';
import 'services/animalObject.dart';
import 'services/debitObject.dart';
import 'services/hotelObject.dart';
import 'package:location/location.dart';
import 'main_menu.dart';
import 'package:place_picker/place_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'payment/checkout_view.dart';

class AppointmentCont extends StatefulWidget{
  static const id = 'Appointment';
  final int appointType;
  final List<String> addedAnimals;
  final int animlaLenth;
  final int vetType;
  final int days;
  const AppointmentCont({
    Key? key,
    required this.appointType,
    required this.addedAnimals,
    required this.animlaLenth,
    required this.vetType,
    required this.days
  }) : super(key: key);
  @override
  State<AppointmentCont> createState() => _AppointmentCont();
}

class _AppointmentCont extends State<AppointmentCont>{

  CollectionReference debits = FirebaseFirestore.instance.collection('debits');
  CollectionReference hotels = FirebaseFirestore.instance.collection('hotels');
  CollectionReference appointments = FirebaseFirestore.instance.collection('transactions');

  List<HotelObject> hotelObjects = [];
  List<DebitObject> debitObjects = [];
  final now = DateTime.now();
  late String month;
  late String day;
  late String year;
  late String hour;
  late String realHour;
  late String min;
  late String pm;
  double amount = 0;
  bool nowTime = true;

  bool monthDisabled = false;
  bool dayDisabled = false;
  bool yearDisabled = false;
  bool hourDisabled = false;
  bool minDisabled = false;
  bool pmDisabled = false;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();

  void initDate(){
    final now = DateTime.now();
    String setHour;
    setState(() {
      month = now.month.toString();
      year = now.year.toString();
      day = now.day.toString();
      setHour = now.hour.toString();
      if(int.parse(setHour)<10){
        setHour = '0'+setHour;
      }
      realHour = setHour;
      print(realHour);
      min = now.minute.toString();
      if(int.parse(setHour) > 11) {
        setHour = (now.hour -12).toString();
        pm = "pm";
      }
      else {
        pm = "am";
      }
      if(int.parse(setHour)<10){
        setHour = '0'+setHour;
      }
      hourController.text = setHour;
      hour = setHour;
      if(int.parse(min)<10){
        min = '0'+min;
      }
      minController.text = min;
      nowTime = true;
      monthDisabled = true;
      dayDisabled = true;
      yearDisabled = true;
      hourDisabled = false;
      minDisabled = false;
      pmDisabled = true;
    });
  }
  void laterDate(){
    setState((){
      nowTime = false;
      monthDisabled = false;
      dayDisabled = false;
      yearDisabled = false;
      hourDisabled = true;
      minDisabled = true;
      pmDisabled = false;
    });
  }
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }
  List<DropdownMenuItem<String>> get yearDropdownItems{
    List<DropdownMenuItem<String>> menuItems = [];
    for(var i=int.parse(year)-50;i<int.parse(year)+50;i++){
      menuItems.add (DropdownMenuItem(child: Text("${i}"),value: "${i}"),);
    }
    return menuItems;
  }
  List<DropdownMenuItem<String>> get dropdownItems{
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("January"),value: "01"),
      const DropdownMenuItem(child: Text("Febrary"),value: "02"),
      const DropdownMenuItem(child: Text("March"),value: "03"),
      const DropdownMenuItem(child: Text("April"),value: "04"),
      const DropdownMenuItem(child: Text("May"),value: "05"),
      const DropdownMenuItem(child: Text("June"),value: "06"),
      const DropdownMenuItem(child: Text("July"),value: "07"),
      const DropdownMenuItem(child: Text("August"),value: "08"),
      const DropdownMenuItem(child: Text("Septemper"),value: "09"),
      const DropdownMenuItem(child: Text("October"),value: "10"),
      const DropdownMenuItem(child: Text("November"),value: "11"),
      const DropdownMenuItem(child: Text("December"),value: "12"),
    ];
    return menuItems;
  }
  List<DropdownMenuItem<String>> get dayDropdownItems{
    List<DropdownMenuItem<String>> menuItems = [];
    final int days = getDaysInMonth(int.parse(year), int.parse(month));
    for(var i=0;i<=days;i++){
      menuItems.add (DropdownMenuItem(child: Text("${i}"),value: "${i}"),);
    }
    return menuItems;
  }
  List<DropdownMenuItem<String>> get pmDropdownItems{
    List<DropdownMenuItem<String>> menuItems = [];
    menuItems.add (DropdownMenuItem(child: Text("pm   "),value: "pm"),);
    menuItems.add (DropdownMenuItem(child: Text("am   "),value: "am"),);
    return menuItems;
  }
  List<DropdownMenuItem<String>> get debitDropdownItems{
    List<DropdownMenuItem<String>> menuItems = [];
    debitObjects.forEach((element) {

    });
    return menuItems;
  }
  List<DropdownMenuItem<String>> get hotelItems{
    List<DropdownMenuItem<String>> menuItems = [];
    hotelObjects.forEach((element) {

    });
    return menuItems;
  }
  set dayDropdownItems (List<DropdownMenuItem<String>> tempMenuItems){
    dayDropdownItems = tempMenuItems;
  }
  void changeDay(value){
    setState(() {
      day = value;
    });
  }
  void changeMonth(value){
    setState(() {
      month = value;
    });
  }
  void changeYear(value){
    List<DropdownMenuItem<String>> menuItems = [];
    for(var i=int.parse(year)-50;i<int.parse(year)+50;i++){
      menuItems.add (DropdownMenuItem(child: Text("${i}"),value: "${i}"),);
    }
    setState(() {
      year = value;
    });
  }
  void changePM(value){
    setState(() {
      pm = value;
      if(pm == 'am') {
        realHour = hour;
      } else {
        realHour = (int.parse(hour)+12).toString();
      }
    });
  }

  TextEditingController hourController = new TextEditingController();
  TextEditingController rangeController = new TextEditingController();
  TextEditingController minController =  new TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  var _userLocation;
  bool _userLocCatched = false;
  bool _isPicked = false;
  var _pickedLocation;
  Uint8List? imageBytes;
  List<Marker> _markers = <Marker>[];
  late Marker _userMarker;
  void updatePos(Marker marker){
    setState(() {
      _markers.add(_userMarker);
      _userLocCatched = true;
    });
  }
  void updatePickPos(LatLng pickLoc){
    Marker _pickedMarker =  Marker(
        markerId: MarkerId('User'),
        position: LatLng(pickLoc.latitude,pickLoc.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
            title: 'The title of the marker'
        )
    );
    setState(() {
      _markers.clear();
      _isPicked = true;
      _pickedLocation = pickLoc;
      _markers.add(_pickedMarker);
      _markers.add(_userMarker);
    });
  }
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 12,
  );
  final Map<String, bool> _map = {};

  Future<bool> _initLocationService() async {
    var location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) {
        return  false;
      }
    }
    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return false;
      }
    }
    _userLocation = await location.getLocation();
    _userMarker =  Marker(
        markerId: const MarkerId('User'),
        position: LatLng(_userLocation.latitude,_userLocation.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
            title: 'The title of the marker'
        )
    );
    updatePos(_userMarker);
    return true;
  }
  void changeHour(value){
    var setHour;

    if(int.parse(value)<0) {
      setHour = '00';
    }
    else if(int.parse(value)>12) {
      setHour = '11';
    }
    else{
      setHour = value;
    }
    setState(() {
      if(int.parse(setHour)<10){
        hour = '0'+setHour;
      }
      hour = setHour;
      hourController.text = setHour;
      if(pm =='pm') {
        realHour = (int.parse(setHour)+12).toString();
      }
      else{
        realHour = hour;
      }
    });
  }
  void changemin(value){
    var setMin;
    if(int.parse(value)<0) {
      setMin = '0';
    } else if(int.parse(value)>59) {
      setMin = '59';
    }
    else{
      setMin = value;
    }
    setState(() {
      min = setMin;
      if(int.parse(setMin)<10){
        min = '0'+setMin;
      }
      minController.text = min;
    });
  }
  void changeRange(start, end){
    setState(() {
      _endDate = end;
      _startDate = start;
      rangeController.text =_startDate.year.toString()+'.'+_startDate.month.toString()+'.'+_startDate.day.toString()+'~'+_endDate.year.toString()+'.'+_endDate.month.toString()+'.'+_endDate.day.toString();
    });
  }
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }
  Future<bool> getHotels() async {
    await hotels.get().then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc){
        hotelObjects.add(
            HotelObject(
              name:doc["name"]?? '',
            )
        );
      }
      )
    }
    );
    return true;
  }

  Future<bool> addAppointment(double amount, DateTime date, LatLng pos, int type, List<String> animals) async {
    bool _isAppointAdded = false;
    var app = await appointments.doc().set({'animals':animals, 'amount':amount,'date':date, 'latitude':pos.latitude,'longitude':pos.longitude, 'type':type}).then((value) => {
      _isAppointAdded = true
    }).catchError((onError) => {
      print(onError.toString()),
      _isAppointAdded = false
    });
    return _isAppointAdded;
  }

  void showPlacePicker() async {
    LocationResult? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyAkCwqzswCGfPAnfTFlB5p9OCKYsEGD6N8",
              // displayLocation: LatLng(_userLocation.latitude, _userLocation.longitude),
            )));

    // Handle the result in your way
  }
  void initRange(){
    setState(() {
      rangeController.text =_startDate.year.toString()+'.'+_startDate.month.toString()+'.'+_startDate.day.toString()+'~'+_endDate.year.toString()+'.'+_endDate.month.toString()+'.'+_endDate.day.toString();

    });
  }
  @override
  void  initState(){
    super.initState();
    initDate();
    _initLocationService();
    initRange();
  }
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
    Widget barSection = GestureDetector(
        onTap: (){
          _key.currentState!.openDrawer();
        },
        child: Container(
            margin:const EdgeInsets.only(top:20,left:10),
            alignment: Alignment.topLeft,
            child:Image.asset(
                'assets/images/eva_menu-fill.png')
        )
    );
    return
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home:  Container(
              color: Colors.white,
              child:Scaffold(
                  key: _key, // Assign the key to Scaffold.
                  drawer: Container(
                    width: MediaQuery.of(context).size.width*0.6,
                    child:const Drawer(
                      child:MainMenu(pageIndex: 3),
                    ),
                  ),
                  backgroundColor: const Color.fromRGBO(235, 235, 235, 1),
                  body:  Column(
                      children: [
                        Expanded(child: ListView(
                          children: [
                            barSection,
                            Column(
                              children: [
                                Container(
                                    margin:const EdgeInsets.only(left:15, top:15),
                                    alignment: Alignment.topLeft,
                                    child:const Text(
                                        'Create Appointment',
                                        style:TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Montserrat-SemiBold',
                                          fontSize: 24,
                                        )
                                    )
                                ),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async{
                                        // showPlacePicker();
                                        LatLng pickedLocation = await Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType.bottomToTop,
                                            child: LocationScreen(),
                                            isIos: true,
                                            duration: const Duration(milliseconds: 400),
                                          ),
                                        );
                                        updatePickPos(pickedLocation);
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                              padding:const EdgeInsets.only(left:20, top:10,bottom: 10),
                                              alignment: Alignment.center,
                                              child:
                                              const Text(
                                                  'Pick Up Location',
                                                  textAlign: TextAlign.center,
                                                  style:TextStyle(
                                                    fontFamily: 'Montserrat-Bold',
                                                    fontSize: 16,
                                                  )
                                              )
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(left:40, right:40, bottom: 20),
                                              width: MediaQuery.of(context).size.width*0.8,
                                              height: 180,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border:  Border.all(color: const Color.fromRGBO(158, 158, 158, 1), width: 5)
                                              ),
                                              child:
                                              _isPicked?
                                              GoogleMap(
                                                mapType: MapType.normal,
                                                markers: Set<Marker>.of(_markers),
                                                initialCameraPosition: _isPicked? CameraPosition(target: LatLng(_pickedLocation.latitude, _pickedLocation.longitude),zoom: 12):_kGooglePlex,
                                                onMapCreated: (GoogleMapController controller) {
                                                },
                                              )
                                              // :_userLocCatched?
                                              // GoogleMap(
                                              //   mapType: MapType.normal,
                                              //   markers: Set<Marker>.of(_markers),
                                              //   initialCameraPosition: _userLocCatched? CameraPosition(target: LatLng(_userLocation.latitude, _userLocation.longitude),zoom: 12):_kGooglePlex,
                                              //   onMapCreated: (GoogleMapController controller) {
                                              //     _controller.complete(controller);
                                              //   },
                                              // ):
                                                  :
                                              Container(

                                              )
                                          ),
                                        ],
                                      )
                                    ),
                                    Container(
                                      alignment: Alignment.topLeft,
                                      padding: const EdgeInsets.only(top:15,left:20, bottom: 15),
                                      child: const Text(
                                          'Appointment Date',
                                          style:TextStyle(
                                              fontFamily: 'Montserrat-SemiBold',
                                              fontSize: 16
                                          )),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width*0.2,
                                          child: ElevatedButton(
                                            style:ElevatedButton.styleFrom(
                                              backgroundColor: nowTime? const Color.fromRGBO(244,115,32,0.1):const Color.fromRGBO(244,115,32,1),
                                              textStyle: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6.0),
                                                side: const BorderSide(color: Color.fromRGBO(244,115,32,0.1)),
                                              ),
                                            ),
                                            onPressed: () {
                                              // If the form is valid, display a snackbar. In the real world,
                                              // you'd often call a server or save the information in a database.
                                              initDate();
                                            },
                                            child: Text('Now', style: TextStyle(fontSize: 16.0, fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.w700, color: nowTime? const Color.fromRGBO(244,115,32,1):Colors.white,)),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width*0.2,
                                          child: ElevatedButton(
                                            style:ElevatedButton.styleFrom(
                                              backgroundColor: nowTime? const Color.fromRGBO(244,115,32,1):const Color.fromRGBO(244,115,32,0.1),
                                              textStyle: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6.0),
                                                side: const BorderSide(color: Color.fromRGBO(244,115,32,1)),
                                              ),
                                            ),
                                            onPressed: () {
                                              // If the form is valid, display a snackbar. In the real world,
                                              // you'd often call a server or save the information in a database.
                                              laterDate();
                                            },
                                            child: Text('Later', style: TextStyle(fontSize: 16.0, fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.w700,color:!nowTime? const Color.fromRGBO(244,115,32,1):Colors.white)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top:20,left:20),
                                      alignment: Alignment.topLeft,
                                      child: const Text(
                                        'choose the date',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat-Bold',
                                          fontSize:14,
                                        ),
                                      ),
                                    ),
                                    // DropdownMenuItem(child: child),
                                    Container(
                                      padding:const EdgeInsets.only(top:20),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children:[
                                            Container(
                                              padding: const EdgeInsets.only(left:10, right: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color:const Color.fromRGBO(244,115,32,1),
                                                      width:2.0
                                                  )
                                              ),
                                              child: DropdownButton(
                                                underline: Container(
                                                  height: 1.0,
                                                  decoration: const BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: Color.fromRGBO(235, 235, 235, 1),
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                value: day,
                                                icon: Image.asset('assets/images/tri.png'),
                                                items: dayDropdownItems,
                                                elevation : 0,
                                                onChanged: !dayDisabled?(String? value) {
                                                  changeDay(value);
                                                }:null,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(left:10, right: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color:const Color.fromRGBO(244,115,32,1),
                                                      width:2.0
                                                  )
                                              ),
                                              child: DropdownButton(
                                                  underline: Container(
                                                    height: 1.0,
                                                    decoration: const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Color.fromRGBO(235, 235, 235, 1),
                                                          width: 0.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  value: month,
                                                  icon: Image.asset('assets/images/tri.png'),
                                                  items: dropdownItems,
                                                  elevation : 0,
                                                  onChanged: monthDisabled? null:(String? value) {
                                                    changeMonth(value);
                                                  }
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(left:10, right: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color:const Color.fromRGBO(244,115,32,1),
                                                      width: 2
                                                  )
                                              ),
                                              child: DropdownButton(
                                                underline: Container(
                                                  height: 1.0,
                                                  decoration: const BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: Color.fromRGBO(235, 235, 235, 1),
                                                        width: 0.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                                value: year,
                                                icon: Image.asset('assets/images/tri.png'),
                                                items: yearDropdownItems,
                                                elevation : 0,
                                                onChanged: !yearDisabled? (String? value) {
                                                  changeYear(value);
                                                }:null,
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top:20,left:20),
                                      alignment: Alignment.topLeft,
                                      child: const Text(
                                        'choose the time',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat-Bold',
                                          fontSize:14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding:const EdgeInsets.only(top:20, bottom: 20),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children:[
                                            Container(
                                                width:MediaQuery.of(context).size.width*0.2,
                                                padding: const EdgeInsets.only(left:10, right: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:BorderRadius.circular(10),
                                                    border: Border.all(
                                                        color:const Color.fromRGBO(244,115,32,1),
                                                        width:2.0
                                                    )
                                                ),
                                                child: TextField(
                                                  enabled: hourDisabled,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 15),
                                                  controller: hourController,
                                                  autocorrect: false,
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (val){
                                                    changeHour(val);
                                                  },
                                                )
                                            ),
                                            const Text(':', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),),
                                            Container(
                                                width:MediaQuery.of(context).size.width*0.2,
                                                padding: const EdgeInsets.only(left:10, right: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:BorderRadius.circular(10),
                                                    border: Border.all(
                                                        color:const Color.fromRGBO(244,115,32,1),
                                                        width:2.0
                                                    )
                                                ),
                                                child: TextField(
                                                  enabled: minDisabled,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 15),
                                                  controller: minController,
                                                  autocorrect: false,
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (val){
                                                    changemin(val);
                                                  },
                                                )
                                            ),
                                            Container(
                                              alignment:Alignment.center,
                                              width:MediaQuery.of(context).size.width*0.3,
                                              padding: const EdgeInsets.only(left:10, right: 10),
                                              decoration: BoxDecoration(
                                                  color:const Color.fromRGBO(244,115,32,1),
                                                  borderRadius:BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color:const Color.fromRGBO(244,115,32,1)
                                                  )
                                              ),
                                              child: DropdownButton(
                                                  underline: Container(
                                                    height: 1.0,
                                                    decoration: const BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Color.fromRGBO(244,115,32,1),
                                                          width: 0.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                  value: pm,
                                                  icon: Image.asset('assets/images/tri1.png'),
                                                  items: pmDropdownItems,
                                                  elevation : 0,
                                                  onChanged: !pmDisabled?(String? value) {
                                                    changePM(value);
                                                  }:null
                                              ),
                                            ),
                                          ]
                                      ),
                                    ),
                                    Container(
                                      width:MediaQuery.of(context).size.width*0.5,
                                      height: MediaQuery.of(context).size.height*0.06,
                                      margin: const EdgeInsets.only(top:10,bottom: 20),
                                      child:ElevatedButton(
                                        style:ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(244,115,32,1),
                                          textStyle: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6.0),
                                            side: const BorderSide(color: Color.fromRGBO(244,115,32,1)),
                                          ),
                                        ),
                                        onPressed: () async {
                                          amount = (widget.vetType!*widget.animlaLenth).toDouble();
                                          if(amount == 0){
                                            Fluttertoast.showToast(
                                              msg: "Amount is 0!",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.TOP_LEFT,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                          }
                                          else{
                                            var result = await addAppointment(amount, DateTime.parse('$year-$month-$day $realHour:$min:00'), _isPicked? _pickedLocation:LatLng(_userLocation.latitude, _userLocation.longitude), widget.appointType, widget.addedAnimals);
                                            if(result == true)
                                            {
                                              Fluttertoast.showToast(
                                                msg: "Appointment Registered!",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.TOP_LEFT,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                                                textColor: Colors.white,
                                                fontSize: 16.0,
                                              );
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType.bottomToTop,
                                                  child: CheckoutView( amount: amount,id:''),
                                                  isIos: true,
                                                  duration: Duration(milliseconds: 400),
                                                ),
                                              );
                                            }
                                            else{
                                              Fluttertoast.showToast(
                                                msg: "Regsiteration Failed!",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.TOP_LEFT,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                                                textColor: Colors.white,
                                                fontSize: 16.0,
                                              );
                                            }
                                          }
                                        },
                                        child: const Text('Submit', style: TextStyle(fontSize: 16.0, fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        )
                        ),
                      ]
                  )
              )
          )
      );
  }
}