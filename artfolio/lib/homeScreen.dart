import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viewOther.dart';


class HomeScreen extends StatelessWidget {
  final String userId;

  HomeScreen({required this.userId});


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

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: Text('User Not Found'),
            ),
            body: Center(
              child: Text('User not found'),
            ),
          );
        } else {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String firstName = userData['firstName'] ?? 'User';
          return Scaffold(
            appBar: AppBar(
              title: Text('Welcome, $firstName'),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () => _logout(context), 
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/myPortfolio', arguments: userId);
                    },
                    child: Text(
                      'My Portfolio',
                      style: TextStyle(fontSize: 24.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
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
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
