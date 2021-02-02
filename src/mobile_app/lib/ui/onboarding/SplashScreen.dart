import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        heightFactor: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 100),
            FractionallySizedBox(widthFactor: 0.65, child: Image(image: AssetImage('assets/logo.png'))),
            SizedBox(height: 30),
            Expanded(
              flex:1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text("TAKE BACK CONTROL", style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(top:17.0,left:40, right:40.0),
                  child: Text("Hurra let’s you take back control of your data and "
                      "privacy by creating your own private cloud which hosts "
                      "your data and apps right inside your home",
                      style: TextStyle(fontSize: 15.0, color: Color(0xff666666)),
                      textAlign: TextAlign.center),
                ),
              ],),
            ),
            // Spacer(flex:1),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                  Align(alignment: Alignment.bottomCenter, child:
                  Image(
                    fit: BoxFit.cover,
                      alignment: AlignmentDirectional.topCenter,
                      width: double.infinity,
                      image: AssetImage('assets/splashbg.png'))
                  ),
                  // RaisedButton(child: Text("ss"),onPressed: () {})
                  Column(
                    children: [
                      Spacer(flex:1),
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                          ),
                          color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(top:12,left:16,right:16, bottom: 12),
                          child: Text("SET UP NEW HURRA CLOUD"),
                        ), textColor: hurraMainColor, onPressed: () {  }
                        ),
                      SizedBox(height:5),
                      FlatButton(onPressed: (){},
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                          ),
                          textColor: Colors.white,
                          splashColor: Colors.white10,
                          child: Text("Login to my existing Hurra Cloud ")),
                      SizedBox(height: 100)],
                  ),
                ],
                ),
              ),
            )
            // Expanded(
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: Stack(
            //       children: [
            //         Align(alignment: Alignment.bottomCenter, child: Image(image: AssetImage('assets/splashbg.png'))),
            //
            //       ],
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
