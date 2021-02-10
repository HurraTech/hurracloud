import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile_app/ui/widgets/ImageListCellWidget.dart';
import 'package:mobile_app/ui/widgets/StatsWidget.dart';
import 'package:mobile_app/ui/widgets/BaseListItemWidget.dart';

class RecommendedItem extends BaseListItem {
  String title;
  String image;
  String description;
  void Function(BuildContext) onPressed;
  RecommendedItem({this.image, this.title, this.description, this.onPressed});

  @override
  Widget build(BuildContext context)
    => ImageListCellWidget(title: this.title,description: this.description, image: Image.asset("assets/$image.png",), onPressed: onPressed,);
}

class HomeStatsListItem extends BaseListItem {
  List<HurraStat> stats = [];
  HomeStatsListItem({this.stats});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: StatsWidget(stats: stats),
      );
}
