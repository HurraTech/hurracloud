import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
const int hurraMainColorHex = 0xff792333;
const Color hurraMainColor = Color(hurraMainColorHex);
const Color settingIconsColor = Color(hurraMainColorHex);

const Color hurraAppBackgroundColor = Color(0xffeeeeee);
const  Color hurraTabBackgroundColor = Color(0xffffffff);
const double horizontalContentPadding = 10.0;

const  Map<int, Color> color =
{
  50:Color.fromRGBO(121,35,51, .1),
  100:Color.fromRGBO(121,35,51, .2),
  200:Color.fromRGBO(121,35,51, .3),
  300:Color.fromRGBO(121,35,51, .4),
  400:Color.fromRGBO(121,35,51, .5),
  500:Color.fromRGBO(121,35,51, .6),
  600:Color.fromRGBO(121,35,51, .7),
  700:Color.fromRGBO(121,35,51, .8),
  800:Color.fromRGBO(121,35,51, .9),
  900:Color.fromRGBO(121,35,51, 1),
};
MaterialColor hurraColor = MaterialColor(hurraMainColorHex, color);

bool isiOSStyle = !Platform.isAndroid;
