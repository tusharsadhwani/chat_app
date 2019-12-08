import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import './providers/domain.dart';
import './providers/token.dart';

class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<dynamic> _chats;

  @override
  void initState() {
    super.initState();
    print('loading chats');
    Future.delayed(Duration.zero, () => _reloadChats(context));
  }

  void _reloadChats(BuildContext context) async {
    var domain = Provider.of<Domain>(context).domain;
    var token = Provider.of<Token>(context).token;
    try {
      var response = await http.get('$domain/chats?token=$token');
      if (response.statusCode != 200) {
        throw ArgumentError(
            "Request returned with status code ${response.statusCode}");
      }

      var data = jsonDecode(response.body);
      if (data is Map) {
        if (data.containsKey('error')) {
          var errMsg = data.containsKey('message')
              ? data['message']
              : "An error occured";
          throw ArgumentError(errMsg);
        } else {
          throw ArgumentError("An error occured");
        }
      } else if (data is List) {
        setState(() {
          print(data);
          _chats = data;
        });
      }
    } catch (e) {
      _showAlert(e, context);
    }
  }

  void _showAlert(e, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(e.toString()),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: _chats != null
          ? ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (_, index) => ListTile(
                title: Text(_chats[index][1] as String),
              ),
            )
          : Center(child: Text("No chats found")),
    );
  }
}
