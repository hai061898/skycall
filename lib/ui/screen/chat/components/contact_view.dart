import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_c/data/firebase/auth_methods.dart.dart';
import 'package:skype_c/data/firebase/chat_methods.dart';
import 'package:skype_c/data/models/contact_response.dart';
import 'package:skype_c/data/models/use_respone.dart' as model;
import 'package:skype_c/provider/user_provider.dart';
import 'package:skype_c/ui/screen/chat/chat_page.dart';
import 'package:skype_c/ui/widgets/tile_c.dart';

import 'cached_image.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final AuthMethods _authMethods = AuthMethods();

  ContactView(this.contact, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<model.User>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          model.User? user = snapshot.data;
          return ViewLayout(contact: user!);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final model.User contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(
                    receiver: contact,
                  ))),
      title: Text(
        contact.name ?? '..',
        style:
            const TextStyle(color: Colors.white, fontFamily: "Arial", fontSize: 19),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
            senderId: userProvider.getUser.uid, receiverId: contact.uid),
      ),
      leading: Container(
        constraints: const BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.profilePhoto,
              radius: 80,
              isRound: true,
            ),
            OnlineDotIndicator(uid: contact.uid)
          ],
        ),
      ),
    );
  }
}