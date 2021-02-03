import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/store/UserStore.dart';
import 'package:provider/provider.dart';

class OnboardingCompleteScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);

    return Scaffold(
        backgroundColor: Color(0xfff2f2f2),
        body: Padding(
          padding: const EdgeInsets.only(left:30, right:30),
          child: Center(
            heightFactor: 1,
            child: Column(
              children: [
                SizedBox(height: 100),
                FractionallySizedBox(widthFactor: 0.6,child: Image(image: AssetImage('assets/hurrascreen.png'))),
                SizedBox(height: 80),
                SizedBox(
                  width: double.infinity,
                  child: Text("Your cloud is ready!",
                      textAlign: TextAlign.start,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
                ),
                SizedBox(height: 20),
                Text(
                    "Congrats! You are now connected to your private in-home cloud. "
                        "We will help you migrate all your data from 3rd party providers to your cloud so you can have complete control of your data",
                    style: TextStyle(color: Color(0xff333333), fontSize: 18,fontWeight: FontWeight.w300)),
                SizedBox(
                  height: 50,
                ),
                SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: hurraColor,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 16, left: 16, right: 16, bottom: 16),
                          child: Text("GO TO YOUR CLOUD", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 17),),
                        ),
                        textColor: hurraMainColor,
                        onPressed: () {
                          userStore.setLoggedIn();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        })),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ));
  }
}
