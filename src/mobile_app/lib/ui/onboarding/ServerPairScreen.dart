import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nsd/flutter_nsd.dart';
import 'package:mobile_app/HurraStyle.dart';
import 'package:mobile_app/ui/onboarding/OnboardingCompleteScreen.dart';
import 'package:mobile_app/ui/onboarding/pairing/FindDeviceInstructionsCard.dart';

import 'pairing/EnterPairCodeCard.dart';
import 'pairing/FindDeviceCard.dart';
import 'pairing/SearchingDeviceCard.dart';


enum SearchState { INITIAL, FINDING, DISCOVERED, PAIR_CODE, PAIRING, PAIR_ERROR }
class DiscoveredDevice {
  final String name;
  final String hostname;
  final int port;

  DiscoveredDevice({this.name, this.hostname, this.port});
}

class ServerPairScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ServerPairScreenState();
}


class ServerPairScreenState extends State<ServerPairScreen> {

  SearchState currentState = SearchState.INITIAL;

  final flutterNsd = FlutterNsd();
  List<DiscoveredDevice> discoveredDevices = [];
  DiscoveredDevice selectedDevice;

  void initNsd() async {
    final stream = flutterNsd.stream;
    await for (final nsdServiceInfo in stream) {
      print('Discovered service name: ${nsdServiceInfo.name}');
      print('Discovered service hostname/IP: ${nsdServiceInfo.hostname}');
      print('Discovered service port: ${nsdServiceInfo.port}');
    }
  }

  void onSearchClicked() {
    setState(() {
      currentState = SearchState.PAIR_CODE;
    });
  }

  void onCodeEntered(code) async {
    setState((){
      currentState = SearchState.PAIRING;
    });
    await Future.delayed(Duration(seconds: 1));
    // setState((){
    //   currentState = SearchState.PAIR_ERROR;
    // });
    Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => OnboardingCompleteScreen()),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        ),
        backgroundColor: Color(0xfff2f2f2),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            heightFactor: 1,
            child: Column(
              children: [
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Text("Ok, let’s set up your computer",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ),
                SizedBox(height: 15),
                FindDeviceInstructionsCard(),
                SizedBox(height: 20),
                Expanded(child: currentState == SearchState.INITIAL ? FindDeviceCard(onSearchClicked:onSearchClicked) :
                [SearchState.PAIR_CODE, SearchState.PAIRING, SearchState.PAIR_ERROR].contains(currentState)  ?  EnterPairCodeCard(onCodeEntered: onCodeEntered, pairStatus:
                      currentState == SearchState.PAIR_CODE ? PairStatus.INPUTTING :
                      currentState == SearchState.PAIRING ? PairStatus.PAIRING : PairStatus.PAIR_ERROR)
                  : SizedBox(height:30)
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ));
  }
}
