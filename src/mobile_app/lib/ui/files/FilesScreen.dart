import 'package:flutter/material.dart';
import 'package:mobile_app/ui/nav/ScreenWrapper.dart';
import 'package:mobile_app/ui/widgets/BaseListItemWidget.dart';
import 'package:mobile_app/ui/widgets/ListHeaderWidget.dart';

import 'FilesListItems.dart';
class FilesScreen extends StatelessWidget {
  final FileTreeItem selectedNode;
  List<FileTreeItem> files = [
    FileTreeItem(name: "HDD 1", type: FileType.HDD),
    FileTreeItem(name: "USB Disk 1", type: FileType.HDD)
  ];

  FilesScreen({this.selectedNode});

  @override
  Widget build(BuildContext context) {
    List<BaseListItem> items = [];
    if (selectedNode == null) {
      items.add(HeaderListItem(title: "Files"));
    }
    items.addAll(files);

    return ScreenWrapper(
        isRootScreen: this.selectedNode == null,
        title: this.selectedNode != null ? this.selectedNode.name : "Files",

        screen: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: items.length,
            itemBuilder: (context, index) => items[index].build(context)
        )
    );
  }
}

