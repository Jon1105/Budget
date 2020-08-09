import 'package:Budget/main.dart';

class User {
  String id;
  final String name;
  final bool isAdmin;
  final List purchases;
  double total = 0;
  double spent = 0;

  User(this.id, {this.name, this.isAdmin, this.purchases}) {
    purchases.sort((a, b) {
      return a['date'].toDate().compareTo(b['date'].toDate());
    });
    purchases.forEach((purchase) {
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
