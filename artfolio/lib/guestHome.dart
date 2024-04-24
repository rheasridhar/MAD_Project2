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
        title: Text(
          'Welcome, Guest',
          style: TextStyle(color: Colors.white), 
        ),
        backgroundColor: Color(0xFF29386F), 
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white, 
            ),
            onPressed: () => _logout(context),
          ),
        ],
      ),
     backgroundColor: Color(0xFFe9f0ff), 
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Find Portfolio'),
                    backgroundColor: Color(0xFFCAD8EE),
                    content: TextFormField(
                      onChanged: (value) {
                        enteredUid = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter UID',
                        filled: true, 
                        fillColor: Colors.white, 
                        border: OutlineInputBorder( 
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none, 
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                        child: Text(
                          'Find',
                          style: TextStyle(color: Colors.white), 
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Color(0xFF29386F), 
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Find Portfolio',
                  style: TextStyle(fontSize: 24.0, color: Color(0xFF29386F)),
                ),
                Icon(
                  Icons.image_search,
                  size: 200,
                  color: Color(0xFF29386F),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ), backgroundColor: Color(0xFFAEBFDA),
            ),
          ),
        ),
      ),
    );
  }
}
