
import 'package:flutter/material.dart';

class ListHeaderWidget extends StatelessWidget {
  String title;
  String description;
  ListHeaderWidget({
    Key key,
    @required this.title,
    this.description
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 30, left: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20),
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
