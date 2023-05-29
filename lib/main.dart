import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login/Screen/Map_Screen.dart';
import 'package:login/Screen/Station_Owner_Map.dart';
import 'package:login/Screen/login_screen.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  const  MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   inputDecorationTheme:  InputDecorationTheme(
      //     enabledBorder: OutlineInputBorder(
      //       borderSide:const BorderSide(width: 1, color: Colors.green),
      //       borderRadius: BorderRadius.circular(15),
      //     ),
      //     focusedBorder: OutlineInputBorder(
      //       borderSide: const BorderSide(width: 1, color: Colors.green),
      //       borderRadius: BorderRadius.circular(15),
      //     ),
      //   ),
      // ),

      home:  Map_Screen(),
    );
  }
}






