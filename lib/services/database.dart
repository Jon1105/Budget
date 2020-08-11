import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../main.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  CollectionReference accountReference;
  // CollectionReference spendableReference;
  String uid;
  DatabaseService(this.uid) {
    accountReference = Firestore.instance.collection(uid);
    // spendableReference = Firestore.instance.collection('spendable - $uid');
  }

  Stream<List<User>> get accountUsers {
    return accountReference
        .orderBy('isAdmin', descending: true)
        .snapshots()
        .map<List<User>>((QuerySnapshot snapshot) {
      List<User> users = [];
      for (DocumentSnapshot doc in snapshot.documents) {
        if (doc.data['name'] == 'spendable') continue;
        users.add(User(
          doc.data['id'],
          name: doc.data['name'],
          isAdmin: doc.data['isAdmin'] ?? false,
          purchases: doc.data['purchases'],
        ));
      }
      return users;
    });
  }

  Stream<List<int>> get spendable {
    return accountReference.document('spendable').snapshots().map<List<int>>(
        (DocumentSnapshot document) =>
            [document.data['admin'], document.data['child']]);
  }

  Future<void> setSpendable(int adminSpendable, int childSpendable) async =>
      await accountReference
          .document('spendable')
          .setData({'child': childSpendable, 'admin': adminSpendable});

  Future newAccountUser({@required String name, @required bool isAdmin}) async {
    String id = Uuid().v4();

    return await accountReference.document(id).setData({
      'id': id,
      'name': firstUpper(name), // first letter of name is capitalized
      'isAdmin': isAdmin,
      'purchases': []
    });
  }

  Future updateAccountInfo(
      {@required String id, String name, bool isAdmin, bool del: false}) async {
    return del
        ? await accountReference.document(id).delete()
        : await accountReference.document(id).updateData({
            'name': name,
            'isAdmin': isAdmin,
          });
  }

  Future editUserName({@required String id, @required String newName}) async =>
      await accountReference.document(id).updateData({'name': newName});

  Future updateAccountPurchases({
    @required String id,
    bool del: false,
    Map purchase,
  }) async {
    String priceReturn;
    if (purchase['price'].toString().contains('.')) {
      priceReturn = num.parse(purchase['price']).toStringAsFixed(2);
    } else {
      priceReturn = purchase['price'];
    }

    if (del)
      await accountReference.document(id).updateData({
        'purchases': FieldValue.arrayRemove([
          {
            'name': purchase['name'],
            'price': priceReturn.replaceAll(' ', ''),
            'date': purchase['date']
          }
        ])
      });
    else
      await accountReference.document(id).updateData({
        'purchases': FieldValue.arrayUnion([
          {
            'name': purchase['name'],
            'price': priceReturn.replaceAll(' ', ''),
            'date': purchase['date']
          }
        ])
      });
  }
}
