import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'appoint_cont.dart';
import 'services/animalObject.dart';
import 'main_menu.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:page_transition/page_transition.dart';

class Appointment extends StatefulWidget{
  static const id = 'Appointment';
  final int appointType;
  const Appointment({
    Key? key,
    required this.appointType,
  }) : super(key: key);
  @override
  State<Appointment> createState() => _Appointment();
}

class _Appointment extends State<Appointment>{

  bool animalAdded = false;
  List<Widget> addedListAnimals = <Widget>[];

  CollectionReference animals = FirebaseFirestore.instance.collection('animals');
  List<AnimalObject> animalObjects = [];
  List<String> addedAnimals = [];
  int animlaLenth = 0;

  late int days = 0;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();

  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }
  List<DropdownMenuItem<int>> get vetTypeItems{
    List<DropdownMenuItem<int>> menuItems = [];
    menuItems.add(DropdownMenuItem(child:Text("Vet check up: 40SR"),value: 40),);
    menuItems.add(DropdownMenuItem(child:Text("Vet Vaccine: 50SR"),value: 50),);

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
  List<DropdownMenuItem<String>> get pmDropdownItems{
  List<DropdownMenuItem<String>> menuItems = [];
  menuItems.add (DropdownMenuItem(child: Text("pm   "),value: "pm"),);
  menuItems.add (DropdownMenuItem(child: Text("am   "),value: "am"),);
    return menuItems;
  }
  late int vetType= 40;

  TextEditingController rangeController = new TextEditingController();

  set dayDropdownItems (List<DropdownMenuItem<String>> tempMenuItems){
    dayDropdownItems = tempMenuItems;
  }

  Completer<GoogleMapController> _controller = Completer();

  Future<bool> getAnimals() async {
    await animals.get().then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc){
        animalObjects.add(
            AnimalObject(
                id:doc.id,
                name:doc["name"]?? '',
                age:doc["age"]?? '',
                weight:doc["weight"]?? '',
                breed:doc["breed"]?? '',
                imgUrl:doc["imgUrl"]?? '',
                isAdded: false
            )
        );
      }
      )
    }
    );
    setListAnimal();
    return true;
  }
  void setListAnimal(){
    animlaLenth = 0;
    List<Widget> addedWidgetTempAnimals = <Widget>[];
    List<String> addedTempAnimals = [];
    addedListAnimals.clear();
    addedAnimals.clear();
    animalObjects.forEach((element) {
      if(element.isAdded) {
        addedWidgetTempAnimals.add(
          Container(
            margin:const EdgeInsets.only(bottom: 20),
            child:  Stack(
              children: [
                Card(
                    margin: const EdgeInsets.only(top:40,left:20, right: 20),
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child:ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              elevation:0,
                            ),
                            onPressed: () {
                              setState(() {
                                element.isAdded = false;
                              });
                              setListAnimal();
                            }, child: const Text(
                            'Delete',
                            style:  TextStyle(
                                fontFamily: 'Montserrat-SemiBold',
                                fontSize: 14,
                                color: Color.fromRGBO(224, 115, 34, 1)
                            ),
                          ),
                          ),
                        ),
                        Container(
                            alignment:Alignment.center,
                            padding: const EdgeInsets.only(top:50, bottom: 20),
                            width:MediaQuery.of(context).size.width*0.8,
                            child:Text(
                              element.name,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Color.fromRGBO(224, 115, 34, 1),
                                  fontFamily: 'Montserrat-SemiBold'
                              ),
                            )
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:[
                              Column(
                                  children:[
                                    Container(
                                      padding: const EdgeInsets.only(top:10, bottom: 10),
                                      child: const Text(
                                          'Age',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color:Color.fromRGBO(224, 115, 34, 1),
                                              fontFamily: 'Montserrat-SemiBold'
                                          )
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child:
                                        Text(
                                            element.age,
                                            style:const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Montserrat-Medium',
                                            )
                                        )
                                    ),
                                  ]
                              ),
                              Column(
                                  children:[
                                    Container(
                                      padding: const EdgeInsets.only(top:10, bottom: 10),
                                      child: const Text(
                                          'Weight',
                                          style:TextStyle(
                                              fontSize: 16,
                                              color:Color.fromRGBO(224, 115, 34, 1),
                                              fontFamily: 'Montserrat-SemiBold'
                                          )
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child:
                                        Text(
                                            '${element.weight} kg',
                                            style:const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Montserrat-Medium',
                                            )
                                        )
                                    ),
                                  ]
                              ),
                              Column(
                                  children:[
                                    Container(
                                      padding: const EdgeInsets.only(top:10, bottom: 10),
                                      child: const Text(
                                          'Breed',
                                          style:TextStyle(
                                              fontSize: 16,
                                              color:Color.fromRGBO(224, 115, 34, 1),
                                              fontFamily: 'Montserrat-SemiBold'
                                          )
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child:
                                        Text(
                                            element.breed,
                                            style:const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Montserrat-Medium',
                                            )
                                        )
                                    ),
                                  ]
                              )
                            ]
                        )
                      ],
                    )
                ),
                Container(
                    alignment: Alignment.center,
                    child: Image.network(element.imgUrl
                    )
                )
              ],
            ),
          ),
        );
        addedTempAnimals.add(element.id);
        animlaLenth++;
      }
    });
    setState(() {
      addedListAnimals = addedWidgetTempAnimals;
      addedAnimals = addedTempAnimals;
      animalAdded = true;
    });
  }
  void changeRange(start, end){
    setState(() {
      _endDate = end;
      _startDate = start;
      rangeController.text =_startDate.year.toString()+'.'+_startDate.month.toString()+'.'+_startDate.day.toString()+'~'+_endDate.year.toString()+'.'+_endDate.month.toString()+'.'+_endDate.day.toString();
    });
  }

  @override
  void  initState(){
    super.initState();
    getAnimals();
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
    Widget continueSection = Center(
        child:Align(
          alignment: Alignment.bottomCenter,
          child: Column(
              children: <Widget>[
                Container(
                  width:MediaQuery.of(context).size.width*0.5,
                  height: MediaQuery.of(context).size.height*0.06,
                  margin: const EdgeInsets.only(top:10, bottom: 20),
                  child:ElevatedButton(
                    style:ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(244,115,32,1),
                      textStyle: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: const BorderSide(color: Color.fromRGBO(244,115,32,1)),
                      ),
                    ),
                    onPressed: () {
                      if(widget.appointType ==1) {
                        if (animlaLenth == 0) {
                          Fluttertoast.showToast(
                            msg: "You must select animals",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP_LEFT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: const Color.fromRGBO(
                                50, 50, 50, 1),
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                        else {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: AppointmentCont(
                                  appointType: widget.appointType,
                                  addedAnimals: addedAnimals,
                                  animlaLenth: animlaLenth,
                                  vetType: vetType,
                                  days: days
                              ),
                              isIos: true,
                              duration: const Duration(milliseconds: 400),
                            ),
                          );
                        }
                      }
                      else if(widget.appointType ==3){
                        if(days == 0){
                          Fluttertoast.showToast(
                            msg: "You must select days",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP_LEFT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: const Color.fromRGBO(
                                50, 50, 50, 1),
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                        else {
                          // If the form is valid, display a snackbar. In the real world,
                          // you'd often call a server or save the information in a database.
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: AppointmentCont(
                                  appointType: widget.appointType,
                                  addedAnimals: addedAnimals,
                                  animlaLenth: animlaLenth,
                                  vetType: vetType,
                                  days: days
                              ),
                              isIos: true,
                              duration: const Duration(milliseconds: 400),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Continue', style: TextStyle(fontSize: 16.0, fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.w700)),
                  ),
                ),
              ]
          ),
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
                                margin:const EdgeInsets.only(left:25, top:10),
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
                            Container(
                                margin:const EdgeInsets.only(left:25, top:30, bottom: 10),
                                alignment: Alignment.topLeft,
                                child:const Text(
                                    'Select Animal Profiles',
                                    style:TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Montserrat-SemiBold',
                                      fontSize: 20,
                                    )
                                )
                            ),
                            Column(
                              children: [
                                animalAdded?
                                Column(
                                  children: addedListAnimals,
                                ):Container(
                                  margin: const EdgeInsets.only(top:20),
                                ),
                              GestureDetector(
                              onTap: () {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          List<Widget> listAnimals = <Widget>[];
                                          animalObjects.forEach((element) {
                                            if(!element.isAdded) {
                                              listAnimals.add(
                                                Container(
                                                  margin:const EdgeInsets.only(bottom: 20),
                                                  child:  Stack(
                                                    children: [
                                                      Card(
                                                          margin: const EdgeInsets.only(top:40,left:20, right: 20),
                                                          color: Colors.white,
                                                          elevation: 8,
                                                          shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                              color: Colors.grey.shade300,
                                                            ),
                                                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                alignment: Alignment.topRight,
                                                                child:ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    primary: Colors.white,
                                                                    elevation:0,
                                                                  ),
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      element.isAdded = true;
                                                                    });
                                                                  }, child: const Text(
                                                                    'Add',
                                                                    style:  TextStyle(
                                                                      fontFamily: 'Montserrat-SemiBold',
                                                                      fontSize: 14,
                                                                      color: Color.fromRGBO(224, 115, 34, 1)
                                                                    ),
                                                                ),
                                                                ),
                                                              ),
                                                              Container(
                                                                  alignment:Alignment.center,
                                                                  padding: const EdgeInsets.only(top:25, bottom: 20),
                                                                  width:MediaQuery.of(context).size.width*0.8,
                                                                  child:Text(
                                                                    element.name,
                                                                    style: const TextStyle(
                                                                        fontSize: 18,
                                                                        color: Color.fromRGBO(224, 115, 34, 1),
                                                                        fontFamily: 'Montserrat-SemiBold'
                                                                    ),
                                                                  )
                                                              ),
                                                              Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                  children:[
                                                                    Column(
                                                                        children:[
                                                                          Container(
                                                                            padding: const EdgeInsets.only(top:10, bottom: 10),
                                                                            child: const Text(
                                                                                'Age',
                                                                                style: TextStyle(
                                                                                    fontSize: 16,
                                                                                    color:Color.fromRGBO(224, 115, 34, 1),
                                                                                    fontFamily: 'Montserrat-SemiBold'
                                                                                )
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              padding: const EdgeInsets.only(bottom: 10),
                                                                              child:
                                                                              Text(
                                                                                  element.age,
                                                                                  style:const TextStyle(
                                                                                    fontSize: 12,
                                                                                    fontFamily: 'Montserrat-Medium',
                                                                                  )
                                                                              )
                                                                          ),
                                                                        ]
                                                                    ),
                                                                    Column(
                                                                        children:[
                                                                          Container(
                                                                            padding: const EdgeInsets.only(top:10, bottom: 10),
                                                                            child: const Text(
                                                                                'Weight',
                                                                                style:TextStyle(
                                                                                    fontSize: 16,
                                                                                    color:Color.fromRGBO(224, 115, 34, 1),
                                                                                    fontFamily: 'Montserrat-SemiBold'
                                                                                )
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              padding: const EdgeInsets.only(bottom: 10),
                                                                              child:
                                                                              Text(
                                                                                  '${element.weight} kg',
                                                                                  style:const TextStyle(
                                                                                    fontSize: 12,
                                                                                    fontFamily: 'Montserrat-Medium',
                                                                                  )
                                                                              )
                                                                          ),
                                                                        ]
                                                                    ),
                                                                    Column(
                                                                        children:[
                                                                          Container(
                                                                            padding: const EdgeInsets.only(top:10, bottom: 10),
                                                                            child: const Text(
                                                                                'Breed',
                                                                                style:TextStyle(
                                                                                    fontSize: 16,
                                                                                    color:Color.fromRGBO(224, 115, 34, 1),
                                                                                    fontFamily: 'Montserrat-SemiBold'
                                                                                )
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                              padding: const EdgeInsets.only(bottom: 10),
                                                                              child:
                                                                              Text(
                                                                                  element.breed,
                                                                                  style:const TextStyle(
                                                                                    fontSize: 12,
                                                                                    fontFamily: 'Montserrat-Medium',
                                                                                  )
                                                                              )
                                                                          ),
                                                                        ]
                                                                    )

                                                                  ]
                                                              )
                                                            ],
                                                          )
                                                      ),
                                                      Container(
                                                          alignment: Alignment.center,
                                                          child: Image.network(element.imgUrl
                                                          )
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                          return AlertDialog(
                                            alignment: Alignment.topCenter,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(32.0))),
                                            content: SizedBox(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.95,
                                                // width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Container(
                                                        alignment: Alignment
                                                            .center,
                                                        padding: const EdgeInsets
                                                            .only(
                                                            bottom: 20),
                                                        child: const Text(
                                                          'Select Animals',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontFamily: 'Montserrat-SemiBold',
                                                              fontWeight: FontWeight
                                                                  .w600
                                                          ),
                                                        )
                                                    ),
                                                    Expanded(
                                                        child: ListView(
                                                          children: listAnimals,
                                                        )
                                                    )
                                                  ],
                                                )
                                            ),
                                            actions: <Widget>[
                                              Container(
                                                width: double.infinity,
                                                alignment: Alignment.center,
                                                margin: const EdgeInsets.only(
                                                    bottom: 20),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(
                                                        15),
                                                    color: Color.fromRGBO(
                                                        52, 202, 52, 1)
                                                ),
                                                child: TextButton(
                                                  onPressed: () =>
                                                  {
                                                    setListAnimal(),
                                                    Navigator.pop(
                                                        context, 'OK'),
                                                  },
                                                  child: const Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontFamily: 'Montserrat-Bold'
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    }
                                );
                              },
                              child:Container(
                                child: Image.asset('assets/images/plus.png'),
                              ),
                            ),
                            // DropdownMenuItem(child: child),
                              Container(
                                margin:const EdgeInsets.only(top:20),
                                child: widget.appointType == 1?
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left:25, right: 20, top:25),
                                      alignment: Alignment.topLeft,
                                      child: const Text(
                                        'Vet Type',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat-Bold',
                                          fontSize:20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left:30,top:10, bottom: 20),
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
                                          value: vetType,
                                          icon: Image.asset('assets/images/tri.png'),
                                          items: vetTypeItems,
                                          elevation : 0,
                                          onChanged: (int? value) {
                                            setState(() {
                                              vetType = value!;
                                            });
                                          }
                                      ),
                                    )
                                  ],
                                ):widget.appointType == 3?
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left:25, right: 20, top:25),
                                      alignment: Alignment.topLeft,
                                      child: const Text(
                                        'Duration',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat-Bold',
                                          fontSize:20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(top:10, bottom: 20),
                                        padding: const EdgeInsets.only(left:10, right: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:BorderRadius.circular(10),
                                            border: Border.all(
                                                color:const Color.fromRGBO(244,115,32,1),
                                                width: 2
                                            )
                                        ),
                                        child: GestureDetector(
                                            onTap:() {
                                              showCustomDateRangePicker(
                                                context,
                                                dismissible: true,
                                                minimumDate: DateTime.now().subtract(const Duration(days: 30)),
                                                maximumDate: DateTime.now().add(const Duration(days: 30)),
                                                onApplyClick: (start, end) {
                                                  changeRange(start, end);
                                                },
                                                onCancelClick: () {
                                                },
                                              );
                                            },
                                            child:
                                            Container(
                                                width: 180,
                                                child: TextField(
                                                  enabled: false,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 15),
                                                  controller: rangeController,
                                                  autocorrect: false,
                                                  keyboardType: TextInputType.number,
                                                  onChanged: (val){
                                                  },
                                                )
                                            )
                                        )
                                    )
                                  ],
                                ):Container(),
                              ),

                          ],
                        )
                      ],
                    )
                  ],
                ),
            ),
            continueSection
            ]
          )
      )
    )
    );
  }
}