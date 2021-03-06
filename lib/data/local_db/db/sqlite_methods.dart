import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:skype_c/data/local_db/interface/log_interface.dart';
import 'package:skype_c/data/models/log_response.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteMethods implements LogInterface {
  late Database _db;
  String databaseName = 'logoDB';
  String tableName = 'Call_Logs';

  String id = 'log_id';
  String callerName = 'caller_name';
  String callerPic = 'caller_pic';
  String receiverName = 'receiver_name';
  String receiverPic = 'receiver_pic';
  String callStatus = 'call_status';
  String timestamp = 'timestamp';

  Future<Database> get db async {
    // ignore: unnecessary_null_comparison
    if (_db != null) return _db;

    // ignore: avoid_print
    print('db was null');
    _db = await init();
    return _db;
  }

  @override
  openDb(dbName) => (databaseName = dbName);

  @override
  init() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, databaseName);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    String createTableQuery =
        "CREATE TABLE $tableName ($id INTEGER PRIMARY KEY, $callerName TEXT, $callerPic TEXT, $receiverName TEXT, $receiverPic TEXT, $callStatus TEXT, $timestamp TEXT)";

    await db.execute(createTableQuery);
    // ignore: avoid_print
    print('table created');
  }

  @override
  addLogs(Log log) async {
    var dbClient = await db;
    await dbClient.insert(tableName, log.toMap());
  }

  @override
  Future<List<Log>> getLogs() async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.rawQuery('SELECT * FROM $tableName');

      List<Log> logList = [];
      if (maps.isNotEmpty) {
        for (Map map in maps) {
          logList.add(Log.fromMap(map));
        }
      }

      return logList;
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return [];
    }
  }

  @override
  deleteLogs(int logId) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: '$id = ?', whereArgs: [logId + 1]);
  }

  updateLogs(Log log) async {
    var dbClient = await db;

    await dbClient.update(
      tableName,
      log.toMap(),
      where: '$id = ?',
      whereArgs: [log.logId],
    );
  }

  @override
  close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
