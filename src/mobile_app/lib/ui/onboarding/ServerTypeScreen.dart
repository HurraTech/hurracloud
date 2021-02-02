import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/ui/onboarding/pairing/ServerPairScreen.dart';

class ServerTypeScreen extends StatelessWidget {

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
          padding: const EdgeInsets.only(left:20, right:20),
          child: Center(
            heightFactor: 1,
            child: Column(
              children: [
                SizedBox(height: 20),
                Text("Where do you want to host your cloud ?",
                    textAlign: TextAlign.start,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                SizedBox(height: 20),
                Text(
                    "In order to create a truly private Hurra cloud, "
                    "you need to have a computer in your home which will host your cloud data and "
                    "applications.",
                    style: TextStyle(color: Color(0xff666666), fontSize: 14,fontWeight: FontWeight.w300)),
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(top:30, left: 5.0, right:5, bottom:30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width:60,child: Image(image: AssetImage('assets/hurradevice.png'))),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Use Hurra Device ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff555555),
                                            fontSize: 16)),
                                    SizedBox(height: 5,),
                                    Text("Hurra Device is a dedicated cloud device which you can install "
                                        "in your home to host your data. Recommended for best security and performance ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w200,
                                            color: Colors.black,
                                            fontSize: 11.5)),

                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => ServerPairScreen(),
                            ),
                          );
                        })),
                SizedBox(height: 20,),
                SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(top:30, left: 5.0, right:5, bottom:30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width:60,child: Image(image: AssetImage('assets/computer.png'))),
                              SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Use my own computer",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff555555),
                                            fontSize: 16)),
                                    SizedBox(height: 5,),
                                    Text("If you don’t have Hurra Device yet, you can install use your computer. "
                                        "It only takes few minutes to set up your computer. "
                                        "You can later migrate to a Hurra Device for best security and performance",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w200,
                                            color: Colors.black,
                                            fontSize: 11.5)),

                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        onPressed: () {}))

              ],
            ),
          ),
        ));
  }
}
