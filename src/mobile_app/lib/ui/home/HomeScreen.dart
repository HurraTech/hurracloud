import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/ui/home/widgets/SearchWidget.dart';
import 'package:mobile_app/ui/home/widgets/StatsWidget.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: false,
          title: SizedBox(height: 40, child: Image.asset("assets/logo.png")),
        ),
        backgroundColor: Color(0xfff2f2f2),
        body: Center(
            heightFactor: 1,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                SearchWidget(),
                SizedBox(
                  height: 20,
                ),
                StatsWidget(
                  stats: [
                    HurraStat(image: "cpu", label: "CPU Load", value: "56%"),
                    HurraStat(image: "hdd", label: "Disk", value: "10gb/200gb"),
                    HurraStat(image: "memory", label: "Memory", value: "32gb/64gb"),
                    HurraStat(image: "apps", label: "Apps", value: "120")
                  ],
                )
              ],
            )));
  }
}
