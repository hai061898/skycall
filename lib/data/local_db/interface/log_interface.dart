import 'package:skype_c/data/models/log_response.dart';

abstract class LogInterface {
  init();

  openDb(dbName);

  addLogs(Log log);

  Future<List<Log>> getLogs();

  deleteLogs(int logId);

  close();
}
