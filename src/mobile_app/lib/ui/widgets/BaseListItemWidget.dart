import 'package:flutter/material.dart';
import 'package:mobile_app/ui/widgets/ListHeaderWidget.dart';

abstract class BaseListItemWidget {
  Widget build(BuildContext context);
}


class HeaderListItem extends BaseListItemWidget {
  String title;
  HeaderListItem({@required this.title});

  @override
  Widget build(BuildContext context) => ListHeaderWidget(title: title);

}