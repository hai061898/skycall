// ignore_for_file: await_only_futures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype_c/data/enum/user_state.dart';
import 'package:skype_c/utils/string_c.dart';
import 'package:skype_c/data/models/use_respone.dart' as model;
import 'package:skype_c/utils/utils.dart';

class AuthMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = (await _auth.currentUser)!;
    return currentUser;
  }

  Future<model.User> getUserDetails() async {
    User currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser.uid).get();

    return model.User.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  }

  Future<model.User?> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(id).get();
      return model.User.fromMap(
          documentSnapshot.data() as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return null;
    }
  }

  Future<User?> signIn() async {
    GoogleSignInAccount? _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthenication =
        await _signInAccount!.authentication;

    final AuthCredential authCredential = GoogleAuthProvider.credential(
      accessToken: _signInAuthenication.accessToken,
      idToken: _signInAuthenication.idToken,
    );
    final credential = await _auth.signInWithCredential(authCredential);
    return credential.user;
  }

  Future<bool> authenicateUser(User user) async {
    QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    //if user is registered then length of list > 0 or else less than 0
    return docs.isEmpty ? true : false;
  }

  Future<void> addDataToDb(User currentUser) async {
    String? token = await FirebaseMessaging.instance.getToken();
    String username = Utils.getUsername(currentUser.email!);

    model.User user = model.User(
      uid: currentUser.uid,
      name: currentUser.displayName,
      email: currentUser.email,
      profilePhoto: currentUser.photoURL,
      username: username,
    );

    Map<String, dynamic> userMap = user.toMap();
    userMap.addAll({'fcm_token': token});

    firestore.collection(USERS_COLLECTION).doc(currentUser.uid).set(userMap);
  }

  Future<List<model.User>> fetchAllUsers(User currentUser) async {
    List<model.User> userList = <model.User>[];

    QuerySnapshot querySnapshot =
        await firestore.collection(USERS_COLLECTION).get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if ((querySnapshot.docs[i].data()! as Map)['uid'] != currentUser.uid) {
        userList.add(model.User.fromMap(
            querySnapshot.docs[i].data() as Map<String, dynamic>));
      }
    }
    return userList;
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return false;
    }
  }

  void setUserState({required String userId, required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.doc(userId).update({'state': stateNum});
  }

  Stream<DocumentSnapshot> getUserStream({required String uid}) =>
      _userCollection.doc(uid).snapshots();
}
