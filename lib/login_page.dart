import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './providers/domain.dart';

class LoginPage extends StatefulWidget {
  final String title;

  LoginPage({this.title});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var _formData = Map<String, String>();
  var _usernameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  var _disableButton = false;

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState.validate()) {
      print("Invalid form");
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _disableButton = true;
    });
    var domain = Provider.of<Domain>(context).domain;
    var username = _formData['username'].trim();
    var password = _formData['password'];
    var response =
        await http.get('$domain/login?username=$username&password=$password');
    var data = jsonDecode(response.body) as Map<String, dynamic>;
    print(data);
    setState(() {
      _disableButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'username',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocusNode),
                onSaved: (value) {
                  _formData['username'] = value;
                },
                validator: (value) {
                  if (value.trim().contains(RegExp(r'\W')))
                    return "No whitespace allowed in username";
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'password',
                ),
                focusNode: _passwordFocusNode,
                obscureText: true,
                onFieldSubmitted: (_) => _login(),
                validator: (value) {
                  if (value.length < 8) return "Password too short";
                  return null;
                },
                onSaved: (value) {
                  _formData['password'] = value;
                },
              ),
              RaisedButton(
                child: Text('Login'),
                onPressed: _disableButton ? null : _login,
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
