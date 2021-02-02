import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';

class ServerPairScreen extends StatefulWidget {
  ServerPairScreen({Key key}) : super(key: key);

  @override
  ServerPairScreenState createState() => ServerPairScreenState();
}

class ServerPairScreenState extends State<ServerPairScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfff2f2f2),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            heightFactor: 1,
            child: Column(
              children: [
                SizedBox(height: 100),
                SizedBox(width: double.infinity,
                  child: Text("Ok, let’s set up your computer",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ),
                SizedBox(height: 15),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      Text(
                          "Hop over to your computer and open the following URL in your browser",
                          style: TextStyle(color: Color(0xff666666), fontSize: 14,fontWeight: FontWeight.w300)),
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                            "https://www.hurra.com/desktop",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Color(0xff666666), fontSize: 14,fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 10),
                      Text(
                          "Then follow the instructions on your computer to install Hurra cloud server",
                          style: TextStyle(color: Color(0xff666666), fontSize: 14,fontWeight: FontWeight.w300)),

                    ],),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),

              ],
            ),
          ),
        ));
  }
}
