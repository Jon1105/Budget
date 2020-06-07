import 'database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future signIn(String email, String password) async {
    try {
      var result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (error) {
      return null;
    }
  }

  Future signUp(String email, String password, String username) async {
    try {
      var result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      DatabaseService(result.user.uid).setSpendable(10000, 8500);
      DatabaseService(result.user.uid).newAccountUser(
        name: email.substring(0, email.indexOf('@')),
        isAdmin: true,
      );
      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future signOut() async {
    try {
      return await auth.signOut();
    } catch (error) {
      return null;
    }
  }
}
