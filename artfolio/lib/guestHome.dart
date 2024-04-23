import 'package:flutter/material.dart';
import 'viewOther.dart';

class GuestHome extends StatelessWidget {
  final String userId;

  GuestHome({required this.userId});

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    String enteredUid = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, Guest'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Find Portfolio'),
                  content: TextFormField(
                    onChanged: (value) {
                      enteredUid = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter UID',
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                       onPressed: () {
                                  Navigator.of(context).pop(); 
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ViewOther(userId: enteredUid)),
                                  );
                                },
                      child: Text('Find'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            'Find Portfolio',
            style: TextStyle(fontSize: 24.0),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(300, 300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }
}
