import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/ui/onboarding/pairing/FindDeviceInstructionsCard.dart';
import 'FindDeviceCard.dart';

class ServerPairScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        ),
        backgroundColor: Color(0xfff2f2f2),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            heightFactor: 1,
            child: Column(
              children: [
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Text("Ok, let’s set up your computer",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ),
                SizedBox(height: 15),
                FindDeviceInstructionsCard(),
                SizedBox(height: 20),
                Expanded(child: FindDeviceCard()),
                SizedBox(height: 40),
              ],
            ),
          ),
        ));
  }
}
