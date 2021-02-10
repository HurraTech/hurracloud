import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/ui/widgets/SearchWidget.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget screen;
  final bool isRootScreen;
  final String title;

  ScreenWrapper({@required this.screen, this.isRootScreen = false, this.title = null});

  Widget buildAndroidScaffold(BuildContext context, Widget content) =>
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 5.0,
          centerTitle: false,
          iconTheme: IconThemeData(
            color: hurraMainColor, //change your color here,
          ),
          title: isRootScreen ? SizedBox(height: 30, child: Image.asset("assets/logo.png")) :
            Text("Hello",style: TextStyle(color: hurraMainColor,fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        body: content,
      );

  Widget buildiOSScaffold(BuildContext context, Widget content) =>
      CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.white,
          leading:  isRootScreen ?  SizedBox(height: 25, child: Image.asset("assets/logo.png")) : null,
          middle: isRootScreen ? null : Text(title),
        ),
        child: content,
      );


  @override
  Widget build(BuildContext context) {
    Widget content = !isRootScreen ? screen: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          SearchWidget(),
          Expanded(child: screen),
        ]);
    return isiOSStyle ? buildiOSScaffold(context, content)
        : buildAndroidScaffold(context, content);
  }
}
