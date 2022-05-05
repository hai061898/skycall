import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? senderId;
  String? receiverId;
  String? type;
  String? message;
  Timestamp? timestamp;
  String? photoUrl;

  Message({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
  });

  Message.imageMessage({
    this.senderId,
    this.receiverId,
    this.type,
    this.message,
    this.timestamp,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'type': type,
        'message': message,
        'timestamp': timestamp,
      };

  Map<String, dynamic> toImageMap() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'type': type,
        'message': message,
        'photoUrl': photoUrl,
        'timestamp': timestamp,
      };

  Message.fromMap(Map<String, dynamic> map) {
    senderId = map['senderId'];
    receiverId = map['receiverId'];
    type = map['type'];
    message = map['message'];
    timestamp = map['timestamp'];
    photoUrl = map['photoUrl'];
  }
}
