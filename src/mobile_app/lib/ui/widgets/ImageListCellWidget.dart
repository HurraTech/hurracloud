import 'package:flutter/material.dart';

class ImageListCellWidget extends StatelessWidget {
  String title;
  String image;
  String description;
  bool imageIsUrl = false;
  ImageListCellWidget({Key key, @required this.image, @required this.title, this.description, this.imageIsUrl = false}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(color: Color(0xffefefefef)),
                )),
        child: Padding(
          padding: EdgeInsets.all(this.description != null ? 18.0 : 12.0),
          child: Row(
            children: [
              SizedBox(width: 5),
              SizedBox(
                  width: description != null ? 40 : 20,
                  child: imageIsUrl ? Image.network(image) :  Image.asset("assets/${image}.png")),
              SizedBox(width: description != null ? 20 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ] + (this.description != null ? [SizedBox(
                    height: 5,
                  ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13),
                    )
                  ]: []),
                ),
              )
            ],
          ),
        ),
      );
}
