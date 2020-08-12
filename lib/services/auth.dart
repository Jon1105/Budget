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

  Future<FirebaseUser> signUp(String email, String password) async {
    try {
      AuthResult result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      DatabaseService(result.user.uid).setSpendable(-1, -1);
      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async => await auth.signOut();
}
