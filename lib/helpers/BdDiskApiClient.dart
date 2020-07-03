import 'dart:convert';
import 'dart:io';

import 'package:bddisk/AppConfig.dart';
import 'package:bddisk/models/BdDiskFile.dart';
import 'package:bddisk/models/BdDiskQuota.dart';
import 'package:bddisk/models/BdDiskUser.dart';
import 'package:get/get.dart';

class BdDiskApiClient {
  final HttpClient httpClient;
  final host = "pan.baidu.com";
  final diskQuotaPath = "/api/quota";
  final userInfoPath = "/rest/2.0/xpan/nas";
  final diskFilePath = "/rest/2.0/xpan/file";
  final diskFileMetas = "/rest/2.0/xpan/multimedia";

  BdDiskApiClient({HttpClient httpClient}) : this.httpClient = httpClient ?? HttpClient();

  get accessToken async {
    var token = await AppConfig.instance.token;
    if (token == null) {
      Get.offNamedUntil("/Login", (route) => false);
      return null;
    }
    return token.accessToken;
  }

  Future<BdDiskUser> getUserInfo() async {
    HttpClientRequest request =
        await httpClient.getUrl(Uri.http(host, userInfoPath, {'method': "uinfo", 'access_token': await accessToken}));

    HttpClientResponse response = await request.close();

    var responseBody = await response.transform(Utf8Decoder()).join();
    var json = jsonDecode(responseBody);
    return BdDiskUser.fromJSON(json);
  }

  /// [path]	string	否	查询共享目录文件时需要，格式: /<share>uk-fsid，uk对应共享目录创建者ID，fsid对应共享目录的fsid
  /// [fsIds]	json array	是	fsid数组，数组中元素类型为uint64，大小上限100
  /// [thumb]	int	否	是否需要缩略图地址，0 否、1 是，默认0
  /// [dLink]	int	否	是否需要文件下载地址dlink，0 否、1 是，默认0
  /// [extra]	int	否	图片是否需要拍摄时间、原图分辨率等其他信息， 0 否、1 是，默认0
  Future<List<BdDiskFile>> getFileMetas(List<int> fsIds, {String path, int thumb, int dLink, int extra}) async {
    HttpClientRequest request = await httpClient.getUrl(Uri.http(host, diskFileMetas, {
      'method': "filemetas",
      'access_token': await accessToken,
      'fsids': jsonEncode(fsIds),
      'path': path,
      'thumb': '$thumb',
      'dlink': '$dLink',
      'extra': '$extra',
    }));

    HttpClientResponse response = await request.close();

    var responseBody = await response.transform(Utf8Decoder()).join();
    var json = jsonDecode(responseBody);
    var list = (json["list"] as List<dynamic>);
    return list.map((e) => BdDiskFile.fromJSON(e)).toList();
  }

  Future<Map<String, dynamic>> logout() async {
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(
        "https://openapi.baidu.com/rest/2.0/passport/auth/revokeAuthorization?access_token=${await accessToken}"));

    HttpClientResponse response = await request.close();

    var responseBody = await response.transform(Utf8Decoder()).join();
    var json = jsonDecode(responseBody);
    return json;
  }

  Future<BdDiskQuota> getDiskQuota() async {
    HttpClientRequest request =
        await httpClient.getUrl(Uri.http(host, diskQuotaPath, {'access_token': await accessToken}));

    HttpClientResponse response = await request.close();

    var responseBody = await response.transform(Utf8Decoder()).join();
    var json = jsonDecode(responseBody);
    return BdDiskQuota.fromJSON(json);
  }

  Future<List<BdDiskFile>> getListFile(String dir,
      {String order = 'name',
      int start = 0,
      int limit = 1000,
      String desc = '0',
      String web = '',
      int folder = 0,
      int showEmpty = 1}) async {
    HttpClientRequest request = await httpClient.getUrl(Uri.http(host, diskFilePath, {
      'method': "list",
      'access_token': await accessToken,
      'dir': dir,
      order: order,
      "start": '$start',
      "limit": '$limit',
      'desc': desc,
      "web": web,
      "folder": '$folder',
      "showempty": '$showEmpty'
    }));

    HttpClientResponse response = await request.close();

    var responseBody = await response.transform(Utf8Decoder()).join();
    var json = jsonDecode(responseBody);
    if (json["errno"] != 0) {
      throw Exception("diskFilePath error code ${json["errno"]}");
    }
    var list = (json["list"] as List<dynamic>);
    return list.map((e) => BdDiskFile.fromJSON(e)).toList();
  }

  Future<List<BdDiskFile>> getSearchFile(String key,
      {String dir = "/", int page = 1, int num = 1000, String recursion = '0', String web = '0'}) async {
    HttpClientRequest request = await httpClient.getUrl(Uri.http(host, diskFilePath, {
      'method': "search",
      'access_token': await accessToken,
      'key': key,
      'num': '$num',
      'recursion': '$recursion',
      'page': '$page',
      'dir': dir,
      "web": web,
    }));

    HttpClientResponse response = await request.close();

    var responseBody = await response.transform(Utf8Decoder()).join();
    var json = jsonDecode(responseBody);
    if (json["errno"] != 0) {
      throw Exception("diskFilePath error code ${json["errno"]}");
    }
    var list = (json["list"] as List<dynamic>);
    return list.map((e) => BdDiskFile.fromJSON(e)).toList();
  }
}
