
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/ui/widgets/BaseListItemWidget.dart';
import 'package:mobile_app/ui/widgets/ImageListCellWidget.dart';
import 'package:mobile_app/ui/widgets/ListHeaderWidget.dart';

class SouqApp extends BaseListItemWidget {
  String imageUrl;
  String backgroundColor;
  String foregroundColor;
  String name;
  String description;
  SouqApp({@required this.imageUrl, @required  this.name, @required  this.description, this.backgroundColor, this.foregroundColor});

  @override
  Widget build(BuildContext context) =>
      ImageListCellWidget(title: this.name, description: this.description, image: Image.network(imageUrl));

}

class SouqCollection extends BaseListItemWidget{
  String name;
  String description;
  List<SouqApp> apps;
  String displayType = "list"; // Either carousel or list

  SouqCollection({@required this.name, @required this.description, @required this.apps, this.displayType});

  @override
  Widget build(BuildContext context) =>
      ListHeaderWidget(title: this.name, description: this.description);

}