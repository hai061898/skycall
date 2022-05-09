import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_c/data/firebase/call_methods.dart';
import 'package:skype_c/data/models/call_response.dart';
import 'package:skype_c/provider/user_provider.dart';
import 'package:skype_c/ui/screen/call/pickup/pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  // ignore: use_key_in_widget_constructors
  PickupLayout({
    required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    // ignore: unnecessary_null_comparison
    return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: userProvider.getUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                Call call =
                    Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);
                if (call.hasDialled!) {
                  return PickupScreen(call: call);
                }
                return scaffold;
              }
              return scaffold;
            },
          )
        : const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
