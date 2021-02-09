import 'package:flutter/material.dart';
import 'package:mobile_app/ui/widgets/BaseListItemWidget.dart';

import 'SouqListItems.dart';



class SouqScreen extends StatelessWidget {
  List<SouqCollection> collections = [
    SouqCollection(name: "Featured Apps", description: "Apps featured by souq", apps: [
      SouqApp(imageUrl: "https://s3.amazonaws.com/public.guestbot.co/plex.png", name :"Plex Media Server", description: "Turn your Hurra cloud into a media server. Stream all your downloaded files to your phone directly from Hurra cloud using Plex"),
      SouqApp(imageUrl: "https://s3.amazonaws.com/public.guestbot.co/plex.png", name :"Plex Media Server", description: "Turn your Hurra cloud into a media server. Stream all your downloaded files to your phone directly from Hurra cloud using Plex"),
      SouqApp(imageUrl: "https://s3.amazonaws.com/public.guestbot.co/plex.png", name :"Plex Media Server", description: "Turn your Hurra cloud into a media server. Stream all your downloaded files to your phone directly from Hurra cloud using Plex"),
      SouqApp(imageUrl: "https://s3.amazonaws.com/public.guestbot.co/plex.png", name :"Plex Media Server", description: "Turn your Hurra cloud into a media server. Stream all your downloaded files to your phone directly from Hurra cloud using Plex")
    ]),

    SouqCollection(name: "Made by Hurra", description: "Apps made by Hurra to enhance your cloud experience", apps: [
      SouqApp(imageUrl: "https://s3.amazonaws.com/public.guestbot.co/plex.png", name :"Plex Media Server", description: "Turn your Hurra cloud into a media server. Stream all your downloaded files to your phone directly from Hurra cloud using Plex"),
      SouqApp(imageUrl: "https://s3.amazonaws.com/public.guestbot.co/plex.png", name :"Plex Media Server", description: "Turn your Hurra cloud into a media server. Stream all your downloaded files to your phone directly from Hurra cloud using Plex"),
      SouqApp(imageUrl: "https://s3.amazonaws.com/public.guestbot.co/plex.png", name :"Plex Media Server", description: "Turn your Hurra cloud into a media server. Stream all your downloaded files to your phone directly from Hurra cloud using Plex"),
      SouqApp(imageUrl: "https://s3.amazonaws.com/public.guestbot.co/plex.png", name :"Plex Media Server", description: "Turn your Hurra cloud into a media server. Stream all your downloaded files to your phone directly from Hurra cloud using Plex")
    ])

  ];

  @override
  Widget build(BuildContext context) {
    List<BaseListItemWidget> itemsList = [];
    collections.forEach((element) {
      itemsList.add(element);
      itemsList.addAll(element.apps);
    });
    return ListView.builder(
        itemCount: itemsList.length,
        itemBuilder: (context, index) => itemsList[index].build(context)
    );
  }
}


