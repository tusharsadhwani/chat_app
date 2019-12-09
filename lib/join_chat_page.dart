import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import './providers/domain.dart';
import './providers/token.dart';

class JoinChatPage extends StatefulWidget {
  @override
  _JoinChatPageState createState() => _JoinChatPageState();
}

class _JoinChatPageState extends State<JoinChatPage> {
  final _formKey = GlobalKey<FormState>();
  String _address;
  var _disableButton = false;

  void _joinChat(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      print("Invalid form");
      return;
    }
    _formKey.currentState.save();

    setState(() {
      _disableButton = true;
    });
    var domain = Provider.of<Domain>(context).domain;
    var token = Provider.of<Token>(context).token;
    print("tokennn: $token");
    try {
      var response = await http.get('$domain/joinchat/$_address?token=$token');
      if (response.statusCode != 200) {
        throw ArgumentError(
            "Request returned with status code ${response.statusCode}");
      }

      var data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('error')) {
        var errMsg =
            data.containsKey('message') ? data['message'] : "An error occured";
        throw ArgumentError(errMsg);
      }
      if (!data.containsKey('success')) {
        throw ArgumentError("Missing success from response body");
      }
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
      _showAlert(e, context);
    } finally {
      setState(() {
        _disableButton = false;
      });
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
        title: Text('Join Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'chat address',
                ),
                onSaved: (value) {
                  _address = value.trim();
                },
                validator: (value) {
                  if (value.trim().contains(RegExp(r'\W')))
                    return "No whitespace allowed in address";
                  return null;
                },
              ),
              RaisedButton(
                child: Text('Join Chat'),
                onPressed: _disableButton ? null : () => _joinChat(context),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).textTheme.button.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
