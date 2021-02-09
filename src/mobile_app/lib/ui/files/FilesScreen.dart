import 'package:flutter/material.dart';
import 'package:mobile_app/ui/widgets/ListHeaderWidget.dart';

import 'FilesListItems.dart';
class FilesScreen extends StatelessWidget {
  List<FileTreeItem> files = [
    FileTreeItem(name: "HDD 1", type: FileType.HDD),
    FileTreeItem(name: "USB Disk 1", type: FileType.HDD)
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: files.length+1,
        itemBuilder: (context, index) {
          if (index == 0) return ListHeaderWidget(title: "Files",);
          return files[index-1].build(context);
        });
  }
}

