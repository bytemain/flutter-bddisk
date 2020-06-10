import 'package:intl/intl.dart';

class Utils {
  static getDataTime(int serverCTime) {
    var date = new DateTime.fromMillisecondsSinceEpoch(serverCTime * 1000);
    var formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String formatted = formatter.format(date);
    return formatted;
  }

  static getParentPath(String currPath) {
    var index = currPath.lastIndexOf("/");
    if (index == 0) return "/";
    return currPath.substring(0, index);
  }

  static getCurrPathFilename(String currPath) {
    var index = currPath.lastIndexOf("/");
    if (index == 0) return "根目录";
    return currPath.substring(index);
  }
}
