import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skype_c/data/firebase/call_methods.dart';
import 'package:skype_c/data/local_db/repository/log_repository.dart';
import 'package:skype_c/data/models/call_response.dart';
import 'package:skype_c/data/models/log_response.dart';
import 'package:skype_c/data/models/use_respone.dart';
import 'package:skype_c/utils/string_c.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({required User from, required User to, context, type}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
      type: type,
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      LogRepository.addLogs(log);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => type == CALL_TYPE_VIDEO
                ? CallScreen(call: call)
                : PhoneCallScreen(call: call)),
      );
    }
  }
}
