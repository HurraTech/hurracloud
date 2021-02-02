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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ),
                SizedBox(height: 15),
                Card(
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
                ),
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                onPressed: () {}),
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
