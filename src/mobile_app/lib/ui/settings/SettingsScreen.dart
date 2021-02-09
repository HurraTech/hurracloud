import 'package:flutter/material.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/ui/widgets/BaseListItemWidget.dart';


class SettingsScreen extends StatelessWidget {

  final List<BaseListItem> itemsList = [
    HeaderListItem(title: "Manage cloud", lightCell: true),
    ImageListItem(title: "Manage apps", image: Icon(Icons.apps,color: settingIconsColor,),lightCell: true),
    ImageListItem(title: "VPN Settings", image: Icon(Icons.vpn_lock,color: settingIconsColor,),lightCell: true),
    ImageListItem(title: "Connected devices", image: Icon(Icons.devices,color: settingIconsColor,),lightCell: true),

    HeaderListItem(title: "Manage Drives", lightCell: true),
    ImageListItem(title: "Internal Storage", image: Icon(Icons.sd_card,color: settingIconsColor,),lightCell: true),
    ImageListItem(title: "USB 1", image: Icon(Icons.sd_card,color: settingIconsColor,),lightCell: true),

    HeaderListItem(title: "Tools", lightCell: true),
    ImageListItem(title: "Migrate data from external clouds", image: Icon(Icons.cloud_download_rounded,color: settingIconsColor,),lightCell: true),
    ImageListItem(title: "Order new Hurra device", image: Icon(Icons.shopping_cart_sharp,color: settingIconsColor,),lightCell: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: itemsList.length,
        itemBuilder: (context, index) => itemsList[index].build(context)
    );
  }
}
