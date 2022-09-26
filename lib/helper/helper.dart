import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class Helper {
  static internetCek() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static updateIsLogin(User user, int isLogin) async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (isLogin == 0) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          var dataUser = jsonDecode(prefs.getString("dataUser").toString());
          print('INI STATUS LOGIN DI MOBILE <<<<<<=====');
          print(dataUser['is_login_mobile']);
          dataUser['is_login_mobile'] = '0';
          print('INI STATUS LOGIN DI MOBILE SETELAH DI UPDATE <<<<<<=====');
          print(dataUser['is_login_mobile']);
          prefs.setString("dataUser", jsonEncode(dataUser));
          prefs.remove("updateLocation");
        }
        var dataPassword = {
          "id": user.id,
          "updated_by": user.id,
          "is_login_mobile": isLogin,
        };

        var response = await RestService()
            .restRequestService(SystemParam.fUpdateIsLogin, dataPassword);

        var convertDataToJson = json.decode(response.body);
        var code = convertDataToJson['code'];
        print("code:::" + code);
      }
    } on SocketException catch (_) {
      Warning.showWarning("No Internet Connection !!!");
    }
  }
}
