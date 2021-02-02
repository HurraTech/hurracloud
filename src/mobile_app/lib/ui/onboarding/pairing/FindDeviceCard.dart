import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nsd/flutter_nsd.dart';
import 'package:mobile_app/HurraStyle.dart';


class FindDeviceCard extends StatelessWidget {

  final VoidCallback onSearchClicked;
  FindDeviceCard({this.onSearchClicked});

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
          SizedBox(height: 15),
          Text("Let's find your computer",
              style: TextStyle(
                  color: Color(0xff666666),
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          Text(
              "After installing Hurra on your computer, tap the button below to start searching"
                  " for your computer. We need your permission to search in your network",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff666666),
                  fontSize: 14,
                  fontWeight: FontWeight.w300)),
          SizedBox(height: 20),
          SizedBox(
            width:double.infinity,
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                color: hurraColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 12, left: 16, right: 16, bottom: 12),
                  child: Text("Start Searching"),
                ),
                textColor: Colors.white,
                onPressed: onSearchClicked),
          ),
          SizedBox(height: 15),
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