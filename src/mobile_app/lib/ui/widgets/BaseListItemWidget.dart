import 'package:flutter/material.dart';
import 'package:mobile_app/ui/widgets/ImageListCellWidget.dart';
import 'package:mobile_app/ui/widgets/ListHeaderWidget.dart';

abstract class BaseListItem {
  Widget build(BuildContext context);
}


class HeaderListItem extends BaseListItem {
  String title;
  bool lightCell;
  HeaderListItem({@required this.title,this.lightCell = false});

  @override
  Widget build(BuildContext context) => ListHeaderWidget(title: title,lightCell:lightCell);

}


class ImageListItem extends BaseListItem {
  String title;
  Widget image;
  bool lightCell;
  VoidCallback onPressed;

  ImageListItem({@required this.title,this.image, this.lightCell = false,this.onPressed = null});

  @override
  Widget build(BuildContext context) => ImageListCellWidget(title: title, image:image,lightCell: lightCell,onPressed: this.onPressed);

}