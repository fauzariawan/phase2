import 'dart:async';
import 'dart:convert';

import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/profile/setting/profile_setting.dart';
import 'package:workplan_beta_test/main_pages/constans.dart';
import 'package:bulleted_list/bulleted_list.dart';
import 'package:workplan_beta_test/routerName.dart';

import 'biometrik_confirmation.dart';
import 'loginscreen.dart';

class BiometrikTermAndCondition extends StatefulWidget {
  final User user;
  final String page;
  const BiometrikTermAndCondition(
      {Key? key, required this.user, required this.page})
      : super(key: key);

  @override
  _BiometrikTermAndConditionState createState() =>
      _BiometrikTermAndConditionState();
}

class _BiometrikTermAndConditionState extends State<BiometrikTermAndCondition> {
  bool loading = false;
  var db = new DatabaseHelper();
  List<String> termsAndConditions = [
    "Biometric Login adalah fitur tambahan yang kami sediakan kepada Anda untuk mengakses (login) aplikasi Workplan menggunakan pengenalan wajah (face recognition) Pengguna.",
    "Kami tidak mewajibkan Pengguna untuk menggunakan fitur Biometric Login . Apabila Pengguna tidak ingin menggunakan sarana Biometric Login , Pengguna tetap dapat mengakses aplikasi Workplan dengan memasukkan User Id dan Password serta Company Code.",
    "Dengan melakukan aktivasi pengenalan wajah, Pengguna mengetahui dan menyetujui bahwa seluruh pengenalan wajah tersebut dapat digunakan sebagai pilihan otentifikasi login pada aplikasi Workplan.",
    "Pengguna sewaktu-waktu dapat menonaktifkan fitur Biometric Login melalui menu Personal Information > Setting pada aplikasi Workplan.",
    "Kami tidak bertanggung jawab atas segala kerugian yang timbul, baik materiel maupun immateriel, yang disebabkan karena ketidakhati-hatian dan/atau kecerobohan dan/atau kesengajaan dan/atau penyalahgunaan yang dilakukan Pengguna dan/atau pihak lain terhadap pengenalan wajah pada aplikasi Workplan. materiel maupun immateriel, yang disebabkan karena ketidakhati-hatian dan/atau kecerobohan dan/atau kesengajaan dan/atau penyalahgunaan yang dilakukan Pengguna dan/atau pihak lain terhadap pengenalan wajah pada aplikasi Workplan."
  ];
  // Timer? timer;
  int count = 0;
  late CameraDescription cameraDescription;

  @override
  void initState() {
    super.initState();
    print(widget.page);
    // if (widget.page != 'LOGIN') {
    //   timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //     int? limit = widget.user.timeoutLogin * 60;
    //     print('ini limit time logout nhya');
    //     print(limit);
    //     if (count < limit) {
    //       print(count);
    //       setState(() {
    //         count++;
    //       });
    //     } else {
    //       timer.cancel();
    //       Helper.updateIsLogin(widget.user, 0);
    //       Navigator.of(context).pushNamedAndRemoveUntil(
    //           loginScreen, (Route<dynamic> route) => false);
    //     }
    //   });
    // }
    startCamera();
  }

  void startCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
      },
      child: WillPopScope(
        onWillPop: () async {
          if (widget.page == "LOGIN") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ));
          } else {
            // timer!.cancel();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LandingPage(
                    user: widget.user,
                    currentIndex: 1,
                  ),
                ));
          }

          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Terms & Conditions',
              style: TextStyle(
                  fontFamily: "Calibre",
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: SystemParam.colorCustom,
          ),
          body: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            itemCount: termsAndConditions.length + 2,
            itemBuilder: (BuildContext context, i) {
              int nomor = i + 1;
              if (nomor == 6) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: ElevatedButton(
                      onPressed: () {
                        doSave("1");
                      },
                      child: Text("Setuju",
                          style:
                              TextStyle(fontFamily: "Calibre", fontSize: 18))),
                );
              } else if (nomor == 7) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: TextButton(
                      onPressed: () {
                        doSave("0");
                      },
                      child: Text("Cancel",
                          style:
                              TextStyle(fontFamily: "Calibre", fontSize: 18))),
                );
              } else {
                return ListTile(
                    dense: true,
                    leading:
                        Text(nomor.toString(), style: TextStyle(fontSize: 13)),
                    title: Text(
                      termsAndConditions[i].toString(),
                      style: TextStyle(fontFamily: "Poppins", fontSize: 13),
                      textAlign: TextAlign.justify,
                    ),
                    horizontalTitleGap: 10,
                    minVerticalPadding: 12,
                    minLeadingWidth: 0);
              }
            },
          ),
        ),
      ),
    );
  }

  void doSave(isBiometrics) {
    if(isBiometrics=="1"){
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BiometrikConfirmation(
                user: widget.user, isBiometrics: isBiometrics, page: widget.page,
              ),
            ));
    }else{
      if (widget.page == "LOGIN") {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileSetting(
                user: widget.user,
              ),
            ));
      }
    }
    // INI LOGIC UNTUK FACE RECOGNITION CENTERILIZE
    // if (isBiometrics == "1") {
    //   if (widget.page != "LOGIN") timer!.cancel();
    //   print('tampilkan camera');
    //   //  String userString = jsonEncode(widget.user);
    //   Navigator.pushNamed(context, takePicture, arguments: {
    //     "title": "Scanning",
    //     "type": 'Register',
    //     "fromPage": widget.page,
    //     "user": widget.user,
    //     "camera": cameraDescription
    //   });
    //   // Navigator.push(
    //   //     context,
    //   //     MaterialPageRoute(
    //   //       builder: (context) => BiometrikConfirmation(
    //   //         user: widget.user,
    //   //         isBiometrics: isBiometrics,
    //   //         page: widget.page,
    //   //       ),
    //   //     ));
    // } else {
    //   if (widget.page == "LOGIN") {
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => LoginScreen(),
    //         ));
    //   } else {
    //     timer!.cancel();
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => LandingPage(
    //             user: widget.user,
    //             currentIndex: 1,
    //           ),
    //         ));
    //   }
    // }
  }
}
