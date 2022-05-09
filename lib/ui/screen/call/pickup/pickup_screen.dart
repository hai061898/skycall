import 'package:flutter/material.dart';
import 'package:skype_c/data/firebase/call_methods.dart';
import 'package:skype_c/data/local_db/repository/log_repository.dart';
import 'package:skype_c/data/models/call_response.dart';
import 'package:skype_c/data/models/log_response.dart';
import 'package:skype_c/ui/helpers/permissions.dart';
import 'package:skype_c/ui/screen/call/call_page.dart';
import 'package:skype_c/ui/screen/call/phone_call_page.dart';
import 'package:skype_c/ui/screen/chat/components/cached_image.dart';
import 'package:skype_c/utils/string_c.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  const PickupScreen({Key? key,required this.call}):super(key: key);

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();
  bool isCallMissed = true;

  addToLocalStorage({required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    LogRepository.addLogs(log);
  }

  @override
  void dispose() {
    super.dispose();
    if (isCallMissed) addToLocalStorage(callStatus: CALL_STATUS_MISSED);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Incoming...',
              style:  TextStyle(
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 50),
            CachedImage(
              widget.call.callerPic!,
              isRound: true,
              radius: 180,
            ),
            const SizedBox(height: 15),
            Text(
              widget.call.callerName!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    addToLocalStorage(callStatus: CALL_STATUT_RECEIVED);
                    await callMethods.endCall(call: widget.call);
                    isCallMissed = false;
                  },
                ),
                const SizedBox(width: 25),
                IconButton(
                    icon: const Icon(Icons.call),
                    color: Colors.green,
                    onPressed: () async {
                      isCallMissed = false;
                      addToLocalStorage(callStatus: CALL_STATUT_RECEIVED);
                      await Permissions.cameraAndMicrophonePermissionsGranted()
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    widget.call.type == 'video'
                                        ? CallScreen(call: widget.call)
                                        : PhoneCallScreen(call: widget.call),
                              ),
                            )
                          : {};
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}