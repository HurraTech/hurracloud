import 'package:flutter/material.dart';
import 'package:mobile_app/ui/onboarding/ServerTypeScreen.dart';
import 'package:mobile_app/ui/onboarding/SplashScreen.dart';

import 'HurraStyle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: hurraColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen()
    );
  }
}
