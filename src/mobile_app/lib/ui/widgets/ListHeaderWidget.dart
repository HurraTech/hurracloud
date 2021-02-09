
import 'package:flutter/material.dart';

import '../../HurraStyle.dart';

class ListHeaderWidget extends StatelessWidget {
  String title;
  String description;
  bool lightCell;
  ListHeaderWidget({
    Key key,
    @required this.title,
    this.description,
    this.lightCell = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 30, left: horizontalContentPadding, bottom: 10,right:horizontalContentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: lightCell ? 15: 18),
          ),
        ] + (this.description != null ? [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              description,
              style: TextStyle(
                  fontWeight: FontWeight.normal, fontSize: 14, color: Color(0xff555555)),
            ),
          ),
        ] : []),
      ),
    );
  }
}
