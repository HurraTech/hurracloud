import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/ui/files/FilesScreen.dart';
import 'package:mobile_app/ui/home/HomeScreen.dart';
import 'package:mobile_app/ui/souq/SouqScreen.dart';

import 'widgets/SearchWidget.dart';

final GlobalKey<NavigatorState> firstTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> secondTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> thirdTabNavKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> fourthTabNavKey = GlobalKey<NavigatorState>();

class MainTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: false,
        title: SizedBox(height: 40, child: Image.asset("assets/logo.png")),
      ),
      backgroundColor: Color(0xfff2f2f2),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10,),
            SearchWidget(),
            Expanded(
              child: CupertinoTabScaffold(
                tabBar: CupertinoTabBar(
                  border: Border(
                    top:BorderSide(color: Color(0xffe0e0e0e0),width: 1.0)
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          width: 22, child: Image.asset("assets/home_inactive.png")),
                      activeIcon: SizedBox(
                          width: 22, child: Image.asset("assets/home_active.png")),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          width: 22, child: Image.asset("assets/files_inactive.png")),
                      activeIcon: SizedBox(
                          width: 22, child: Image.asset("assets/files_active.png")),
                      label: 'Files',
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          width: 22, child: Image.asset("assets/souq_inactive.png")),
                      activeIcon: SizedBox(
                          width: 22, child: Image.asset("assets/souq_active.png")),
                      label: 'Souq',
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          width: 22, child: Image.asset("assets/settings_inactive.png")),
                      activeIcon: SizedBox(
                          width: 22, child: Image.asset("assets/settings_active.png")),
                      label: 'Settings',
                    ),
                  ],
                ),
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
                      builder: (BuildContext context) => HomeScreen(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
