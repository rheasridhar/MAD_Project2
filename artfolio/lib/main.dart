import 'package:flutter/material.dart';
import 'loginScreen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'editProfileScreen.dart';
import 'guestHome.dart';
import 'homeScreen.dart';
import 'myPortfolio.dart';
import 'uploadArtwork.dart';


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
