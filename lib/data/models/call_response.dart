class Call {
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  bool? hasDialled;
  String? type;

  Call({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.channelId,
    this.hasDialled,
    this.type,
  });

  Map<String, dynamic> toMap() => {
        'callerId': callerId,
        'callerName': callerName,
        'callerPic': callerPic,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'receiverPic': receiverPic,
        'channelId': channelId,
        'hasDialled': hasDialled,
        'type:': type,
      };

  Call.fromMap(Map<String, dynamic> callMap) {
    callerId = callMap['callerId'];
    callerName = callMap['callerName'];
    callerPic = callMap['callerPic'];
    receiverId = callMap['receiverId'];
    receiverName = callMap['receiverName'];
    receiverPic = callMap['receiverPic'];
    channelId = callMap['channelId'];
    hasDialled = callMap['hasDialled'];
    type = callMap['type'];
  }
}