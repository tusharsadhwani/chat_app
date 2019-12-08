import 'package:flutter/material.dart';

class JoinChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'chat address',
              ),
            ),
            RaisedButton(
              child: Text('Join Chat'),
              onPressed: () {},
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).textTheme.button.color,
            ),
          ],
        ),
      ),
    );
  }
}
