
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
      child: Text(
        "$title",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}
