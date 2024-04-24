import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewArtScreen extends StatefulWidget {
  final String imageURL;
  final String description;

  ViewArtScreen({required this.imageURL, required this.description});

  @override
  _ViewArtScreenState createState() => _ViewArtScreenState();
}

class _ViewArtScreenState extends State<ViewArtScreen> {
  List<String> comments = [];
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Artwork'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(widget.imageURL),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.description,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('comments').add({
                    'imageURL': widget.imageURL,
                    'comment': commentController.text,
                    'timestamp': DateTime.now(),
                  }).then((_) {
                    setState(() {
                      comments.add(commentController.text);
                      commentController.clear();
                    });
                  }).catchError((error) {
                    print("Failed to add comment: $error");
                  });
                }
              },
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('imageURL', isEqualTo: widget.imageURL)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No comments found');
                } else {
                  // Map the documents to comments
                  List<String> fetchedComments = snapshot.data!.docs
                      .map((doc) => doc['comment'] as String)
                      .toList();
                  // Set the comments list with fetched comments
                  comments = fetchedComments;
                  // Display the comments
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Comments:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(comments[index]),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
