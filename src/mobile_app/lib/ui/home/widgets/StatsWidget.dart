import 'package:flutter/material.dart';

class HurraStat {
  String image;
  String label;
  String value;
  HurraStat({this.image, this.label, this.value});
}

class StatsWidget extends StatelessWidget {
  List<HurraStat> stats = [];
  StatsWidget({Key key, @required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(color: Color(0xffcccccc)),
                bottom: BorderSide(color: Color(0xffcccccc)))),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Wrap(
            runSpacing: 10,
              children: this.stats
                  .map((item) => FractionallySizedBox(
                      widthFactor: 0.5,
                      child: StatItemWidget(
                          stat: HurraStat(
                              image: "${item.image}", label: "${item.label}", value: "${item.value}"))))
                  .toList()),
        ));
  }
}

class StatItemWidget extends StatelessWidget {
  HurraStat stat;

  StatItemWidget({key, this.stat}) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(width: 25, child: Image.asset("assets/${stat.image}.png")),
          SizedBox(
            width: 5,
          ),
          Text(
            "${stat.label}: ${stat.value}",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          )
        ],
      );
}
