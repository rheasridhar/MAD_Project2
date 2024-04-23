import 'dart:io';
import 'package:artfolio/uploadArtwork.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'editProfileScreen.dart';
import 'guestHome.dart';
import 'homeScreen.dart';
import 'myPortfolio.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artfolio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) {
  final userId = ModalRoute.of(context)?.settings.arguments as String?;
  if (userId != null) {
    return HomeScreen(userId: userId);
  } else {
  
    return Scaffold(
      body: Center(
        child: Text('User ID is missing'),
      ),
    );
  }
},
        '/createAccount': (context) => CreateAccountScreen(),
        '/myPortfolio': (context) => MyPortfolio(userId: ModalRoute.of(context)!.settings.arguments as String),
        '/uploadArtwork': (context) => UploadArtwork(userId: ModalRoute.of(context)!.settings.arguments as String),
        '/editProfile': (context) => EditProfileScreen(userData: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
        '/login': (context) => LoginScreen(),
        '/guestHome': (context) => GuestHome(userId: ModalRoute.of(context)!.settings.arguments as String),
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    String userId = userCredential.user!.uid;

    Navigator.pushReplacementNamed(context, '/home', arguments: userCredential.user!.uid);
  } catch (e) {

    print('Error signing in: $e');
  }
}

  Future<void> signInAnonymously(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();
  
      String userId = userCredential.user!.uid;

      Navigator.pushReplacementNamed(context, '/guestHome', arguments: userId);
    } catch (e) {
   
      print('Error signing in anonymously: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artfolio'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                signInWithEmailAndPassword(context);
              },
              child: Text('Submit'),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/createAccount');
              },
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  children: [
                    TextSpan(
                      text: 'Create one here',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
  padding: EdgeInsets.symmetric(vertical: 50.0), 
  child: Text(
    'or',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
  ),
),
Text(
    'Enter as Guest',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
  ),

            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
              
                signInAnonymously(context);
              },
              child: Text('Guest'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _createAccount(BuildContext context) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': emailController.text.trim(),
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'phoneNumber': phoneNumberController.text.trim(),
      'address': addressController.text.trim(),
    });

    if (_profileImage != null) {
      String imageName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      String imagePath =
          'profile_images/${userCredential.user!.uid}/$imageName';
      await FirebaseStorage.instance
          .ref()
          .child(imagePath)
          .putFile(_profileImage!);
      String profileImageURL =
          await FirebaseStorage.instance.ref(imagePath).getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({'profileImageURL': profileImageURL});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, '/home', arguments: userCredential.user!.uid);

  } catch (e) {
    
    print('Error creating account: $e');
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
        title: Text('Create Account'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: _pickImage,
                child: _profileImage == null
                    ? Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(Icons.camera_alt, size: 50),
                        ),
                      )
                    : Image.file(_profileImage!),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Optional Information (Used in contact section)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                ),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _createAccount(context);
                },
                child: Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}