
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_generator/screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);



  runApp(const PasswordGeneratorApp());
}


class PasswordGeneratorApp extends StatefulWidget {
  const PasswordGeneratorApp({super.key});

  @override
  State<PasswordGeneratorApp> createState() => _PasswordGeneratorAppState();
}

class _PasswordGeneratorAppState extends State<PasswordGeneratorApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: PasswordGeneratorScreen(),
    );
  }
}