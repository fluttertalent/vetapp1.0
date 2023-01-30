import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vetapp/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const SignIn(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class MainMenu extends StatefulWidget{

  final pageIndex;
  const MainMenu({Key? key,this.pageIndex}) : super(key: key);

  State<MainMenu> createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {

  @override
  void initState() {

  }
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown,
      child: Column(
        children: [
          Container(
            height: 212,
            child: Padding(
              padding: EdgeInsets.only(top:50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child:Container(
                        padding: const EdgeInsets.only(left: 20),
                        child: Image.asset('assets/images/menuLogo.png'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(left:30, right: 16, bottom: 20),
            padding: const EdgeInsets.only(bottom: 12),
            decoration: (widget.pageIndex == 0)
                ?BoxDecoration(
                color:const Color.fromRGBO(229, 249, 224, 1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color:const Color.fromRGBO(229, 249, 224, 1),)
            )
                :BoxDecoration(),
            child:  ListTile(
              onTap: () async{
                print("ttooo");
                dynamic result = FirebaseAuth.instance.signOut();
                if(result == null){
                  print('error signing out');
                }else{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('loogged', false);
                  print('signed out');
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) =>
                              SignIn()),
                          (_createRoute) => true);
                }
              },
              leading:  Image.asset('assets/images/logout.png'),
              title:Text(
                "Log Out",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat-SemiBold',
                    color:(widget.pageIndex != 0)?
                     Colors.white
                        : Colors.black
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(left:30, right: 16, bottom: 20),
            padding: const EdgeInsets.only(bottom: 12),
            decoration: (widget.pageIndex == 1)
                ?BoxDecoration(
                color:const Color.fromRGBO(229, 249, 224, 1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color:const Color.fromRGBO(229, 249, 224, 1),)
            )
                :const BoxDecoration(),
            child:ListTile(
              selectedColor: const Color.fromRGBO(229, 249, 224, 1),
              focusColor: const Color.fromRGBO(229, 249, 224, 1),
              onTap: (){

              },
              leading: SizedBox(
                child: Image.asset(
                    'assets/images/lang.png',
                ),
              ),
              title:Text(
                "Laguage",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat-SemiBold',
                    color:(widget.pageIndex != 1)?
                    Colors.white
                        : Colors.black
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            margin: const EdgeInsets.only(left:30, right: 16),
            padding: const EdgeInsets.only(bottom: 12),
            decoration: (widget.pageIndex == 2)
                ?BoxDecoration(
                color:const Color.fromRGBO(229, 249, 224, 1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color:const Color.fromRGBO(229, 249, 224, 1),)
            )
                :BoxDecoration(),
            child: ListTile(
              selectedColor: const Color.fromRGBO(229, 249, 224, 1),
              focusColor: const Color.fromRGBO(229, 249, 224, 1),
              onTap: (){

              },
              leading: Container(
                child: Image.asset('assets/images/profile.png'),
              ),
              title:Text(
                "Profile",
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat-SemiBold',
                    color:(widget.pageIndex != 2)?
                    Colors.white
                        : Colors.black
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}