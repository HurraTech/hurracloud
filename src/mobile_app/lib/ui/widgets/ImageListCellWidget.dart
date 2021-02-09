import 'package:flutter/material.dart';


class ImageListCellWidget extends StatelessWidget {
  String title;
  String image;
  String description;
  bool imageIsUrl = false;
  ImageListCellWidget({Key key, this.image, this.title, this.description, this.imageIsUrl = false}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(color: Color(0xffefefefef)),
                )),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              SizedBox(width: 5),
              SizedBox(
                  width: 40,
                  child: imageIsUrl ? Image.network(image) :  Image.asset("assets/${image}.png")),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
}
