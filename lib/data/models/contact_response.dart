import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  String? uid;
  Timestamp? addedOn;

  Contact({
    this.uid,
    this.addedOn,
  });

  Map<String, dynamic> toMap(Contact senderContact) => {
        'uid': uid,
        'added_on': addedOn,
      };

  factory Contact.fromMap(Map<String, dynamic> mapData) => Contact(
        uid: mapData['uid'],
        addedOn: mapData['added_on'],
      );
}