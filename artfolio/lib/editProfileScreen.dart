import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfileScreen({required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.userData['firstName'];
    _lastNameController.text = widget.userData['lastName'];
    _emailController.text = widget.userData['email'];
    _phoneNumberController.text = widget.userData['phoneNumber'] ?? '';
    _addressController.text = widget.userData['address'] ?? '';
  }

  Widget _buildProfileAvatar() {
    if (_profileImage != null) {
      // If there's a selected profile image, use it
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_profileImage!),
      );
    } else {
      // If there's a profile image URL, use it
      if (widget.userData.containsKey('profileImageURL') &&
          widget.userData['profileImageURL'] != null &&
          widget.userData['profileImageURL'] is String) {
        return CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(widget.userData['profileImageURL'] as String),
        );
      } else {
        // Use the default avatar image
        return CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('assets/default_avatar.png'),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    
    // Update user profile information
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneNumberController.text,
      'address': _addressController.text,
      // Update other fields as well
    });

    // If a new profile image is selected, upload it to Firebase Storage
    if (_profileImage != null) {
      String imagePath = 'profile_images/$userId.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(imagePath);
      await ref.putFile(_profileImage!);
      
      // Get the download URL of the uploaded image
      String downloadURL = await ref.getDownloadURL();

      // Update the profile image URL in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profileImageURL': downloadURL,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  } catch (e) {
    print('Error updating profile: $e');
  }
}



  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    _buildProfileAvatar(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: _pickImage,
                        tooltip: 'Edit Profile Picture',
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
