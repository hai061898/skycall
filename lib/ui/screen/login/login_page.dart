import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skype_c/data/firebase/auth_methods.dart.dart';
import 'package:skype_c/ui/screen/home/home_page.dart';
import 'package:skype_c/ui/themes/universal_variables.dart';
import 'package:shimmer/shimmer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: Stack(
        children: [
          Center(
            child: loginButton(),
          ),
          isLoginPressed
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container()
        ],
      ),
    );
  }

  Widget loginButton() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: UniversalVariables.senderColor,
      child: TextButton(
        style: TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'LOGIN',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        onPressed: () => performLogin(),
      ),
    );
  }

  void performLogin() {
    // ignore: avoid_print
    print('tring to perfrom login');

    setState(() {
      isLoginPressed = true;
    });

    _authMethods.signIn().then((User? user) {
      // ignore: unnecessary_null_comparison
      if (user != null) {
        authenicateUser(user);
      } else {
        // ignore: avoid_print
        print('There was an error');
      }
    });
  }

  void authenicateUser(User user) {
    _authMethods.authenicateUser(user).then((isNewUser) {
      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        _authMethods.addDataToDb(user).then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              return const HomeScreen();
            }),
          );
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return const HomeScreen();
          }),
        );
      }
    });
  }
}
