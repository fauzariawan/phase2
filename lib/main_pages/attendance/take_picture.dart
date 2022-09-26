import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/helper/utility_image.dart';
import 'package:workplan_beta_test/main_pages/attendance/result_clock_in_clock_out.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/loginscreen.dart';
import 'package:workplan_beta_test/pages/new_change_password.dart';
import 'package:workplan_beta_test/pages/profile/setting/profile_setting.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data_dokumen_take_picture.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/warning.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

final double mirror = math.pi;

class TakePicture extends StatefulWidget {
  final CameraDescription cameraDescription;
  final String type;
  final User? user;
  final String fromPage;
  final int locationId;
  final int shiftId;
  final dynamic role;
  // final String title;
  const TakePicture(
      {Key? key,
      required this.type,
      required this.user,
      required this.cameraDescription,
      required this.fromPage,
      required this.locationId,
      required this.shiftId,
      required this.role
      // required this.title,
      })
      : super(key: key);

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _availableCameras;
  late XFile image;
  String? imagePath;
  bool isScanning = false;
  int count = 0;
  Timer? timer;
  String _deviceId = 'Unknown';
  User? user;
  var db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();
    print(widget.type);
    // now = DateFormat.Hm().format(dateTime);
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   int? limit = widget.user!.timeoutLogin * 60;
    //   // print('ini limit time logout nhya');
    //   // print(limit);
    //   if (count < limit) {
    //     // print(count);
    //     setState(() {
    //       count++;
    //     });
    //   } else {
    //     timer.cancel();
    //     Helper.updateIsLogin(widget.user!, 0);
    //     Navigator.of(this.context).pushNamedAndRemoveUntil(
    //         loginScreen, (Route<dynamic> route) => false);
    //   }
    // });
    // 1. REGISTER
    // 2. Clock In
    _getAvailableCameras();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameraDescription,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    // _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _getAvailableCameras() async {
    // WidgetsFlutterBinding.ensureInitialized();
    _availableCameras = await availableCameras();
    print('ini avaliable camera');
    print(_availableCameras);
    // final lensDirection = _controller.description.lensDirection;
    _initializeControllerFuture = _initCamera(widget.cameraDescription);
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(description, ResolutionPreset.medium,
        enableAudio: true);

