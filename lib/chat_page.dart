import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './providers/domain.dart';
import './providers/token.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List _args;
  List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _setupChat);
  }

  void _setupChat() {
    _args = (ModalRoute.of(context).settings.arguments as List);
    var _chatId = _args[0] as int;
    _loadChats(context, _chatId);
  }

  Future<void> _loadChats(BuildContext context, int chatId) async {
    var domain = Provider.of<Domain>(context).domain;
    var token = Provider.of<Token>(context).token;
    try {
      var response = await http.get('$domain/chats/$chatId?token=$token');
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
          _messages = data
              .map((message) => {
                    'name': message[5],
                    'body': message[3],
                    'timestamp': message[1],
                  })
              .toList();
          print(_messages);
        });
      }
    } catch (e) {
      // print(e);
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
    _args = (ModalRoute.of(context).settings.arguments as List);
    var _chatName = _args[1] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(_chatName),
      ),
      body: _messages == null
          ? Center(
              child: Text('No Chats Found'),
            )
          : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, index) => ChatMessage(
                name: _messages[index]['name'],
                body: _messages[index]['body'],
                timestamp: _messages[index]['timestamp'],
              ),
            ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String name;
  final String body;
  final int timestamp;

  ChatMessage({this.name, this.body, this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: body != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(body),
                Divider(),
              ],
            )
          : Center(
              child: Column(
                children: [
                  Text('$name joined the chat'),
                  Divider(),
                ],
              ),
            ),
    );
  }
}
