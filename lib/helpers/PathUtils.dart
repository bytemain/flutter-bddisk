class PathUtils {
  static String basename(String filePath) {
    var index = filePath.lastIndexOf("/");
    if (index == 0) return "根目录";
    return filePath.substring(index + 1);
  }

  static String basenameWithoutExtension(String filePath) {
    return PathUtils.basename(filePath);
  }

  static String dirname(String filePath) {
    var index = filePath.lastIndexOf("/");
    if (index == 0) return "/";
    return filePath.substring(0, index);
  }
}
