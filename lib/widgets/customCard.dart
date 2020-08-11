import 'package:flutter/material.dart';
import '../theme.dart';

class CustomCard extends StatelessWidget {
  final Widget content;
  final EdgeInsets padding;
  CustomCard(this.content, this.padding);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 7),
        // width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(color: colors['accent-light'], width: 3),
          color: Colors.white,
        ),
        child: content);
  }
}
