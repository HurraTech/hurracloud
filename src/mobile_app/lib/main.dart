import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_app/store/UserStore.dart';
import 'package:mobile_app/ui/home/HomeScreen.dart';
import 'package:mobile_app/ui/onboarding/SplashScreen.dart';
import 'package:provider/provider.dart';

import 'HurraStyle.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final userStore = UserStore(); // Instantiate the store

  @override
  Widget build(BuildContext context) {
    return Provider<UserStore>(
      create: (_) => userStore,
      child: MaterialApp(
        title: 'Hurra',
        theme: ThemeData(
          primarySwatch: hurraColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/': (BuildContext context) => Observer(
              builder: (context)  =>  userStore.isLoggedIn ? HomeScreen() : SplashScreen()
          ),
        },
      ),
    );
  }
}
