// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skype_c/data/local_db/interface/log_interface.dart';
import 'package:skype_c/data/models/log_response.dart';

class HiveMethods implements LogInterface {
  String hive_box = '';

  @override
  openDb(dbName) => (hive_box = dbName);

  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  @override
  addLogs(Log log) async {
    var box = await Hive.openBox(hive_box);
    var logMap = log.toMap();
    logMap['log_id'] = box.length + 1;
    int idOfInput = await box.add(logMap);

    close();
    return idOfInput;
  }

  updateLogs(int i, Log newLog) async {
    var box = await Hive.openBox(hive_box);

    var newLogMap = newLog.toMap();

    box.put(i, newLogMap);

    close();
  }

  @override
  Future<List<Log>> getLogs() async {
    var box = await Hive.openBox(hive_box);

    List<Log> logList = [];

    for (int i = 0; i < box.length; i++) {
      var logMap = box.getAt(i);
      logList.add(Log.fromMap(logMap));
    }
    return logList;
  }

  @override
  deleteLogs(int logId) async {
    var box = await Hive.openBox(hive_box);
    await box.deleteAt(logId);
  }

  @override
  close() => Hive.close();
}
