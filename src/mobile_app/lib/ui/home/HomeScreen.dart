import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: false,
          title: SizedBox(height:40, child: Image.asset("assets/logo.png")),
        ),
        backgroundColor: Color(0xfff2f2f2),
        body: Center(heightFactor: 1, child: Column(
      
      children: [
        
      ],
    )));
  }
}
