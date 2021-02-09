import 'package:flutter/material.dart';

class CellData {
  String title;
  String image;
  String description;

  CellData({this.image, this.title, this.description});
}

class ImageListCellWidget extends StatelessWidget {
  CellData cellData;

  ImageListCellWidget({Key key, this.cellData}) : super(key: key);

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
                  child: Image.asset("assets/${cellData.image}.png")),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cellData.title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      cellData.description,
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
