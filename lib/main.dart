import 'package:flutter/material.dart';
import 'package:vetapp/home_screen.dart';
import 'package:vetapp/sign_up.dart';
import 'package:vetapp/tools/verification.dart';
import 'verification.dart';
import 'tools/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

late final SharedPreferences prefs;

bool isPhoneNumber(String value) {
  String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = new RegExp(patttern);
  if (value.isEmpty) {
    return false;
  }
  else if (!regExp.hasMatch(value)) {
    return false;
  }
  return true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  prefs = await SharedPreferences.getInstance();
  runApp(const FirebasePhoneAuthProvider(
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home:MyApp())
    )
  );
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: prefs.getBool('loggedin') != true
          ? '/SignIn':'/Home',
          // initialRoute: '/' ,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color.fromARGB(255, 255, 35, 35),
          ),
          fontFamily: 'Roboto',
          ),
          routes: {
            '/SignIn': (context) => const SignIn(),
            '/Verification': (context) => VerificationScreen(phoneNumber: ''),
            '/SingUp': (context) => SignUp(phoneNumber: '', partNumber: '', countryCode: '',),
            '/Home': (context) => HomeScreen(),
          },
        );
  }
}

class SignIn extends StatefulWidget{
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignIn();
}

class _SignIn extends State<SignIn>{

  final _formKey = GlobalKey<FormState>();
  late String phoneNumber, verificationId;
  late String countryCode, partNumber;
  bool textChanged = false;
  late String otp, authStatus = "";
  late final SharedPreferences prefs;

  String email = '';
  FirebaseService service = FirebaseService();
  @override
  Widget build(BuildContext context) {
    Widget headerSection = Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: const Text(
        'Sign In',
        textAlign: TextAlign.left,
        style: TextStyle(
            color:Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat-SemiBold'
        ),
      ),
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
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                if (textChanged) {
                  if (isPhoneNumber(phoneNumber)) {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: VerifyPhoneNumberScreen(
                          phoneNumber: phoneNumber,
                          countryCode: countryCode,
                          partNumber: partNumber,
                        ),
                        isIos: true,
                        duration: Duration(milliseconds: 400),
                      ),
                    );
                  }
                }
              },
              child: const Text('Sign In', style: TextStyle(fontSize: 16.0, fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.w700)),
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
          Expanded(
            child:ListView(
              children:[
                headerSection,
                Container(
                  child: Image.asset('assets/images/YaMa vet-04 1.png'),
                ),
                //-----Phone Number-------
                Container(
                 padding:EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03,bottom: 5),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(),
                    ),
                  ),
                  initialCountryCode: 'SA',
                  onChanged: (phone) {
                    textChanged = true;
                    phoneNumber = phone.completeNumber;
                    partNumber = phone.number;
                    countryCode = phone.countryCode;
                  },
                ),
              ],
            ),
          ),
          continueSection
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
            backgroundColor: Colors.transparent,
            body:  formSection
            ),
          )

    );
  }
}