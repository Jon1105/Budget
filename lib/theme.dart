import 'package:flutter/material.dart';

var appBarText = TextStyle(fontSize: 25, fontFamily: 'UbuntuBold');

var cardTitle = TextStyle(
  fontSize: 20,
  fontFamily: 'UbuntuMed',
);

var linkText = TextStyle(
  color: Colors.blue,
  decoration: TextDecoration.underline,
  fontSize: 15,
);

var promptTitle = TextStyle(
  fontFamily: 'UbuntuMed',
  fontSize: 20,
  fontWeight: FontWeight.w700,
);

var bodyText = TextStyle();

var italicBodyText = TextStyle(fontFamily: 'UbuntuItalic');

var boldBodyText =
    TextStyle(fontFamily: 'UbuntuBold', color: colors['primary-dark']);

var promptSubmitText = TextStyle(
  fontFamily: 'UbuntuMedItalic',
  color: Colors.blue,
);

var mainPriceText = TextStyle(
  color: colors['accent'],
  fontSize: 20,
);

var drawerItemText = TextStyle(
  fontFamily: 'UbuntuMed',
  fontSize: 20,
);

var errorText = TextStyle(
  color: Colors.red,
);

var dropdownItemText = TextStyle(
  color: Colors.grey,
  fontSize: 16,
);

var hintTextStyle = TextStyle(
  color: Colors.grey[600],
  fontSize: 16,
);

Map<String, Color> colors = {
  'primary': Color(0xFF33a3a3),
  'primary-light': Color(0xFF40cfcf),
  'primary-dark': Color(0xFF2c8a8a),
  'accent': Color(0xFF571fab),
  'accent-light': Color(0xFF8159bd),
  'accent-dark': Color(0xFF4a0aab),
};
