import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:validators/validators.dart';
import 'tools/firebase_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:location/location.dart';

class SignUp extends StatefulWidget{
  final String phoneNumber;
  final String partNumber;
  final String countryCode;
  const SignUp({
    Key? key,
    required this.phoneNumber,
    required this.partNumber,
    required this.countryCode,
  }) : super(key: key);

  @override
  State<SignUp> createState() => _SignUp();
}

class _SignUp extends State<SignUp>{
  late String phoneNumber = widget.phoneNumber;
  late String name ;
  late final SharedPreferences prefs;
  Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final _formKey = GlobalKey<FormState>();
  CollectionReference  users = FirebaseFirestore.instance.collection('users');
  String email = '';
  FirebaseService service = FirebaseService();

  //---------get user's location information------
  var _userLocation;
  late Marker _userMarker;
  List<Marker> _markers = <Marker>[];
  bool _userLocCatched = false;
  Future<bool> setUserData(String name, String email,String phoneNumber, LatLng pos) async {
    bool _isUserAdded = false;
    var prefs = await SharedPreferences.getInstance();
    var uid = await prefs.getString('uid');
    var user = await users.doc(uid).set({'name':name,'email':email, 'phoneNumber':phoneNumber,'latitude':pos.latitude,'longitude':pos.longitude}).then((value) => {
      _isUserAdded = true
    }).catchError((onError) => {
      _isUserAdded = false
    });
    return _isUserAdded;
  }
  void updatePos(Marker marker){
    setState(() {
      _markers.add(_userMarker);
      _userLocCatched = true;
    });
  }
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
        infoWindow: const InfoWindow(
            title: 'The title of the marker'
        )
    );
    updatePos(_userMarker);
    print("${_userLocation.latitude} ${_userLocation.longitude}");
    return true;
  }

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }
  @override
  Widget build(BuildContext context) {
    Widget headerSection = Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: const Text(
        'Sign Up',
        textAlign: TextAlign.left,
        style: TextStyle(
            color:Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat-SemiBold'
        ),
      ),
    );
    Widget positionSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children :[
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: const Text(
            ' Your Position',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Color.fromRGBO(244,115,32,1),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat-SemiBold'
            ),
          ),
        ),
      ],
      //-----position-------
    );
    Widget continueSection = Container(
        color: Colors.transparent,
        child:Align(
          alignment: Alignment.bottomCenter,
          child: Column(
              children: <Widget>[
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
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        // insertUserInfo(name,email,phoneNumber);
                        var _isAdded = await setUserData(name, email, phoneNumber,LatLng(_userLocation.latitude, _userLocation.longitude));
                        if(_isAdded){
                          Fluttertoast.showToast(
                            msg: "Sign Up Success!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP_LEFT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/Home', (route)=> false
                          );
                          // Navigator.push(
                          //   context,
                          //   PageTransition(
                          //     type: PageTransitionType.bottomToTop,
                          //     child: const HomeScreen(),
                          //     isIos: true,
                          //     duration: Duration(milliseconds: 400),
                          //   ),
                          // );
                        }else{
                          Fluttertoast.showToast(
                            msg: "Sign Up Failed! Please try again later.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP_LEFT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      }},
                    child: const Text('Sign Up', style: TextStyle(fontSize: 16.0, fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.w700)),
                  ),
                ),
              ]
          ),
        )
    );
    Widget formSection =  Form(
        key:_formKey,
        child:
        Container(
          padding: const EdgeInsets.only(top:22,left:25,right:25),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                      headerSection,
                      //-------Name------
                      Container(
                        padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.02, bottom: 12),
                        child: const Text(
                          ' Name',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Color.fromRGBO(244,115,32,1),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat-Medium'
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin:const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left:10),
                            hintStyle: const TextStyle(fontSize: 15, fontFamily: 'Montserrat-Medium', color:Color.fromRGBO(158, 158, 158, 1)),
                            hintText: 'Enter your Name',
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius:BorderRadius.circular(15.0)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:  BorderSide(color: Colors.green,),
                              borderRadius:BorderRadius.circular(15.0),
                            ),
                          ),
                          autocorrect: false,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if ( value?.isEmpty?? true) {
                              return 'Name Required';
                            }
                            return null;
                          },
                          onChanged: (text){
                            name = text;
                          },
                        ),
                      ),
                      //-----Email-------
                      Container(
                        padding:EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02,bottom: 5),
                        child: const Text(
                          'Email Address',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Color.fromRGBO(244,115,32,1),
                              fontSize: 15,
                              fontFamily: 'Montserrat-SemiBold'
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin:const EdgeInsets.only(bottom: 5),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintStyle: const TextStyle(fontSize: 15, fontFamily: 'Montserrat-Medium', color:Color.fromRGBO(158, 158, 158, 1)),
                            contentPadding: const EdgeInsets.only(left:10),
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey),
                                borderRadius:BorderRadius.circular(15.0)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:  const BorderSide(color: Colors.green,
                              ),
                              borderRadius:BorderRadius.circular(15.0),
                            ),
                          ),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if ( value?.isEmpty?? true) {
                              return 'Email Required';
                            }
                            if(!isEmail(value!))
                            {
                              return 'Invalid Email';
                            }
                            return null;
                          },
                          onChanged:(text){
                            setState((){
                              email = text;
                            });
                          },
                        ),
                      ),
                      //-----Phone Number-------
                      Container(
                        padding:EdgeInsets.only(top: MediaQuery.of(context).size.height*0.02,bottom: 5),
                        child: const Text(
                          'Phone Number',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color:Color.fromRGBO(244,115,32,1),
                              fontSize: 15,
                              fontFamily: 'Montserrat-SemiBold'
                          ),
                        ),
                      ),
                      IntlPhoneField(
                        initialValue: widget.partNumber,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide(),
                            ),
                          ),
                        initialCountryCode: 'SA',
                        onChanged: (phone) {
                          phoneNumber = phone.completeNumber;
                        },
                      ),
                      positionSection
                    ],
                  ),
                ),
    );
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:  Container(
          color: Colors.white,
          child:Scaffold(
              backgroundColor: Colors.transparent,
              body:  Column(
                children: [
                  Expanded(
                      child:ListView(
                        children:[
                          formSection,
                          Container(
                            margin: const EdgeInsets.only(left:40, right:40),
                            width: MediaQuery.of(context).size.width*0.8,
                            height: 180,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:  Border.all(color: const Color.fromRGBO(158, 158, 158, 1))
                            ),
                            child:
                            _userLocCatched?
                            GoogleMap(
                              mapType: MapType.normal,
                              markers: Set<Marker>.of(_markers),
                              initialCameraPosition: _userLocCatched? CameraPosition(target: LatLng(_userLocation.latitude, _userLocation.longitude),zoom: 12):_kGooglePlex,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                            ):Container()
                          ),
                        ],
                      )
                  ),
                  continueSection
                ],
              )
          )
        )
        );

  }
}