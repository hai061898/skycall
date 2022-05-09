import 'package:flutter/material.dart';
import 'package:skype_c/data/local_db/repository/log_repository.dart';
import 'package:skype_c/data/models/log_response.dart';
import 'package:skype_c/ui/screen/chat/components/cached_image.dart';
import 'package:skype_c/ui/screen/chat/components/quiet_box.dart';
import 'package:skype_c/ui/widgets/tile_c.dart';
import 'package:skype_c/utils/string_c.dart';
import 'package:skype_c/utils/utils.dart';

class LogListContainer extends StatefulWidget {
  const LogListContainer({Key? key}) : super(key: key);

  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  getIcon(String callStatus) {
    Icon _icon;
    double _iconSize = 15;

    switch (callStatus) {
      case CALL_STATUS_DIALLED:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;

      case CALL_STATUS_MISSED:
        _icon = Icon(
          Icons.call_missed,
          size: _iconSize,
          color: Colors.red,
        );
        break;

      default:
        _icon = Icon(
          Icons.call_received,
          size: _iconSize,
          color: Colors.grey,
        );
    }

    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: LogRepository.getLogs(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            List<dynamic> logList = snapshot.data;
            if (logList.isNotEmpty) {
              return ListView.builder(
                itemCount: logList.length,
                itemBuilder: (context, index) {
                  Log _log = logList[index];
                  bool hasDialled = _log.callStatus == CALL_STATUS_DIALLED;
                  return CustomTile(
                    leading: CachedImage(
                      hasDialled ? _log.receiverPic : _log.callerPic,
                      isRound: true,
                      radius: 45,
                    ),
                    mini: false,
                    title: Text(
                      hasDialled ? _log.receiverName : _log.callerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    icon: getIcon(_log.callStatus),
                    subtitle: Text(
                      Utils.formatDateString(_log.timestamp),
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    onLongPress: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete this log'),
                        content: const Text('Are you sure to delete this log?'),
                        actions: [
                          TextButton(
                            child: const Text('YES'),
                            onPressed: () async {
                              Navigator.maybePop(context);
                              await LogRepository.deleteLogs(index);
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                          TextButton(
                            child: const Text('No'),
                            onPressed: () async {
                              Navigator.maybePop(context);
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return QuietBox(
              heading: 'This is where all your logs are listed',
              subtitle: 'Calling pepole all over the world with just one click',
            );
          }
          return const Text('No call logs');
        });
  }
}