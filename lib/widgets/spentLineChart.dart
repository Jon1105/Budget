import 'package:flutter/material.dart';
import '../theme.dart';

class LineChart extends StatelessWidget {
  final double y;
  final double total;
  LineChart({@required this.y, @required this.total});

  @override
  Widget build(BuildContext context) {
    bool gained = (y < 0) ? true : false;
    return Container(
      // height: 60,
      width: 15,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(220, 220, 220, 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FractionallySizedBox(
            heightFactor: gained
                ? 1
                : (y / total < 0.05 && y / total > 0) ? 0.05 : y / total,
            child: Container(
                decoration: BoxDecoration(
              color: gained ? Colors.lightGreen : colors['primary'],
              borderRadius: BorderRadius.circular(10),
            )),
          )
        ],
      ),
    );
  }
}
