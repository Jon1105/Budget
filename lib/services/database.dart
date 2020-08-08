import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../main.dart';
import 'package:uuid/uuid.dart';

class DatabaseService {
  CollectionReference accountReference;
  CollectionReference spendableReference;
  String uid;
  DatabaseService(this.uid) {
    accountReference = Firestore.instance.collection('account - $uid');
    spendableReference = Firestore.instance.collection('spendable - $uid');
  }

  List<User> _usersFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      var sorted = doc.data['purchases'];
      // sorted = sorted
      //     .sort((a, b) => a['date'].toDate().compareTo((b['date'].toDate())));
      return User(doc.data['id'],
          name: doc.data['name'],
          isAdmin: doc.data['isAdmin'] ?? false,
          purchases: sorted);
    }).toList();
  }

  Stream<List<User>> get accountUsers {
    return accountReference
        .orderBy('isAdmin', descending: true)
        .snapshots()
        .map(_usersFromSnapshot);
  }

  List<int> _spendableListFromDocument(QuerySnapshot snapshot) {
    return snapshot.documents
        .map((doc) {
          return doc.data['val'];
        })
        .cast<int>()
        .toList();
  }

  Stream<List<int>> get spendable {
    return spendableReference.snapshots().map(_spendableListFromDocument);
  }

  Future setSpendable(int adminSpendable, int childSpendable) async {
    spendableReference
        .document('adminSpendable')
        .setData({'val': adminSpendable});
    spendableReference
        .document('childSpendable')
        .setData({'val': childSpendable});
  }

  Future newAccountUser({@required String name, @required bool isAdmin}) async {
    String id = Uuid().v4();

    return await accountReference.document('user - $id').setData({
      'id': id,
      'name': firstUpper(name), // first letter of name is capitalized
      'isAdmin': isAdmin,
      'purchases': []
    });
  }

  Future updateAccountInfo(
      {@required String id, String name, bool isAdmin, bool del: false}) async {
    return del
        ? await accountReference.document('user - $id').delete()
        : await accountReference.document('user - $id').updateData({
            'name': name,
            'isAdmin': isAdmin,
          });
  }

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

    return !del
        ? await accountReference.document('user - $id').updateData({
            'purchases': FieldValue.arrayUnion([
              {
                'name': purchase['name'],
                'price': priceReturn.replaceAll(' ', ''),
                'date': purchase['date']
              }
            ])
          })
        : await accountReference.document('user - $id').updateData({
            'purchases': FieldValue.arrayRemove([
              {
                'name': purchase['name'],
                'price': priceReturn.replaceAll(' ', ''),
                'date': purchase['date']
              }
            ])
          });
  }
}
