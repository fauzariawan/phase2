import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:workplan_beta_test/main_pages/attendance/location_clock_in_clock_out.dart';
import 'package:workplan_beta_test/main_pages/declaration/declarationQuestionAnswer.dart';
// import 'package:workplan_beta_test/main_pages/faceDetection/faceDetection.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/biometrik_termandcondition.dart';
import 'package:workplan_beta_test/pages/loginscreen.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/register_success.dart';

import 'main_pages/attendance/take_picture.dart';

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case locationClockInClockOut:
        var data = settings.arguments as dynamic;
        String userString = data["user"];
        var userJson = jsonDecode(userString);
        User user = User.fromJson(userJson);
        return MaterialPageRoute(
            builder: (_) => LocationClockInClockOut(
                type: data['type'],
                user: user,
                jamMulaiKerja: data['jamMulaiKerja'],
                jamSelesaiKerja: data['jamSelesaiKerja'],
                role: data['role'],
                locationId: data['locationId'],
                shiftId: data['shiftId']));
      case takePicture:
        var data = settings.arguments as dynamic;
        // String userString = data["user"] ?? null;
        // print('ini dari router');
        // var userJson = userString != null ? jsonDecode(userString) : '';
        // print(userJson);
        // User? user = userJson != '' ? User.fromJson(userJson) : null;
        CameraDescription camera = data["camera"];
        // title: data['title']
        return MaterialPageRoute(
            builder: (_) => TakePicture(
              role: data['role'],
                type: data['type'],
                user: data['user'],
                locationId: data['locationId'],
                shiftId: data['shiftId'],
                cameraDescription: camera,
                fromPage: data['fromPage']));
      case registerSuccess:
        var data = settings.arguments as dynamic;
        return MaterialPageRoute(
            builder: (_) => RegisterSuccess(
                  fromPage: data['fromPage'],
                  user: data['user'],
                ));
      case termsAndConditions:
        print('masuk ke router termsAndConditions');
        var data = settings.arguments as dynamic;
        // print(data);
        // String userString = data["user"];
        // var userJson = jsonDecode(userString);
        // User user = User.fromJson(userJson);
        return MaterialPageRoute(
            builder: (_) => BiometrikTermAndCondition(
                  page: data['type'],
                  user: data["user"],
                ));
      case declarationQuestionAnswer:
        var data = settings.arguments as dynamic;
        String title = data["title"];
        return MaterialPageRoute(
            builder: (_) => DeclarationQuestionAnswer(
                title: title,
                user: data["user"],
                idQuestion: data["idQuestion"],
                isViewOnly: data["isViewOnly"],
                isScoring: data["isScoring"],
                role: data['role']));
      // case personal:
      //   var data = settings.arguments as dynamic;
      //   print(data);
      //   User user = data['user'];
      //   PersonalInfoProfilData profileData = data['profileData'];
      //   return MaterialPageRoute(
      //       builder: (_) => ProfilePersonal(
      //                 user: user, profile: profileData));
      // case produkPromo:
      //   var data = settings.arguments as List<dynamic>;
      //   var noTelp = data[0];
      //   var dataOperator = data[1];
      //   print('INI DATA DARI ROUTER');
      //   print(noTelp);
      //   print(dataOperator);
      //   return MaterialPageRoute(
      //       builder: (_) => ProdukPromo(data: dataOperator, noTelp: noTelp));
      // case finance:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(builder: (_) => Finance(data: data));
      // case cekTagihan:
      //   var data = settings.arguments as List<dynamic>;
      //   var nomor = data[0];
      //   var item = data[1];
      //   print(data);
      //   return MaterialPageRoute(
      //       builder: (_) => CekTagihan(data: item, nomor: nomor));
      // case telkom:
      //   return MaterialPageRoute(builder: (_) => Telkom());
      // case gasAlam:
      //   return MaterialPageRoute(builder: (_) => GasAlam());
      // case listOperator:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(builder: (_) => ListOperator(data: data));
      // case profileDetail:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(builder: (_) => ProfileDetail(data: data));
      // case myQrcode:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(builder: (_) => MyQrcode(data: data));
      // case tesPembayaran:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(builder: (_) => TesPembayaran(data: data));
      // case pulsa:
      //   var data = settings.arguments as List<dynamic>;
      //   var noTelp = data[0];
      //   return MaterialPageRoute(builder: (_) => Pulsa(data: noTelp));
      // case kirimSaldo:
      //   var data = settings.arguments as List<dynamic>;
      //   var noTelp = data[0];
      //   return MaterialPageRoute(builder: (_) => KirimSaldo(data: noTelp));
      // case kuota:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(builder: (_) => Kuota(backupKodeTitle: data));
      // case konfirmasiPin:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(builder: (_) => KonfirmasiPin(data: data));
      // case detailTransaksi:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(
      //       builder: (_) => DetailTransaksi(
      //             data: data,
      //           ));
      // case profile:
      //   return MaterialPageRoute(builder: (_) => Profile());
      // case map:
      //   return MaterialPageRoute(builder: (_) => Map());
      // case kirim:
      //   var data = settings.arguments as List<dynamic>;
      //   var ind = data[1];
      //   var noTelp = data[0];
      //   return MaterialPageRoute(builder: (_) => Kirim(selectedIndex: ind, noTelp: noTelp));
      // case laporan:
      //   var data = settings.arguments as dynamic;
      //   return MaterialPageRoute(builder: (_) => Laporan(data: data));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
