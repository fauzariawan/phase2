import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:workplan_beta_test/base/system_param.dart';

class RestService {
  static RestService _instance = new RestService.internal();
  RestService.internal();
  factory RestService() => _instance;

  Future<Response> restRequestService(String url, var data) async {
    // print(Uri.parse(url));
    // print("parameter: "+jsonEncode(data));
    print("url:" + SystemParam.baseUrl + url);
    var respon = await post(
      Uri.parse(SystemParam.baseUrl + url),
      headers: {"content-type": "application/json"},
      body: jsonEncode(data),
    );
    return respon;
  }

  Future<Response?> restRequestServicePost(String url, var data) async {
    // print(Uri.parse(url));
    // print("parameter: "+jsonEncode(data));
    print("url:" + SystemParam.baseUrl + url);
    try {
      var respon = await post(
        Uri.parse(SystemParam.baseUrl + url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          // "content-type": "application/json",
        },
        body: data,
      );
      return respon;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Response> restRequestServiceOthers(String url, var data) async {
    // print(Uri.parse(url));
    var respon = await post(
      Uri.parse(url),
      headers: {"content-type": "application/json"},
      body: jsonEncode(data),
    );
    return respon;
  }

  Future<Response> requestServiceGet(
      String path, var pathVariable, String params) async {
    Uri? url;
    print("ini url dari request service GET <<<<<<<======");
    String _pathVariable = pathVariable.toString();
    // print(
    //     Uri.parse(SystemParam.baseUrl + path + "/" + "$_pathVariable?$params"));
    // print(_pathVariable);
    if (path == 'attendance') {
      print("attendance <<<===");
      url = Uri.parse(
          SystemParam.baseUrl + path + "/" + "$_pathVariable?$params");
    }

    if (path == 'declaration') {
      print("declaration<<<====");
      if (pathVariable == null) {
        url = Uri.parse(SystemParam.baseUrl + path + "?$params");
        print(url);
      } else {
        print('tidak menggunakan path variable');
        url = Uri.parse(
            SystemParam.baseUrl + path + "/" + _pathVariable + "?$params");
        print(url);
      }
    }

    var respon = await get(url!);
    print("response");
    return respon;
  }
}
