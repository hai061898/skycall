import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skype_c/data/firebase/firebase_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  FirebaseRepository repository = FirebaseRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loginButton(),
    );
  }

  Widget loginButton() {
    return TextButton(
      child: const Text(
        "LOGIN",
        style: TextStyle(
            fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.2),
      ),
      onPressed: () => performLogin(),
    );
  }

  void performLogin() {
    // ignore: avoid_print
    print("tring to perform login");
    repository.signIn().then((User user) {
      // ignore: unnecessary_null_comparison
      if (user != null) {
        authenticateUser(user);
      } else {
        // ignore: avoid_print
        print("There was an error");
      }
    });
  }

  void authenticateUser(User user) {
    repository.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        repository.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
