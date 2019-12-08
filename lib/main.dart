import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './login_page.dart';
import './chats_page.dart';
import './providers/domain.dart';
import './providers/token.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /* ========================= SET THESE PROPERTIES ========================= */
  static const _appName = 'ChatApp';
  static const _domainName = 'https://api.example.com';
  /* ======================================================================== */

  var _defaultHome = LoginPage(title: _appName);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(
          value: Domain(_domainName),
        ),
        ChangeNotifierProvider.value(
          value: Token(),
        )
      ],
      child: MaterialApp(
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
          '/login': (_) => LoginPage(title: _appName),
          '/chats': (_) => ChatsPage(),
        },
        title: _appName,
      ),
    );
  }
}
