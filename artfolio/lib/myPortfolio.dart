import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editProfileScreen.dart'; // Import the edit profile screen

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Name: ${userData['firstName']} ${userData['lastName']}',
                              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Navigate to the edit profile screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditProfileScreen(userData: userData)),
                                );
                              },
                            ),
                          ],
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
                                  crossAxisCount: 3, // Changed to 3 images per row
                                  crossAxisSpacing: 3.0,
                                  mainAxisSpacing: 3.0,
                                  childAspectRatio: 1, // Adjust aspect ratio for wider squares
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
                                        aspectRatio: 1, // Square aspect ratio
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
