import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ViewOther extends StatelessWidget {
  final String userId;

  ViewOther({required this.userId});

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('User not found');
            } else {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String firstName = userData['firstName'];
              return Text("$firstName's Portfolio");
            }
          },
        ),
    ),
    body: Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text('User not found');
                    } else {
                      var userData = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(userData['profileImageURL']),
                              ),
                              SizedBox(width: 20.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${userData['firstName']} ${userData['lastName']}',
                                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10.0),
                                  Row(
                                    children: [
                                      Text(
                                        'UID:',
                                        style: TextStyle(fontSize: 18.0, color: Colors.grey), 
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: userId));
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text('UID copied to clipboard'),
                                          ));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                      Divider(),
                        ],
                      );
                    }
                  },
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('artworks').where('userId', isEqualTo: userId).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No artworks found');
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: 1, 
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        var artwork = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        return InkWell(
                          onTap: () {
                            // Handle artwork tap
                          },
                          child: Card(
                            elevation: 3.0,
                            child: AspectRatio(
                              aspectRatio: 1, 
                              child: Image.network(
                                artwork['imageURL'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -10, 
          child: Container(
            height: 50, 
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2), 
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.alternate_email),
                iconSize: 35,
                onPressed: () {
                
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                
                      return ContactInformationScreen(userId: userId);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}

class ContactInformationScreen extends StatelessWidget {
  final String userId;

  ContactInformationScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    // Fetch user's contact information from Firestore
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0, // Adjust this value to control the height from the bottom
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          } else {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.alternate_email, size: 35),
                          SizedBox(height: 5),
                          Text(
                            '${userData['firstName']} ${userData['lastName']}',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text('UID: $userId', style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 116, 116, 116))),
                  SizedBox(height: 40),
                  Text('${userData['email']}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Text('${userData['phoneNumber']}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Text('${userData['address']}', style: TextStyle(fontSize: 20)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
