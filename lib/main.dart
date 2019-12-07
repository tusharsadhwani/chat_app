import 'package:flutter/material.dart';

import './login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const appName = 'ChatApp';
  var _defaultHome = LoginPage(title: appName);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _defaultHome,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        textTheme: TextTheme(
          button: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      routes: {
        '/login': (_) => LoginPage(title: appName),
      },
      title: appName,
    );
  }
}
