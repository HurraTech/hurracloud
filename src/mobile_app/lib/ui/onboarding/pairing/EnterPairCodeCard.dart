import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void PairCodeCallback(int pairCode);
enum PairStatus { INPUTTING, PAIRING, PAIR_ERROR }

class EnterPairCodeCard extends StatelessWidget {
  PairCodeCallback onCodeEntered;
  PairStatus pairStatus = PairStatus.INPUTTING;

  EnterPairCodeCard({this.onCodeEntered, this.pairStatus});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Image(image: AssetImage('assets/findcomputer.png'))),
              Expanded(
                  flex: 3,
                  child: Column(children: [
                    Text(
                        "Enter the four digits code that is displayed on your computer to pair with your phone",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xff333333),
                            fontSize: 17,
                            fontWeight: FontWeight.normal)),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                          autofocus: true,
                          enabled: pairStatus != PairStatus.PAIRING,
                          onChanged: (text) {
                            if (text.length == 4) {
                              onCodeEntered(int.parse(text));
                            }
                          },
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              letterSpacing: 50,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(4),
                          ]),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: pairStatus == PairStatus.INPUTTING
                          ? SizedBox(height: 40)
                          : pairStatus == PairStatus.PAIRING
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey))
                              : Text(
                                  "Unable to pair, please check the pair code",
                                  style: TextStyle(color: Colors.red),
                                ),
                    )
                  ]))
            ],
          ),
        ),
      );
}
