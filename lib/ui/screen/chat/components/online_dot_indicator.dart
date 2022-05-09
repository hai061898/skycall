import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skype_c/data/enum/user_state.dart';
import 'package:skype_c/data/firebase/auth_methods.dart.dart';
import 'package:skype_c/utils/utils.dart';
import 'package:skype_c/data/models/use_respone.dart' as model;

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  final AuthMethods _authMethods = AuthMethods();

  OnlineDotIndicator({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getColor(int? state) {
      switch (Utils.numToState(state!)) {
        case UserState.Offline:
          return Colors.red;

        case UserState.Online:
          return Colors.green;

        default:
          return Colors.orange;
      }
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _authMethods.getUserStream(uid: uid),
      builder: (context, snapshot) {
        model.User? user;
        if (snapshot.hasData && snapshot.data!.data() != null) {
          user =
              model.User.fromMap(snapshot.data!.data() as Map<String, dynamic>);
        }

        return Container(
          height: 10,
          width: 10,
          margin: const EdgeInsets.only(right: 5, top: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: getColor(user!.state!),
          ),
        );
      },
    );
  }
}
