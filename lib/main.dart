import 'package:error/HomeScreen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    //flutter k andr wudgets use ki jaati hain
    //e.g text , icons , status bar , app bar, body ,heiarchy widgets hoti h

    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,

      ),

      darkTheme: ThemeData(
        brightness: Brightness.light,
      ),
      initialRoute:
          "/Login", //initial route mein back slash/ replace hojata hai
      routes: {
        "/": (context) => HomeScreen(),

      },
    );
  }
}