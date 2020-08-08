import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../theme.dart';
import '../models/user.dart';

@deprecated
class UserChart extends StatelessWidget {
  final User user;

  UserChart(this.user);

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> _sections = [];

    Map _totals = {};

    for (var catList in categories) {
      _totals[catList[0]] = 0;
    }
    for (var purchase in user.purchases) {
      _totals[purchase['category']] += ((double.parse(purchase['price']) > 0)
          ? double.parse(purchase['price'])
          : 0);
    }

    for (var catList in categories) {
      if (_totals[catList[0]] != 0) {
        _sections.add(PieChartSectionData(
            title: catList[0],
            titleStyle: TextStyle(color: Colors.black),
            showTitle: false,
            color: catList[2],
            value: _totals[catList[0]].abs(),
            // value: 0.5,
            radius: 50));
      }
    }
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text(
          'Spendings',
          style: cardTitle,
        ),
        Row(
          children: <Widget>[
            Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: categories.map((catList) {
                    return (catList[0] != 'gain' && _totals[catList[0]] != 0)
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(children: <Widget>[
                              CircleAvatar(
                                backgroundColor: catList[2],
                                radius: 10,
                              ),
                              SizedBox(width: 5),
                              Text(firstUpper(catList[0]))
                            ]),
                          )
                        : Container();
                  }).toList(),
                )),
            Expanded(
                flex: 5,
                child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: <Widget>[
                        PieChart(PieChartData(
                            borderData: FlBorderData(show: false),
                            sections: _sections,
                            centerSpaceRadius: 50,
                            sectionsSpace: 0,
                            startDegreeOffset: 0)),
                        Center(
                          child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // color: Colors.red,
                              ),
                              child: Center(
                                  child: Text((user.spent == user.total)
                                      ? ''
                                      : '\$${user.spent}'))),
                        )
                      ],
                    )))
          ],
        ),
      ],
    );
  }
}
