import 'package:bddisk/helpers/BdDiskApiClient.dart';
import 'package:bddisk/models/BdDiskFile.dart';

class BdDiskFileStore {
  final BdDiskApiClient apiClient;

  BdDiskFileStore({BdDiskApiClient apiClient}) : this.apiClient = apiClient ?? BdDiskApiClient();

  /// 获取指定 [dir] 下的文件列表
  ///
  /// [dir] 已 / 开头的绝对路径，默认为 /
  /// [order] default:name 排序字段： time name size
  /// [start] 起始位置
  /// [limit] 每页条目数
  Future<List<BdDiskFile>> list(String dir, {String order = 'name', int start = 0, int limit = 1000}) {
    return apiClient.getListFile(dir, order: order, start: start, limit: limit);
  }

  /// 搜索文件
  /// [key] 搜索关键字
  /// [dir] 搜索目录
  /// [recursion] 是否递归 1递归 0不递归
  /// [page] 页数 从1开始，缺省返回所有条目
  /// [num] 每页条目数
  Future<List<BdDiskFile>> search(String key, {String dir = "/", int recursion = 1, int page = 1, int num = 1000}) {
    return apiClient.getSearchFile(key, dir: dir, recursion: recursion.toString(), page: page, num: num);
  }
}
