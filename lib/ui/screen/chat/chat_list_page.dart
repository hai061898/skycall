import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_c/data/firebase/chat_methods.dart';
import 'package:skype_c/data/models/contact_response.dart';
import 'package:skype_c/provider/user_provider.dart';
import 'package:skype_c/ui/screen/chat/components/contact_view.dart';
import 'package:skype_c/ui/screen/chat/components/user_circle.dart';
import 'package:skype_c/ui/themes/universal_variables.dart';
import 'package:skype_c/ui/widgets/skype_appbar.dart';

import 'components/new_chat_button.dart';
import 'components/quiet_box.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: SkypeAppBar(
        title: const UserCircle(),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/search_screen');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: const NewChatButton(),
      body: ChatListContainer(),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();

  ChatListContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return SizedBox(
      child: StreamBuilder<QuerySnapshot>(
        stream: _chatMethods.fetchContacts(userId: userProvider.getUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var docList = snapshot.data!.docs;

            if (docList.isEmpty) {
              return QuietBox(
                heading: 'This is where all the contacts are listed',
                subtitle:
                    'Search for your friends and family to start calling or chatting with them',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: docList.length,
              itemBuilder: (context, index) {
                Contact contact = Contact.fromMap(
                    docList[index].data() as Map<String, dynamic>);

                return ContactView(contact);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
