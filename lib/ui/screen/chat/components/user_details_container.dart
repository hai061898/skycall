import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_c/data/firebase/auth_methods.dart.dart';
import 'package:skype_c/provider/user_provider.dart';
import 'package:skype_c/data/models/use_respone.dart' as model;
import 'package:skype_c/ui/screen/chat/components/logo.dart';
import 'package:skype_c/ui/screen/login/login_page.dart';
import 'package:skype_c/ui/widgets/appbar_c.dart';

import 'cached_image.dart';

class UserDetailsContainer extends StatelessWidget {
  const UserDetailsContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    signOut() async {
      final bool isLoggedOut = await AuthMethods().signOut();

      if (isLoggedOut) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          CustomAppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: const ShimmeringLogo(),
            actions: [
              TextButton(
                onPressed: () => signOut(),
                child: const Text(
                  'SignOut',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          ),
          const UserDetailsBody()
        ],
      ),
    );
  }
}

class UserDetailsBody extends StatelessWidget {
  const UserDetailsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final model.User user = userProvider.getUser;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          CachedImage(user.profilePhoto!, isRound: true, radius: 50),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name!,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }
}