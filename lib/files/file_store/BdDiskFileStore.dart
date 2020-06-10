import 'package:bddisk/files/file_store/FileStore.dart';
import 'package:bddisk/helpers/BdDiskApiClient.dart';
import 'package:bddisk/models/DiskFile.dart';

class BdDiskFileStore extends FileStore {
  final BdDiskApiClient apiClient;

  BdDiskFileStore({BdDiskApiClient apiClient}) : this.apiClient = apiClient ?? BdDiskApiClient();

  @override
  Future<List<DiskFile>> list(String dir, {String order = 'name', int start = 0, int limit = 1000}) {
    return apiClient.getListFile(dir, order: order, start: start, limit: limit);
  }

  @override
  Future<List<DiskFile>> search(String key, {String dir = "/", int recursion = 1, int page = 1, int num = 1000}) {
    return apiClient.getSearchFile(key, dir: dir, recursion: recursion.toString(), page: page, num: num);
  }
}
