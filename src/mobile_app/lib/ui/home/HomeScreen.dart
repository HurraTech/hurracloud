import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/ui/widgets/ImageListCellWidget.dart';
import 'package:mobile_app/ui/widgets/ListHeaderWidget.dart';
import 'package:mobile_app/ui/widgets/SearchWidget.dart';
import 'package:mobile_app/ui/widgets/StatsWidget.dart';

class HomeScreen extends StatelessWidget {
  List<Object> itemsList = [
    "HURRA_STATS",
    "Build your cloud",
    CellData(
        image: "hurradevice_s",
        title: "Get or migrate to a Hurra device",
        description:
            "Order a Hurra device or migrate cloud from computer to your new Hurra device"),
    CellData(
        image: "migrate",
        title: "Migrate your data to Hurra cloud",
        description:
            "Migrate files, photos, and personal data from 3rd party cloud providers to your Hurra home cloud"),
    CellData(
        image: "souq",
        title: "Browse Souq",
        description:
            "Browse Souq to discover new apps that you can install to your cloud device ")
  ];

  @override
  Widget build(BuildContext context) {
    Object item;
    return ListView.builder(
        itemCount: itemsList.length,
        itemBuilder: (context, index) {
          Object item = itemsList[index];
          if (item == "HURRA_STATS") {
            return Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                StatsWidget(
                  stats: [
                    HurraStat(
                        image: "cpu",
                        label: "CPU Load",
                        value: "56%"),
                    HurraStat(
                        image: "hdd",
                        label: "Disk",
                        value: "10gb/200gb"),
                    HurraStat(
                        image: "memory",
                        label: "Memory",
                        value: "32gb/64gb"),
                    HurraStat(
                        image: "apps", label: "Apps", value: "120")
                  ],
                ),
              ],
            );
          } else if (item is CellData) {
            return ImageListCellWidget(cellData: item);
          } else {
            return ListHeaderWidget(title: item);
          }
        });
  }
}