    try {
      await _controller.initialize();
      setState(() {});
      // to notify the widgets that camera has been initialized and now camera preview can be done
    } catch (e) {
      print(e);
    }
  }

  void _toggleCameraLens() {
    final lensDirection = _controller.description.lensDirection;
    CameraDescription newDescription;
    print('ini posisi camera pertama');
    print(lensDirection);
    if (lensDirection == CameraLensDirection.back) {
      newDescription = CameraDescription(
          name: "1",
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0);
      _initCamera(newDescription);
    } else {
      newDescription = CameraDescription(
          name: "0",
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90);
      _initCamera(newDescription);
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Scanning"),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                children: [
                  imagePath == null
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 9, vertical: 9),
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: MediaQuery.of(context).size.width * 0.9,
                            child: CameraPreview(_controller),
                          ),
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: Transform(
                            alignment: Alignment.topCenter,
                            transform: Matrix4.rotationY(
                                mirror), // untuk mengatasi posisi gambar yang flip sendiri
                            child: Image.file(File(imagePath!),
                                width: MediaQuery.of(context).size.width * 0.65,
                                height:
                                    MediaQuery.of(context).size.width * 0.91),
                          ),
                        ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset("images/Attandance/picture frame2.png",
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.91),
                  )
                ],
              ),
              Text("Face Scanning ...",
                  style: TextStyle(
                      fontFamily: "poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(
                "Please put your phone in front of your face\nthen push button bellow and wait\nuntil process scanning finish",
                textAlign: TextAlign.center,
              ),
              isScanning
                  ? CircularProgressIndicator()
                  : IconButton(
                      icon: Image.asset("images/Attandance/Group 91.png"),
                      iconSize: 80,
                      onPressed: () async {
                        try {
                          print('sudah di pencet');
                          print(widget.type);
                          print('ini di panggil dari halaman <<<<<<<=====');
                          print(widget.fromPage);
                          // Warning.showWarning(
                          //     "Menunggu API dari Mas Rindi : ${widget.type}");

                          setState(() {
                            isScanning = true;
                          });
                          // // await _initializeControllerFuture;
                          image = await _controller.takePicture();
                          // File rotatedImage =
                          //     await FlutterExifRotation.rotateImage(
                          //         path: image!.path);
                          print('ini image nya<<<<====');
                          print(image.path);
                          setState(() {
                            imagePath = image.path;
                          });
                          var path = image.path;
                          File file = File(path);
                          // String baseimage = base64Encode(file.readAsBytesSync());
                          String fileName = widget.user!.id.toString() +
                              "_" +
                              path.split('/').last;

                          //save to local
                          Utility.saveImageToPreferences(
                              Utility.base64String(file.readAsBytesSync()),
                              fileName);

                          uploadImage(file, path, context, widget.type);
                        } catch (e) {
                          Warning.showWarning(e.toString());
                        }
                      },
                    ),
              InkWell(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'poppins',
                      color: SystemParam.colorCustom),
                ),
                onTap: () {
                  if (widget.fromPage == null) {
                    Navigator.pop(context);
                    return;
                  }
                  print('sudah di pencet');
                  print(widget.type);
                  print('ini di panggil dari halaman <<<<<<<=====');
                  print(widget.fromPage);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileSetting(
                                user: widget.user!, /*timer: timer!*/
                              )));
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => LoginScreen(),
                  //     ));
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => ResultCICO()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  uploadImage(File file, String path, BuildContext context, String type) async {
    // imageSource.readAsBytes();
    print('sudah masuk ke fungsi upload image<<<<<<<=======');
    File file = File(path);
    //String baseimage = base64Encode(file.readAsBytesSync());
    String fileName = widget.user!.id.toString() + "_" + path.split('/').last;

    //save to local
    Utility.saveImageToPreferences(
        Utility.base64String(file.readAsBytesSync()), fileName);

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        uploadOnline(file, fileName, context, type);
      }
    } on SocketException catch (_) {
      print('not connected');
      Warning.showWarning("No Internet Connection");
    }
  }

  uploadOnline(File imageFile, String filename, BuildContext context,
      String type) async {
    print('masuk ke upload online');
    var stream = new http.ByteStream(Stream.castFrom(imageFile.openRead()));
    DateTime dateTime = DateTime.now();
    var now = DateFormat.Hm().format(dateTime);
    // get file length
    try {
      var length = await imageFile.length();
      var uri;

      // string to uri
      if (type == 'LOGIN') {
        uri =
            Uri.parse(SystemParam.baseUrl + SystemParam.loginByFaceRecognition);
      }

      if (type == 'Register') {
        uri = Uri.parse(SystemParam.baseUrl +
            SystemParam.registerFaceRecognition +
            "/" +
            widget.user!.id.toString());
      }

      if (type == 'Clock In' || type == 'Clock Out') {
        var path;
        if (type == 'Clock In') {
          path = 'clock-in';
        } else {
          path = 'clock-out';
        }
        uri = Uri.parse(
            SystemParam.baseUrl + path + "/" + widget.user!.id.toString());
      }
      print('link Scanning Wajah <<<=====');
      print(uri);
      print(type);

      // create multipart request
      var request = new http.MultipartRequest("POST", uri);
      // request.fields.addEntries(data);
      // multipart that takes file
      var multipartFile = new http.MultipartFile('image', stream, length,
          filename: basename(imageFile.path));

      // add file to multipart

      request.files.add(multipartFile);

      if (type == 'LOGIN') {
        request.fields['company_id'] = widget.user!.userCompanyId.toString();
        request.fields['user_id'] = widget.user!.id.toString();
      }

      if (type == 'Register') {
        print('menambah kan body untuk register...');
        print(widget.user!.userCompanyId);
        if (widget.fromPage == 'Ulang') {
          request.fields['company_id'] = widget.user!.userCompanyId.toString();
          request.fields['type'] = widget.fromPage;
        } else {
          request.fields['company_id'] = widget.user!.userCompanyId.toString();
        }
      }

      if (type == 'Clock In' || type == 'Clock Out') {
        var data = {
          'company_id': widget.user!.userCompanyId.toString(),
          'timezone': dateTime.timeZoneName,
          'time': now,
          'absence_location_id': widget.locationId.toString(),
          'shift_id': widget.shiftId.toString()
        };
        print('INI DATA YANG MAU DIKIRIM SAAT CLOCK IN <<<<<<<<<====');
        print(data);
        request.fields['company_id'] = widget.user!.userCompanyId.toString();
        request.fields['timezone'] = dateTime.timeZoneName;
        request.fields['time'] = now;
        if (widget.locationId != null) {
          request.fields['absence_location_id'] = widget.locationId.toString();
        }
        request.fields['shift_id'] = widget.shiftId.toString();
      }

      print('menunggu respons request...');
      var response = await request.send();
      print('request sudah selesai');

      print(
          'Ini status code dari request register face recognition <<<<<<=====');
      print(response.statusCode);
      // listen for response
      response.stream.transform(utf8.decoder).listen((value) async {
        var response = jsonDecode(value);

        if (type == 'LOGIN') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          print('ini respon dari upload foto LOGIN');
          print(response);
          if (response['code'] == "1") {
            setState(() {
              isScanning = false;
              imagePath = null;
            });
            Warning.showWarning(response['status']);
            return;
          }

          String errorMsg = "";
          bool isLogin = false;
          bool isActive;

          if (response['code'] == "0") {
            setState(() {
              isScanning = false;
            });
            Warning.showWarning(response['status']);
            await db.deleteUser();
            UserModel userModel = userFromJson(jsonEncode(response));
            List<User> userList = userModel.data;
            user = userList[0];
            if (null != userList && userList.length < 1) {
              errorMsg += "User Id";
            }

            if (null != userList &&
                userList.length > 0 &&
                userList[0].isLoginMobile == "1" &&
                userList[0].deviceId != _deviceId) {
              print("Device ID::::" +
                  userList[0].deviceId.toString() +
                  "::::" +
                  _deviceId.toString());
              isLogin = true;
            }

            // if (null != userList &&
            //     userList.length > 0 &&
            //     userList[0].encryptedPassword != encryptedPassword) {
            //   if (errorMsg != "") {
            //     errorMsg += ", Password";
            //   } else {
            //     errorMsg = "Password";
            //   }
            // }

            // String errorCompany = "";
            // for (var i = 0; i < userList.length; i++) {
            //   if (userList[i].companyCode.toUpperCase() ==
            //       companyCode.toUpperCase()) {
            //     user = userList[i];
            //     errorCompany = "";

            //     break;
            //   } else {
            //     //cek company tidak cocok
            //     if (userList[i].companyCode.toUpperCase() !=
            //         companyCode.toUpperCase()) {
            //       errorCompany = "Company Code";
            //     }
            //   }
            // }

            // if (errorCompany != "") {
            //   if (errorMsg != "") {
            //     errorMsg += ", Company";
            //   } else {
            //     errorMsg += "Company";
            //   }
            // }

            if (errorMsg == "") {
              for (var i = 0; i < userList.length; i++) {
                /* INSERT USER */
                db.insertUser(userList[i]);
              }
            }
          } else {
            Navigator.pop(context);
            if (errorMsg != "") {
              errorMsg += ", User Id";
            } else {
              errorMsg += "User Id";
            }
          }

          if (errorMsg != "" || isLogin) {
            String errMsg = "";
            if (errorMsg != "") {
              errMsg = errorMsg + " salah ";
            } else {
              errMsg = "User sudah login di device lain";
            }
            setState(() {
              isScanning = false;
              imagePath = null;
            });
            Warning.showWarning(errMsg);
            return;
          } else {
            bool isActive = true;
            if (0 == user!.employeeStatus) {
              if (1 == user!.resignFlag) {
                DateTime dtNow = DateTime.now();
                if (user!.resignDate != null) {
                  if (dtNow.isAfter(user!.resignDate)) {
                    //user inactive becouse resign date
                    isActive = false;
                  }
                }
              } else {
                //user inactive
                isActive = false;
              }
            }

            if (!isActive) {
              //USER INACTIVE
              setState(() {
                isScanning = false;
                imagePath = null;
              });

              Warning.showWarning("User is not active!");
              return;
            } else if (null == user!.lastSignInAt) {
              //USER BARU
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewChangePassword(
                      user: user!,
                      rootAsal: 'loginScreen',
                    ),
                  ));
            } else {
              /* UPDATE IS LOGIN */
              Navigator.pop(context);
              dynamic json = jsonEncode(user);
              prefs.setString("dataUser", json.toString());
              print(json);
              onLoginSuccess(user);
            }
          }
        }

        if (type == 'Register') {
          print('ini respon dari upload foto REGISTER');
          print(response);
          print(value);
          if (response['code'] == "0") {
            print('registrasi berhasil');
          
            // await saveDataLocal(response['data']);
            // timer!.cancel();
            Navigator.of(this.context).pushNamed(registerSuccess, arguments: {
              "user": widget.user,
              "fromPage": widget.fromPage,
              // "timer": timer
            }); // tambahkan widget.fromPage
          } else {
            setState(() {
              isScanning = false;
              imagePath = null;
            });
            Warning.showWarning(
                "Registrasi Gagal !!!, respon dari backend : ${response["status"]}");
          }
          print(response['code'].toString());
          print(response["status"]);
          return;
        }

        if (type == 'Clock In' || type == 'Clock Out') {
          print('ini respon dari upload foto Clock-In || Clock-Out');
          print(response['data']);
          print(response);
          if (response['code'] == "0") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ResultCICO(
                          widget.role,
                          widget.user!,
                          type,
                          widget.user!.fullName,
                          imagePath!,
                          response['data']['clocktime'],
                          response['data']['timezone'],
                        )));
          } else {
            setState(() {
              isScanning = false;
              imagePath = null;
            });
            Warning.showWarning(response['status']);
            print(response['status']);
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // Future<void> saveDataLocal(List<dynamic> data) async {
  //   // for (var item in data) {
  //   //   if(item['id'] == widget.user!.id && item['company_id'] == widget.user!.userCompanyId){

  //   //   }
  //   // }
  //   // print('masuk ke save data local <<<<<<=====');
  //   // print(data);
  //   // // var dataJson = jsonDecode(data);
  //   // UserModel userModel = userFromJson(data);
  //   // print('ini data user yang mau di simpan <<<<<<======');
  //   // print(userModel.data);
  //   // List<User> userList = userModel.data;
  //   // await db.deleteUser();
  //   // for (var i = 0; i < userList.length; i++) {
  //   //   await db.insertUser(userList[i]);
  //   // }
  //   setState(() {
  //     isScanning = false;
  //   });
  // }

  void onLoginSuccess(user) async {
    updateIsLogin(user, "1");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("login_via", "Face Recognition");
    Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => LandingPage(user: user, currentIndex: 0),
        ));
  }

  void updateIsLogin(User user, String isLogin) async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var dataPassword = {
          "id": user.id,
          "updated_by": user.id,
          "is_login_mobile": isLogin,
          "device_id": _deviceId
        };

        var response = await RestService()
            .restRequestService(SystemParam.fUpdateIsLogin, dataPassword);

        var convertDataToJson = json.decode(response.body);
        var code = convertDataToJson['code'];
        print("code is login response:" + code);
      }
    } on SocketException catch (_) {
      Warning.showWarning('No Internet Connection');
    }
  }
}
