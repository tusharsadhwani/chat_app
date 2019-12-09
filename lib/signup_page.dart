import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './providers/domain.dart';

class SignupPage extends StatefulWidget {
  final String title;

  SignupPage({this.title});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  var _formData = Map<String, String>();
  var _emailFocusNode = FocusNode();
  var _usernameFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  var _disableButton = false;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _signup(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      print("Invalid form");
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _disableButton = true;
    });
    var domain = Provider.of<Domain>(context).domain;
    var name = _formData['name'];
    var email = _formData['email'];
    var username = _formData['username'].trim();
    var password = _formData['password'];
    try {
      var response = await http.get(
          '$domain/signup?name=$name&email=$email&username=$username&password=$password');
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
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Success'),
          content: Text(
              "A verification email has been sent to your email. Login with your username and password after you have opened the verification link."),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login');
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
                  labelText: 'name',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocusNode),
                onSaved: (value) {
                  _formData['name'] = value;
                },
                validator: (value) {
                  if (value.length == 0) return "Field must not be empty";
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'email',
                ),
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_usernameFocusNode),
                onSaved: (value) {
                  _formData['email'] = value;
                },
                validator: (value) {
                  value = value.trim();
                  var matchGroup =
                      RegExp(r'[\w\.]+@\w+\.\w+').allMatches(value).toList();
                  if (matchGroup.length > 0) {
                    print(matchGroup[0].group(0));
                    if (matchGroup[0].group(0) != value) return "Invalid email";
                    return null;
                  }
                  return "Invalid Email";
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'username',
                ),
                focusNode: _usernameFocusNode,
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
                onFieldSubmitted: (_) => _signup(context),
                validator: (value) {
                  if (value.length < 8) return "Password too short";
                  return null;
                },
                onSaved: (value) {
                  _formData['password'] = value;
                },
              ),
              RaisedButton(
                child: Text('Create Account'),
                onPressed: _disableButton ? null : () => _signup(context),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).textTheme.button.color,
              ),
              FlatButton(
                child: Text('Login Instead'),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
