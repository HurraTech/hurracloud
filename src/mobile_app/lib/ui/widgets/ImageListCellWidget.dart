import 'package:flutter/material.dart';

class ImageListCellWidget extends StatelessWidget {
  String title;
  Widget image;
  String description;
  bool lightCell;
  VoidCallback onPressed;

  ImageListCellWidget(
      {Key key,
      @required this.image,
      @required this.title,
      this.description,
      this.lightCell = false,
      this.onPressed = null})
      : super(key: key);

  @override
  Widget build(BuildContext context) => onPressed != null
      ? FlatButton(
          padding: EdgeInsets.all(0),
          color: Colors.white,
          onPressed: this.onPressed,
          child: buildContent(context),
        )
      : buildContent(context);

  Widget buildContent(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: onPressed != null ? null : Colors.white,
            border: Border(
          top: BorderSide(color: Color(0xffefefefef)),
        )),
        child: Padding(
          padding: EdgeInsets.all(this.description != null ? 18.0 : 12.0),
          child: Row(
            children: [
              SizedBox(width: lightCell ? 0 : 5),
              SizedBox(
                  width: lightCell
                      ? (image is Icon ? 30 : 15)
                      : (description != null ? 40 : 30),
                  child: image),
              SizedBox(width: description != null ? 20 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                              fontWeight: lightCell
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 15),
                        ),
                      ] +
                      (this.description != null
                          ? [
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                description,
                                style: TextStyle(fontSize: 13),
                              )
                            ]
                          : []),
                ),
              )
            ],
          ),
        ),
      );
}
