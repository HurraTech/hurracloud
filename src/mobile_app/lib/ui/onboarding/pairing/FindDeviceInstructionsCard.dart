import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FindDeviceInstructionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
              "Hop over to your computer and open the following URL in your browser",
              style: TextStyle(
                  color: Color(0xff666666),
                  fontSize: 14,
                  fontWeight: FontWeight.w300)),
          SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: Text("https://www.hurra.com/desktop",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Color(0xff666666),
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10),
          Text(
              "Then follow the instructions on your computer to install Hurra cloud server",
              style: TextStyle(
                  color: Color(0xff666666),
                  fontSize: 14,
                  fontWeight: FontWeight.w300)),
        ],
      ),
    ),
  );

}