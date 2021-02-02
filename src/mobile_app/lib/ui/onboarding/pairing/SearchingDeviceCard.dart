import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SearchingDeviceCard extends StatelessWidget {

  @override
  Widget build(BuildContext context)  => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 15),
          FractionallySizedBox(
              widthFactor: 0.5,
              child: Image(
                  image:
                  AssetImage('assets/findcomputer.png'))),
          SizedBox(height: 30),
          Text("Please wait while we find and connect to your computer",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff333333),
                  fontSize: 17,
                  fontWeight: FontWeight.normal)),
          SizedBox(height: 30),
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.grey)),
          SizedBox(height: 30),
          FlatButton(
              onPressed: () {},
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              textColor: Colors.lightBlue,
              splashColor: Colors.white10,
              child: Text("Tap here if you prefer to connect manually", style:TextStyle(fontWeight:FontWeight.normal), textAlign: TextAlign.center)),

        ],
      ),
    ),
  );

}