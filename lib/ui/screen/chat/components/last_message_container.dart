
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skype_c/data/models/message_response.dart';

class LastMessageContainer extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final stream;

  // ignore: use_key_in_widget_constructors
  const LastMessageContainer({required this.stream});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data!.docs;

          if (docList.isNotEmpty) {
            Message message = Message.fromMap(docList.last.data() as Map<String,dynamic>);
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                message.message!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            );
          }

          return const Text(
            'No message',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          );
        }
        return const Text(
          '..',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        );
      },
    );
  }
}