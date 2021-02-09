import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/ui/widgets/BaseListItemWidget.dart';
import 'package:mobile_app/ui/widgets/ImageListCellWidget.dart';
import 'package:mobile_app/ui/widgets/ListHeaderWidget.dart';
import 'package:mobile_app/ui/widgets/SearchWidget.dart';
import 'package:mobile_app/ui/widgets/StatsWidget.dart';

import 'HomeListItems.dart';



class HomeScreen extends StatelessWidget {

  final List<BaseListItemWidget> itemsList = [
    HomeStatsListItem(stats: [
      HurraStat(image: "cpu", label: "CPU Load", value: "56%"),
      HurraStat(image: "hdd", label: "Disk", value: "10gb/200gb"),
      HurraStat(image: "memory", label: "Memory", value: "32gb/64gb"),
      HurraStat(image: "apps", label: "Apps", value: "120")
    ]),

    HeaderListItem(title: "Build your cloud"),
    RecommendedItem(
        image: "hurradevice_s",
        title: "Get or migrate to a Hurra device",
        description:
            "Order a Hurra device or migrate cloud from computer to your new Hurra device"),
    RecommendedItem(
        image: "migrate",
        title: "Migrate your data to Hurra cloud",
        description:
            "Migrate files, photos, and personal data from 3rd party cloud providers to your Hurra home cloud"),
    RecommendedItem(
        image: "souq",
        title: "Browse Souq",
        description:
            "Browse Souq to discover new apps that you can install to your cloud device ")
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: itemsList.length,
        itemBuilder: (context, index) => itemsList[index].build(context)
    );
  }
}
