import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/ui/files/FilesScreen.dart';
import 'package:mobile_app/ui/widgets/BaseListItemWidget.dart';
import 'package:mobile_app/ui/widgets/ImageListCellWidget.dart';

enum FileType { HDD, DIR, FILE }

class FileTreeItem extends BaseListItem {
  String name;
  FileType type;
  List<FileTreeItem> children = [];
  String mimeType;

  FileTreeItem({@required this.name, @required this.type, this.children});

  @override
  Widget build(BuildContext context) => ImageListCellWidget(
        image: Image.asset(
            "assets/file_${type.toString().split('.').last.toLowerCase()}.png"),
        title: name,
        lightCell: false,
        onPressed: (context) {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => FilesScreen(selectedNode: this,)),
          );
        },
      );
}
