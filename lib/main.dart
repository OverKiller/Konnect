import 'package:flutter/material.dart';
import 'package:konnect/screens/addpc/addpc_screen.dart';
import 'package:konnect/screens/main/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    "/": (context) => MainScreen(),
    "/add-screen": (context) => AddScreen()
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konnect Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: "/",
      routes: routes,
    );
  }
}
