import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/ui/files/FilesScreen.dart';
import 'package:mobile_app/ui/home/HomeScreen.dart';
import 'package:mobile_app/ui/settings/SettingsScreen.dart';
import 'package:mobile_app/ui/souq/SouqScreen.dart';

import '../../HurraStyle.dart';

final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> fourthTabNavKey = GlobalKey<NavigatorState>();

class MainTabView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MainTabViewState();
}
class MainTabViewState extends State<MainTabView> {
  int selectedIndex = 0;
  EdgeInsets iconPadding = isiOSStyle ? EdgeInsets.all(0) : EdgeInsets.all(5);


  List<BottomNavigationBarItem> getNavItems() =>  [
    getNavItem("home", "Home"),
    getNavItem("files", "Files"),
    getNavItem("souq", "Souq"),
    getNavItem("settings", "Settings")
  ];

  BottomNavigationBarItem getNavItem(String icon, String label) =>
      BottomNavigationBarItem(
        icon: Padding( padding: iconPadding, child: SizedBox(width: 22, child: Image.asset("assets/${icon}_inactive.png")),),
        activeIcon: Padding(padding: iconPadding, child: SizedBox(width: 22, child: Image.asset("assets/${icon}_active.png")),
        ),
        label: label,
      );


  @override
  Widget build(BuildContext context) => !isiOSStyle
      ? Scaffold(
        body: (() {
          switch (selectedIndex) {
            case 0:return HomeScreen();
            case 1: return FilesScreen();
            case 2: return SouqScreen();
            default: return SettingsScreen();
          }
        })(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
          selectedItemColor: hurraMainColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) { setState(() { this.selectedIndex = index; }); },
          items: getNavItems(),
        ))
      : Scaffold(body: CupertinoTabScaffold(
          backgroundColor: hurraAppBackgroundColor,
          tabBar: CupertinoTabBar(
              backgroundColor: hurraTabBackgroundColor,
              onTap: (index) {
                // Navigator.of(context).pop();
              },
              border: Border(
                  top: BorderSide(color: Color(0xffe0e0e0e0), width: 1.0)),
              items: getNavItems()),
          tabBuilder: (context, index) {
            if (index == 0) {
              return CupertinoTabView(
                navigatorKey: firstTabNavKey,
                builder: (BuildContext context) => HomeScreen(),
              );
            } else if (index == 1) {
              return CupertinoTabView(
                navigatorKey: secondTabNavKey,
                builder: (BuildContext context) => FilesScreen(),
              );
            } else if (index == 2) {
              return CupertinoTabView(
                navigatorKey: thirdTabNavKey,
                builder: (BuildContext context) => SouqScreen(),
              );
            } else {
              return CupertinoTabView(
                navigatorKey: fourthTabNavKey,
                builder: (BuildContext context) => SettingsScreen(),
              );
            }
          },
        ));
}
