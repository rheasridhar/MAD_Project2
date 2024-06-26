import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UploadArtwork extends StatefulWidget {
  final String userId;

  UploadArtwork({required this.userId});

  @override
  _UploadArtworkState createState() => _UploadArtworkState();
}

class _UploadArtworkState extends State<UploadArtwork> {
  File? _image;
  TextEditingController _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

 Future<void> _uploadArtwork() async {
  try {

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    String imagePath = 'artworks/${widget.userId}/$imageName.jpg';
    await FirebaseStorage.instance.ref().child(imagePath).putFile(_image!);

    String imageURL = await FirebaseStorage.instance.ref(imagePath).getDownloadURL();

    await FirebaseFirestore.instance.collection('artworks').add({
      'userId': widget.userId,
      'imageURL': imageURL,
      'description': _descriptionController.text,
      'timestamp': DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Artwork uploaded successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  } catch (e) {

    print('Error uploading artwork: $e');
  }
}


  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Upload Artwork'),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _pickImage,
              child: _image == null
                  ? Container(
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(Icons.camera_alt, size: 50),
                ),
              )
                  : Image.file(_image!),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _uploadArtwork();
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    ),
    resizeToAvoidBottomInset: true, 
  );
}
}