
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skype_c/data/method/firebase_methods.dart';

class FirebaseRepository {
  // ignore: prefer_final_fields
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<User> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<UserCredential> signIn() => _firebaseMethods.signIn();

  Future<bool> authenticateUser(User user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> addDataToDb(User user) => _firebaseMethods.addDataToDb(user);
}