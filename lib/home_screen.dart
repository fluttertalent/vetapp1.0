import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vetapp/appoint.dart';
import 'main_menu.dart';
import 'services/animalObject.dart';

class HomeScreen extends StatefulWidget{
  static const id = 'HomeScreen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>{

  bool _homeOpend = true;
  bool _profileOpend = false;
  bool animalAdded = false;
  List<Widget> listAnimals = <Widget>[];

  CollectionReference  animals = FirebaseFirestore.instance.collection('animals');
  List<AnimalObject> animalObjects = [];

  void setAnimals (){
    setState(() {
      animalAdded = true;
    });
  }
  Future<bool> getAnimals() async {
     await animals.get().then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc){
            animalObjects.add(
              AnimalObject(
                name:doc["name"]?? '',
                age:doc["age"]?? '',
                weight:doc["weight"]?? '',
                breed:doc["breed"]?? '',
                imgUrl:doc["imgUrl"]?? ''
              )
          );
         }
        )
      }
      );
     List<Widget> tempAnimals = <Widget>[];
     animalObjects.forEach((element) {
       tempAnimals.add(
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
     });
     setState(() {
       animalAdded = true;
       listAnimals = tempAnimals;
     });
     return true;
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
    Widget menuSection = Container(
      margin: const EdgeInsets.only(top:10, bottom: 10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: (){
                setState(() {
                  _homeOpend = true;
                  _profileOpend = false;
                });
              },
              child: Column(
                children: [
                  Container(
                    child: Text(
                      'Home',
                      style: _homeOpend? const TextStyle(
                          fontFamily: 'Montserrat-SemiBold',
                          fontSize: 22,
                          color: Color.fromRGBO(244, 115, 34, 1)
                      ):const TextStyle(
                          fontFamily: 'Montserrat-SemiBold',
                          fontSize: 15,
                          color: Color.fromRGBO(158, 158, 158, 1)
                      ),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width*0.25,
                      margin: const EdgeInsets.only(top:5),
                      height: _homeOpend? 4:2,
                      color: _homeOpend? const Color.fromRGBO(224, 115, 34, 1):const Color.fromRGBO(158, 158, 158, 1)
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  _profileOpend = true;
                  _homeOpend = false;

                });
              },
              child: Column(
                children: [
                  Container(
                    child: Text(
                      'Animal profiles',
                      style: TextStyle(
                          fontFamily: 'Montserrat-SemiBold',
                          fontSize: _profileOpend? 22:15,
                          color: _profileOpend? const Color.fromRGBO(224, 115, 34, 1): const Color.fromRGBO(158, 158, 158, 1)
                      ),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width*0.3,
                      margin: const EdgeInsets.only(top:5),
                      height: _profileOpend? 4:2,
                      color: _profileOpend? const Color.fromRGBO(224, 115, 34, 1): const Color.fromRGBO(158, 158, 158, 1)
                  ),
                ],
              ),
            ),
          ]
      ),
    );
    Widget mainSection = Column(
      children: [
        Card(
            margin: const EdgeInsets.only(top:20,left:20, right: 20),
            elevation: 8,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Appointment(appointType: 1)),
                  );
                },
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          duration: Duration(milliseconds: 500),
                          child: const Appointment(appointType: 1,),
                          inheritTheme: true,
                          ctx: context),
                    );
                  },
                  child:Container(
                    padding:const EdgeInsets.only(bottom:20),
                    child: Column(
                        children:[
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              width: double.infinity,
                              child:ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                  child: Image.asset('assets/images/pet.png',
                                      fit:BoxFit.fill
                                  )
                              )
                          ),
                          Container(
                              alignment: Alignment.topLeft,
                              padding:const EdgeInsets.only(left:5, top:10),
                              child:const Text(
                                'Get -20% on Ben\'s Vet',
                                style: TextStyle(
                                    color: Color.fromRGBO(31, 31, 31, 1),
                                    fontSize: 16,
                                    fontFamily: 'Montserrat-Bold',
                                    fontWeight: FontWeight.w600
                                ),
                              )
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(left:10, top:5),
                            child: const Text(
                              'Offer',
                              style: TextStyle(
                                  fontFamily: 'Montserrat-SemiBold',
                                  fontSize: 14,
                                  color:Color.fromRGBO(224, 115, 34, 1)
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(right:10, top:5),
                            child: const Text(
                              'Learn more',
                              style: TextStyle(
                                  fontFamily: 'Montserrat-Bold',
                                  fontSize: 14,
                                  color:Color.fromRGBO(224, 115, 34, 1)
                              ),
                            ),
                          )
                        ]
                    ),
                  ),
                )
            )
        ),
        Card(
            margin: const EdgeInsets.only(top:20,left:20, right: 20),
            elevation: 8,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: Duration(milliseconds: 500),
                      child: const Appointment(appointType: 2,),
                      inheritTheme: true,
                      ctx: context),
                );
              },
              child: Container(
                padding:const EdgeInsets.only(bottom:20),
                child: Column(
                    children:[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          width: double.infinity,
                          child:ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              child: Image.asset('assets/images/pet.png',
                                  fit:BoxFit.fill
                              )
                          )
                      ),
                      Container(
                          alignment: Alignment.center,
                          padding:const EdgeInsets.only(left:5, top:25),
                          child:const Text(
                            'we will visit you ASAP  to check your pet',
                            style: TextStyle(
                                color: Color.fromRGBO(31, 31, 31, 1),
                                fontSize: 16,
                                fontFamily: 'Montserrat-SemiBold',
                                fontWeight: FontWeight.w600
                            ),
                          )
                      ),

                    ]
                ),
              ),
            )
        ),
        Card(
            margin: const EdgeInsets.only(top:20,left:20, right: 20),
            elevation: 8,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: Duration(milliseconds: 500),
                      child: const Appointment(appointType: 3,),
                      inheritTheme: true,
                      ctx: context),
                );
              },
              child: Container(
                padding:const EdgeInsets.only(bottom:20),
                child: Column(
                    children:[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          width: double.infinity,
                          child:ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              child: Image.asset('assets/images/pet.png',
                                  fit:BoxFit.fill
                              )
                          )
                      ),
                      Container(
                          alignment: Alignment.topLeft,
                          padding:const EdgeInsets.only(left:5, top:10),
                          child:const Text(
                            'Pet Hotel',
                            style: TextStyle(
                                color: Color.fromRGBO(31, 31, 31, 1),
                                fontSize: 16,
                                fontFamily: 'Montserrat-SemiBold',
                                fontWeight: FontWeight.w600
                            ),
                          )
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left:10, top:5),
                        child: const Text(
                          'Do you need  a place for your vet?',
                          style: TextStyle(
                              fontFamily: 'Montserrat-Bold',
                              fontSize: 16,
                              color:Color.fromRGBO(31, 31, 31, 1)
                          ),
                        ),
                      ),
                    ]
                ),
              ),
            )
        ),
        Card(
            margin: const EdgeInsets.only(top:20,left:20, right: 20),
            elevation: 8,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      duration: Duration(milliseconds: 500),
                      child: const Appointment(appointType: 4,),
                      inheritTheme: true,
                      ctx: context),
                );
              },
                child:Container(
                  padding:const EdgeInsets.only(bottom:20),
                  child: Column(
                      children:[
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)
                            ),
                            width: double.infinity,
                            child:ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                                child: Image.asset('assets/images/pet.png',
                                    fit:BoxFit.fill
                                )
                            )
                        ),
                        Container(
                            alignment: Alignment.topLeft,
                            padding:const EdgeInsets.only(left:5, top:10),
                            child:const Text(
                              'Do you need a shower for your vet?',
                              style: TextStyle(
                                  color: Color.fromRGBO(31, 31, 31, 1),
                                  fontSize: 16,
                                  fontFamily: 'Montserrat-Bold',
                                  fontWeight: FontWeight.w600
                              ),
                            )
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.only(left:10, top:5),
                          child: const Text(
                            'Offer',
                            style: TextStyle(
                                fontFamily: 'Montserrat-SemiBold',
                                fontSize: 14,
                                color:Color.fromRGBO(224, 115, 34, 1)
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.only(right:10, top:5),
                          child: const Text(
                            'Learn more',
                            style: TextStyle(
                                fontFamily: 'Montserrat-Bold',
                                fontSize: 14,
                                color:Color.fromRGBO(224, 115, 34, 1)
                            ),
                          ),
                        )
                      ]
                  ),
                ),
              )
        ),
        Card(
            margin: const EdgeInsets.only(top:20,left:20, right: 20),
            elevation: 8,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => RideDetail()),
                // );
              },
              child: Container(
                padding:const EdgeInsets.only(bottom:20),
                child: Column(
                    children:[
                      Container(

                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          width: double.infinity,
                          child:ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              child: Image.asset('assets/images/pet.png',
                                  fit:BoxFit.fill
                              )
                          )
                      ),
                      Container(
                          alignment: Alignment.topLeft,
                          padding:const EdgeInsets.only(left:5, top:10),
                          child:const Text(
                            'Do you need consultation for your vet?',
                            style: TextStyle(
                                color: Color.fromRGBO(31, 31, 31, 1),
                                fontSize: 16,
                                fontFamily: 'Montserrat-Bold',
                                fontWeight: FontWeight.w600
                            ),
                          )
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.only(left:10, top:5),
                        child: const Text(
                          'Offer',
                          style: TextStyle(
                              fontFamily: 'Montserrat-SemiBold',
                              fontSize: 14,
                              color:Color.fromRGBO(224, 115, 34, 1)
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.only(right:10, top:5),
                        child: const Text(
                          'Learn more',
                          style: TextStyle(
                              fontFamily: 'Montserrat-Bold',
                              fontSize: 14,
                              color:Color.fromRGBO(224, 115, 34, 1)
                          ),
                        ),
                      )
                    ]
                ),
              ),
            )
        ),
        Card(
            margin: const EdgeInsets.only(top:20,left:20, right: 20),
            elevation: 8,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => RideDetail()),
                // );
              },
              child: Container(
                padding:const EdgeInsets.only(bottom:20),
                child: Column(
                    children:[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)
                          ),
                          width: double.infinity,
                          child:ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              child: Image.asset('assets/images/pet.png',
                                  fit:BoxFit.fill
                              )
                          )
                      ),
                      Container(
                          alignment: Alignment.topLeft,
                          padding:const EdgeInsets.only(left:5, top:10),
                          child:const Text(
                            'Resources',
                            style: TextStyle(
                                color: Color.fromRGBO(31, 31, 31, 1),
                                fontSize: 16,
                                fontFamily: 'Montserrat-Bold',
                                fontWeight: FontWeight.w600
                            ),
                          )
                      ),
                    ]
                ),
              ),
            )
        )
      ]
    );
    Widget profileSection = Column(
        children: [
         Container(
           margin:const EdgeInsets.only(left:15, top:30),
           alignment: Alignment.topLeft,
           child:const Text(
             'Animal Profiles',
             style:TextStyle(
               color: Colors.black,
               fontFamily: 'Montserrat-SemiBold',
               fontSize: 16,
             )
           )
         ),
         animalAdded?
         Column(
           children: listAnimals,
         ):Container()
        ],
    );
    return
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home:  Container(
            color: Colors.white,
            child:Scaffold(
                key: _key,
                drawer: Container(
                  color:Colors.brown,
                  width:MediaQuery.of(context).size.width*0.6,
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
                        menuSection,
                        _profileOpend?
                        Column(
                          children: [
                            Container(
                                margin:const EdgeInsets.only(left:15, top:30),
                                alignment: Alignment.topLeft,
                                child:const Text(
                                    'Animal Profiles',
                                    style:TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Montserrat-SemiBold',
                                      fontSize: 16,
                                    )
                                )
                            ),
                            animalAdded?
                            Column(
                              children: listAnimals,
                            ):Container()
                          ],
                        ):
                        mainSection
                      ],
                    )),

                  ],
                )
            ),
          )

      );
  }
}