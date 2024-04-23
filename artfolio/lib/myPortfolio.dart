import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPortfolio extends StatelessWidget {
  final String userId;

  MyPortfolio({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Portfolio'),
      ),
      body: SingleChildScrollView(
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
                        Text(
                          'Name: ${userData['firstName']} ${userData['lastName']}',
                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'UID: $userId',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Artworks:',
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10.0),
                        // Display user artworks
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
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 150.0, // Fixed height to ensure images have the same size
                                            child: Image.network(
                                              artwork['imageURL'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              artwork['description'] ?? 'No description',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the screen to add a new artwork
          Navigator.pushNamed(context, '/uploadArtwork', arguments: userId);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
