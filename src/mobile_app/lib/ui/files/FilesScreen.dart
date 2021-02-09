import 'package:flutter/material.dart';
import 'package:mobile_app/ui/widgets/ListHeaderWidget.dart';

enum FileType { HDD, DIR, FILE }

class FileTreeItem {
  String name;
  FileType type;
  List<FileTreeItem> children = [];
  String mimeType;

  FileTreeItem({@required this.name, @required this.type, this.children});
}

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
          FileTreeItem item = files[index-1];
          return FileListItem(file: item);
        });
  }
}


class FileListItem extends StatelessWidget {
  FileTreeItem file;

  FileListItem({Key key, this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xffefefefef)),
            )),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              SizedBox(width: 5),
              SizedBox(
                  width: 20,
                  child: Image.asset("assets/file_${this.file.type.toString().split('.').last
                      .toLowerCase()}.png")),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  file.name,
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              )
            ],
          ),
        ),
      );
}
