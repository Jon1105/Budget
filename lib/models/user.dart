import 'package:Budget/main.dart';
import 'package:flutter/foundation.dart';

class User {
  String id;
  final String name;
  final bool isAdmin;
  final List purchases;
  double total = 0;
  double spent = 0;

  User(this.id,
      {@required this.name, @required this.isAdmin, @required this.purchases}) {
    this.purchases.sort((a, b) {
      return b['date'].toDate().compareTo(a['date'].toDate());
    });
    this.purchases.forEach((purchase) {
      if (purchase['price'].contains('-')) {
        total += -num.parse(purchase['price'].substring(1));
      } else {
        total += num.parse(purchase['price']);
        spent += num.parse(purchase['price']);
      }
    });
    total = toDecimalPlaces(total, 2);
  }
}
