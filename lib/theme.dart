import 'package:flutter/material.dart';

TextStyle appBarText = TextStyle(fontSize: 25, fontFamily: 'UbuntuBold');

TextStyle cardTitle = TextStyle(
  fontSize: 20,
  fontFamily: 'UbuntuMed',
);

TextStyle linkText = TextStyle(
  color: Colors.blue,
  decoration: TextDecoration.underline,
  fontSize: 15,
);

TextStyle promptTitle = TextStyle(
  fontFamily: 'UbuntuMed',
  fontSize: 20,
  fontWeight: FontWeight.w700,
);

TextStyle bodyText = TextStyle();

TextStyle italicBodyText = TextStyle(fontFamily: 'UbuntuItalic');

TextStyle boldBodyText =
    TextStyle(fontFamily: 'UbuntuBold', color: colors['primary']);

TextStyle promptSubmitText = TextStyle(
  fontFamily: 'UbuntuMedItalic',
  color: Colors.blue,
);

TextStyle mainPriceText = TextStyle(
  color: colors['accent'],
  fontSize: 20,
);

TextStyle drawerItemText = TextStyle(
  fontFamily: 'UbuntuMed',
  fontSize: 20,
);

TextStyle errorText = TextStyle(
  color: Colors.red,
);

TextStyle dropdownItemText = TextStyle(
  color: Colors.grey,
  fontSize: 16,
);

TextStyle hintTextStyle = TextStyle(
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
