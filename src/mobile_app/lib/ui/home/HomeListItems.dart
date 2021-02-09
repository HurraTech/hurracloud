import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile_app/ui/widgets/ImageListCellWidget.dart';
import 'package:mobile_app/ui/widgets/StatsWidget.dart';
import 'package:mobile_app/ui/widgets/BaseListItemWidget.dart';

class RecommendedItem extends BaseListItemWidget {
  String title;
  String image;
  String description;

  RecommendedItem({this.image, this.title, this.description});

  @override
  Widget build(BuildContext context) => ImageListCellWidget(title: this.title,description: this.description, image: this.image,);
}


class HomeStatsListItem extends BaseListItemWidget {
  List<HurraStat> stats = [];
  HomeStatsListItem({this.stats});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 30.0),
    child: StatsWidget(stats: stats),
  );
}