
import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top:BorderSide(color:Color(0xffcccccc)),
                  bottom:BorderSide(color:Color(0xffcccccc))
              )
          ),
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Image.asset("assets/search.png",scale: 1.7),
                ),
                border: InputBorder.none,
                hintText: "Type to search your cloud for files, photos, data, apps",
                contentPadding:
                EdgeInsets.only(left: 20, right: 10,top:14)),
          ),
        ));
  }
}
