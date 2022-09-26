// ignore_for_file: unrelated_type_equality_checks, unnecessary_statements

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_location/trust_location.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/UsersDatabase.dart';
import 'package:workplan_beta_test/helper/cek_mock_location.dart';
import 'package:workplan_beta_test/helper/converter.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/permission.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/main.dart';
import 'package:workplan_beta_test/main_pages/attendance/take_picture.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/main_pages/session_timer.dart';
// import 'package:workplan_beta_test/model/user/user.dart';
import 'package:workplan_beta_test/model/user_model.dart';
// import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/biometrik_termandcondition.dart';
import 'package:workplan_beta_test/pages/login_choose_company.dart';
import 'package:workplan_beta_test/pages/new_change_password.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/internet_checking.dart';
import 'package:workplan_beta_test/widget/warning.dart';
// import 'package:workplan_beta_test/helper/database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userIdCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController companyCodeCtrl = TextEditingController();
  TextEditingController nomorHpDialogCtrl = TextEditingController();

  final requiredValidator =
      RequiredValidator(errorText: 'this field is required');
  final _keyForm = GlobalKey<FormState>();
  String _deviceId = 'Unknown';
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  String _message = "Not Authorized";
  var db = new DatabaseHelper();
  // var db = new UsersDatabase();
  bool loading = false;
  bool isCheckedBiometrics = false;
  bool isFaceDetection = false;
  bool isFaceRecognition = false;
  bool isFaceRecognitionRegistered = false;
  bool isFaceValidation = false;
  bool isFaceValidationChecked = false;
  late CameraDescription cameraDescription;
  User? user;
  late User userDb;
  bool isBiometricAvaliable = false;
  bool checkBiometric = false;
  List<BiometricType> availableBiometrics = [];
  bool authenticated = false;

  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";
  String appType = "";
  bool _isMockLocation = false;
  String baseUrl = SystemParam.baseUrl;
  PermissionStatus? statusPermission;

  @override
  void initState() {
    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   Workmanager().registerOneOffTask(
    //     'taskOne',
    //     'updateLocation',
    //     initialDelay: Duration(seconds: 1),
    //   );
    // });
    // TODO: implement initState
    super.initState();
    startCamera();
    _checkBiometric();
    // initUser();

    initUniqueIdentifierState();
    getPackageInfo();
    switch (baseUrl) {
      case 'https://workplan-phase2-be.aplikasidev.com/api/':
        appType = 'UAT';
        break;
      case 'https://workplan-app-beta.dev-v3.aplikasidev.com/api/':
        appType = 'BETA';
        break;
      default:
    }
    askForPermission();
    CekMockLocation().runCekMockLocation();
  }

  void startCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
  }

  Future<void> initUniqueIdentifierState() async {
    String identifier;
    try {
      identifier = (await UniqueIdentifier.serial)!;
    } on PlatformException {
      identifier = 'Failed to get Unique Identifier';
    }

    if (!mounted) return;

    setState(() {
      _deviceId = identifier;
      print(":::_deviceId::::" + _deviceId);
    });
  }

  // void initUser() async {
  //   loading = true;
  //   print('masuk ke init device');
  //   db.getUserList().then((value) {
  //     print(value);
  //     if (value.length > 0) {
  //       print('ada db local');
  //       setState(() {
  //         late User userDb = value[0];
  //         print("isBiometrik");
  //         print(userDb.isBiometrik);
  //         if (userDb.isBiometrik == "1") {
  //           isCheckedBiometrics = true;
  //           // _authenticateMe();
  //         } else {
  //           isCheckedBiometrics = false;
  //         }

  //         loading = false;
  //       });
  //     }
  //   });
  //   loading = false;
  // }

  // // ini logic untuk fitur face recognition
  // void initUser() async {
  //   loading = true;
  //   print('masuk ke init device');
  //   db.getUserList().then((value) {
  //     print(value);
  //     if (value.length > 0) {
  //       print('ada db local');
  //       setState(() {
  //         userDb = value[0];
  //         print('Validation Type Face');
  //         print(userDb.validationFaceType);
  //         print("Apaka Face Recognition Sudah Di Registrasikan?");
  //         print(userDb.isFaceRecognitionRegistered);
  //         if (userDb.validationFaceType == 1) {
  //           isFaceDetection = true;
  //           print("ini dari init user");
  //           print(isFaceDetection);
  //           // _authenticateMe();
  //         } else if (userDb.validationFaceType == 2) {
  //           isFaceRecognition = true;
  //         }

  //         if (userDb.isFaceRecognitionRegistered == 1)
  //           isFaceRecognitionRegistered = true;

  //         if (userDb.isFaceRecognitionValidated != null)
  //           isFaceValidationChecked = true;
  //         if (userDb.isFaceforgetRecognitionValidated == 1) isFaceValidation = true;
  //         loading = false;
  //       });
  //     }
  //   });
  //   loading = false;
  // }

  Future<void> _authenticateMe() async {
    print('cek fingerprint <<<<<=========');
    bool authenticated = false;

    isBiometricAvaliable = await _localAuthentication.canCheckBiometrics;
    // print(isAvailableBiometrics.then((value) => print(value)));
    if (isBiometricAvaliable) {
      Warning.showWarning("Fitur Biometrics tidak tersedia pada device anda");
      return;
    } else {
      availableBiometrics = await _localAuthentication.getAvailableBiometrics();
    }

    // getAvailabelBioMetrics();
    // Future<bool> isAvailableBiometrics = getAvailabelBioMetrics();
    // // print(isAvailableBiometrics.then((value) => print(value)));
    // isAvailableBiometrics.then((value) {
    //   print("isAvailableBiometrics");
    //   print(value);
    //   if (value) {
    //     Warning.showWarning("Fitur Biometrics tidak tersedia pada device anda");
    //     return;
    //   }
    // });

    // print('coba menampilkan showdialog finger print');
    // try {
    //   authenticated = await _localAuthentication.authenticate(
    //     localizedReason: "Authenticate for login", // message for dialog
    //     useErrorDialogs: true, // show error in dialog
    //     stickyAuth: true,
    //     biometricOnly: true,
    //     // native process
    //   );

    //   setState(() async {
    //     _message = authenticated ? "Authorized" : "Not Authorized";

    //     if (authenticated) {
    //       Warning.loading(context);
    //       loginBiometrik("LOGIN");
    //     }
    //   });
    // } on PlatformException catch (e) {
    //   print('gagal mencoba buka showdialog finger print');
    //   Warning.showWarning('Your Fingerprint Not Supported');
    //   print(e);
    // }
    // if (!mounted) return;
  }

  // Future<bool> getAvailabelBioMetrics() async {
  //   List<BiometricType> availableBiometrics =
  //       await _localAuthentication.getAvailableBiometrics();
  //   print(' tipe biometrics yang ada di perangkat anda <<<==========');
  //   print(availableBiometrics);
  //   // bool isAvailable = true;
  //   // if (Platform.isIOS) {
  //   //   if (!availableBiometrics.contains(BiometricType.face)) {
  //   //     // !Face ID.
  //   //     isAvailable = false;
  //   //   }
  //   // }

  //   // if (Platform.isAndroid) {
  //   //   if (!availableBiometrics.contains(BiometricType.face)) {
  //   //     // !Face ID.
  //   //     isAvailable = false;
  //   //   }
  //   // }
  //   // return isAvailable;
  //   return false;
  // }

  void loginBiometrik(String type, String typeBiometric, User user) async {
    // // var user;
    // // SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('cek data User');
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // // late User user;
    // // print(prefs);
    // // bool isLogedIn = false;
    // // bool isDataUserExist = prefs.containsKey('dataUser');
    // // if (isDataUserExist) {
    // //   print('ini lihat user masih login to tidak di local');
    // //   print('apakah prefs.containsKey masih ada => $isDataUserExist');
    // //   var data = jsonDecode(prefs.getString("dataUser").toString());
    // //   print(data['is_login_mobile']);
    // //   if (data['is_login_mobile'] == "1") {
    // //     print('cocok');
    // //     isLogedIn = true;
    // //   } else {
    // //     print('TIDAK COCOK');
    // //     data['is_login_mobile'].runtimeType;
    // //   }
    // //   print(data);
    // //   var dataUser;
    // //   if (data != null) {
    // //     dataUser = json.decode(data);
    // //     user = User.fromJson(dataUser);
    // //   }
    // //   print(dataUser);
    // // }
    // late User user;
    // print(prefs);
    // bool isLogedIn = prefs.containsKey('dataUser');
    // print('ini lihat user masih login to tidak di local');
    // print('apakah prefs.containsKey masih ada => $isLogedIn');
    // print(isLogedIn);
    // var data = prefs.getString("dataUser");
    // print(data);
    // var dataUser;
    // if (data != null) {
    //   dataUser = json.decode(data);
    //   if (dataUser['is_login_mobile'] != "1") isLogedIn = false;
    //   user = User.fromJson(dataUser);
    // }


    // // await db.getUserList().then((value) {
    // //   if (value != null && value.length > 0) {
    // //     user = value[0];
    // //   }
    // // });

    // // // await db.getAllUsers().then((value) {
    // // //   if (value != null && value.length > 0) {
    // // //     user = value[0];
    // // //   }
    // // // });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(user);

    if (user == null) {
      Warning.showWarning(
          "Belum ada data Local, silahkan login manual terlebih dahulu");
    } else {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (null != user) {
            var data = {
              "username": user.username,
            };

            var response = await RestService()
                .restRequestService(SystemParam.fLoginByUserIdOrEmail, data);

            var convertDataToJson = json.decode(response.body);
            var code = convertDataToJson['code'];

            if (code == "0") {
              UserModel userModel = userFromJson(response.body.toString());
              List<User> userList = userModel.data;
              await db.deleteUser();
              for (var i = 0; i < userList.length; i++) {
                await db.insertUser(userList[i]);
              }

              if (userList.length > 1) {
                if (type == "LOGIN") {
                  if (userList[0].isLoginMobile == "1" &&
                      userList[0].deviceId != _deviceId) {
                    Warning.showWarning("User sudah login di device lain");
                    return;
                  }
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginChooseCompanyCode(
                            userList: userList,
                            deviceId: _deviceId,
                            login_via: typeBiometric),
                      ));
                } else {
                  /* DAFTAR */
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BiometrikTermAndCondition(
                          user: user,
                          page: "LOGIN",
                        ),
                      ));
                }
              } else if (userList.length == 1) {
                for (var i = 0; i < userList.length; i++) {
                  user = userList[i];
                  dynamic json = jsonEncode(user);
                  prefs.setString("dataUser", json.toString());
                }

                if (type == "LOGIN") {
                  if (user.isLoginMobile == "1" && user.deviceId != _deviceId) {
                    Warning.showWarning("User sudah login di device lain");
                    return;
                  }
                  /* UPDATE IS LOGIN */
                  Navigator.of(context).pop();
                  onLoginSuccess(user, typeBiometric);
                  // updateIsLogin(user, "1");
                  // sessionTimer.startTimer(user);
                  // /* LOGIN */
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => LandingPage(
                  //         user: user,
                  //       ),
                  //     ));
                } else {
                  /* DAFTAR */
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BiometrikTermAndCondition(
                          user: user,
                          page: "LOGIN",
                        ),
                      ));
                }
              } else {
                Warning.showWarning("Silahkan login terlebih dahulu");
              }
            }
          }
          // });
          // });
        }
      } on SocketException catch (_) {
        Warning.showWarning('No Internet Connection');
        //print('not connected');

        // db.getUserList().then((userList) {
        //   // setState(() {
        //   if (userList.length > 1) {
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => LoginChooseCompanyCode(
        //             userList: userList,
        //             deviceId: _deviceId,
        //           ),
        //         ));
        //   } else if (userList.length == 1) {
        //     for (var i = 0; i < userList.length; i++) {
        //       user = userList[i];
        //     }

        //     if (type == "LOGIN") {
        //       /* UPDATE IS LOGIN */
        //       onLoginSuccess(user, typeBiometric);
        //       // updateIsLogin(user, "1");
        //       // sessionTimer.startTimer(user);
        //       // /* LOGIN */
        //       // Navigator.push(
        //       //     context,
        //       //     MaterialPageRoute(
        //       //       builder: (context) => LandingPage(
        //       //         user: user,
        //       //       ),
        //       //     ));
        //     } else {
        //       /* DAFTAR */
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => BiometrikTermAndCondition(
        //               user: user,
        //               page: "LOGIN",
        //             ),
        //           ));
        //     }
        //   } else {
        //     Warning.showWarning("Silahkan login terlebih dahulu");
        //   }
        //   // });
        // });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidht = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: screenHeight * 0.8,
              child: SingleChildScrollView(
                reverse: true,
                child: Center(
                  child: Form(
                    key: _keyForm,
                    child: Column(
                      children: [
                        // SizedBox(
                        //   height: 40,
                        // ),
                        Image.asset("images/App_Splash/WrkPln Logo 12.png"),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Welcome',
                            style: TextStyle(
                                fontFamily: "Calibre",
                                fontSize: 36,
                                fontWeight: FontWeight.bold)),
                        Text('You need to sign in before continuing.',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Text('User Id',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: screenWidht * 0.7,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            validator: requiredValidator,
                            controller: userIdCtrl,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              // filled: true,
                              // fillColor: Colors.grey[400],
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              labelStyle: TextStyle(
                                  fontSize: 14.0, fontFamily: "Brand Bold"),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Password',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: screenWidht * 0.7,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            validator: requiredValidator,
                            controller: passwordCtrl,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              labelStyle: TextStyle(
                                  fontSize: 14.0, fontFamily: "Brand Bold"),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Company Code',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: screenWidht * 0.7,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            validator: requiredValidator,
                            controller: companyCodeCtrl,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              // filled: true,
                              // fillColor: Colors.grey[400],
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            forgotPassword();
                          },
                          child: Text("Forgot Password",
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14.0,
                                  color: Colors.blue)),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: screenWidht * 0.5,
                                height: 45,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      print(statusPermission);
                                      if (statusPermission !=
                                          PermissionStatus.granted) {
                                        askForPermission();
                                        return;
                                      }

                                      if (_keyForm.currentState!.validate()) {
                                        bool hasInternetConnection =
                                            await InternetChecking
                                                .checkInternet();
                                        if (hasInternetConnection) {
                                          String encryptedPassword =
                                              ConverterUtil().generateMd5(
                                                  passwordCtrl.text);
                                          String companyCode = companyCodeCtrl
                                              .text
                                              .toUpperCase();
                                          String username = userIdCtrl.text;
                                          CekMockLocation()
                                              .getValueMockLocation()
                                              .then((value) {
                                            print('is mock location : $value');
                                            value
                                                ? Warning.showWarning(
                                                    "HP Anda terdeteksi telah di-root atau menggunakan aplikasi fake GPS sehingga Anda tidak diperkenankan login ke aplikasi.")
                                                : login(encryptedPassword,
                                                    companyCode, username);
                                          });
                                        } else {
                                          Warning.showWarning(
                                              'No Internet Connection');
                                        }
                                      }
                                    },
                                    child: Text("LOGIN"))),
                            SizedBox(
                              width: 5,
                            ),
                            // ElevatedButton(
                            //     onPressed: () async {
                            //       var uniqueId =
                            //           DateTime.now().second.toString();

                            //       // await Workmanager().registerPeriodicTask(
                            //       //     uniqueId, task,
                            //       //     constraints: Constraints(networkType: NetworkType.connected),
                            //       //     frequency: Duration(seconds: 1));
                            //     },
                            //     child: Text('tes backround task')),
                            // SizedBox(
                            //   width: 5,
                            // ),
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: isFaceDetection
                                          ? Colors.grey
                                          : SystemParam.colorCustom),
                                  onPressed: () async {
                                    print('sudah di pencet');
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (prefs.containsKey("dataUser")) {
                                      user = User.fromJson(jsonDecode(prefs
                                          .getString("dataUser")
                                          .toString()));
                                    }

                                    // await db.getUserList().then((value) {
                                    //   print('ini hasil dari get user list');
                                    //   print(value);
                                    //   if (value != null && value.length > 0) {
                                    //     user = User.fromJson(
                                    //         jsonDecode(jsonEncode(value[0])));
                                    //     user = value[0];
                                    //     print(user!.username);
                                    //   }
                                    // });

                                    print(user);
                                    if (user == null) {
                                      Warning.showWarning(
                                          "Belum ada data Local, silahkan login manual terlebih dahulu");
                                      return;
                                    } else {
                                      if (user!.isBiometrik == "1") {
                                        if (isBiometricAvaliable) {
                                          showDialogAuthentication(user!);
                                        } else {
                                          Warning.showWarning(
                                              "Your device not support to use this fiture");
                                        }
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BiometrikTermAndCondition(
                                                      user: user!,
                                                      page: "LOGIN"),
                                            ));
                                      }

                                      // if (!isCheckedBiometrics) {
                                      //   print('masuk kesini');
                                      //   loginBiometrik("DAFTAR");
                                      // } else {
                                      //   _authenticateMe();
                                      // }
                                      // showDialogAuthentication();
                                      // Navigator.pushNamed(
                                      //     context, faceDetection);
                                      //////////////////////////////
                                      // ini logic untuk face recognition
                                      // if (isFaceDetection == true) {
                                      //   print("Face Detection");
                                      //   // print('masuk kesini');
                                      //   // loginBiometrik("DAFTAR");
                                      //   Warning.showWarning(
                                      //       'You are not allowed using this fiture');
                                      //   return;
                                      // }

                                      // if (isFaceRecognition = true) {
                                      //   // SharedPreferences prefs =
                                      //   //     await SharedPreferences
                                      //   //         .getInstance();
                                      //   var data = {
                                      //     "username": user!.username,
                                      //   };
                                      //   Warning.loading(context);
                                      //   print('hit api <<<<<=========');
                                      //   var response = await RestService()
                                      //       .restRequestService(
                                      //           SystemParam
                                      //               .fLoginByUserIdOrEmail,
                                      //           data);

                                      //   var convertDataToJson =
                                      //       json.decode(response.body);

                                      //   var dataUser =
                                      //       convertDataToJson['data'][0];

                                      //   print(
                                      //       'is_face_recognition_registered = ${dataUser['is_face_recognition_registered']}');
                                      //   print(
                                      //       ' is_face_recognition_validated = ${dataUser['is_face_recognition_validated']}');

                                      //   // _authenticateMe();
                                      //   if (dataUser[
                                      //               'is_face_recognition_registered'] ==
                                      //           0 &&
                                      //       dataUser[
                                      //               'is_face_recognition_validated'] ==
                                      //           0) {
                                      //     Navigator.pop(context);
                                      //     Warning.showWarning(
                                      //         "Anda belum bisa login menggunakan face recognition");
                                      //     return;
                                      //   }
                                      //   if (dataUser[
                                      //               'is_face_recognition_registered'] ==
                                      //           1 &&
                                      //       dataUser[
                                      //               'is_face_recognition_validated'] ==
                                      //           0) {
                                      //     Navigator.pop(context);
                                      //     Warning.showWarning(
                                      //         "Proses register sedang menunggu persetujuan, Silahkan Login Manual");
                                      //     return;
                                      //   }
                                      //   // if (dataUser[
                                      //   //             'is_face_recognition_registered'] ==
                                      //   //         1 &&
                                      //   //     dataUser[
                                      //   //             'is_face_recognition_validated'] ==
                                      //   //         0) {
                                      //   //   Navigator.pop(context);
                                      //   //   Warning.showWarning(
                                      //   //       "Registrasi Face Recognition Anda ditolak, silahkan lakukan registrasi ulang di menu profile");
                                      //   //   return;
                                      //   // }
                                      //   if (dataUser[
                                      //               'is_face_recognition_registered'] ==
                                      //           1 &&
                                      //       (dataUser['is_face_recognition_validated'] ==
                                      //               2 ||
                                      //           dataUser[
                                      //                   'is_face_recognition_validated'] ==
                                      //               1 ||
                                      //           dataUser[
                                      //                   'is_face_recognition_validated'] ==
                                      //               3)) {
                                      //     Navigator.pop(context);
                                      //     showDialogAuthentication();
                                      //     return;
                                      //   }
                                      // }
                                      return;
                                    }
                                  },
                                  child: Image.asset(
                                    "images/Icon Biometric/biometric face _ fingerprint white.png",
                                    height: 45,
                                  )),
                            ),
                          ],
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Text(
                                "version Phase 2 / " + version + " " + appType,
                                style: TextStyle(
                                    fontSize: 9, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Positioned(
                      top: screenHeight * 0.8.abs(),
                      right: screenWidht * 0.4.abs(),
                      child: Container(
                        width: screenWidht + (screenWidht * 0.1),
                        height: screenWidht + (screenWidht * 0.1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SystemParam.colorCustom,
                        ),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.85.abs(),
                      // right: screenWidht*0.4.abs(),
                      child: SizedBox(
                        width: screenWidht,
                        child: Center(
                          child: Container(
                            width: screenWidht * 0.25,
                            height: screenWidht * 0.25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SystemParam.colorCustom2,
                            ),
                            child: Image.asset("images/Login/Vector.png"),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.85.abs(),
                      left: screenWidht * 0.3.abs(),
                      child: Container(
                        padding: EdgeInsets.all(90.0),
                        width: screenWidht + (screenWidht * 0.3),
                        height: screenWidht + (screenWidht * 0.3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: SystemParam.colorCustom3,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void dispose() {
    TrustLocation.stop();
    super.dispose();
  }

  void getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      buildNumber = packageInfo.buildNumber;
    });
  }

  void forgotPassword() {
    Widget cancelButton = ElevatedButton(
      child:
          Text("Cancel", style: TextStyle(fontFamily: "Poppins", fontSize: 14)),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        primary: Colors.green,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
        child: Text("Reset Password",
            style: TextStyle(fontFamily: "Poppins", fontSize: 14)),
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            primary: Colors.red),
        onPressed: () {
          resetPassword();
        } //resetPassword,
        );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Column(
        children: [
          Text("Reset Password",
              style: TextStyle(
                  fontFamily: "Calibre",
                  fontSize: 21,
                  fontWeight: FontWeight.bold)),
          Text(
            "Please insert your registered phone number",
            style: TextStyle(fontFamily: "Poppins", fontSize: 14),
            textAlign: TextAlign.center,
          )
        ],
      ),
      content: SingleChildScrollView(
          // biar ga bablas panjang kebawah
          child: Column(
        children: [
          Text(
            "Input Nomor HP",
            style: TextStyle(fontFamily: "Poppins", fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 40,
            width: 200,
            child: TextFormField(
              textAlign: TextAlign.center,
              validator: requiredValidator,
              controller: nomorHpDialogCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 10.0,
                ),
              ),
              style: TextStyle(fontSize: 14.0, fontFamily: "Poppins"),
            ),
          ),
        ],
      )),
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cancelButton,
            SizedBox(
              width: 5,
            ),
            continueButton,
          ],
        )
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // tidak ada pengecekan no hp yang valid
  void resetPassword() async {
    if (nomorHpDialogCtrl.text == "") {
      Warning.showWarning("Nomor HP harus diisi");
      return;
    }
    Navigator.of(context).pop();
    Warning.loading(context);
    String datetime = SystemParam.formatDateTimeUnique.format(DateTime.now());
    String token = datetime + nomorHpDialogCtrl.text;

    var data = {
      "token": token.toUpperCase(),
      "phone": nomorHpDialogCtrl.text,
    };
    print('ini data yang mau di kirim <<<<<<======');
    print(data);
    var response = await RestService()
        .restRequestService(SystemParam.fResetPassword, data);
    print('ini response request reset password <<<<<<<<========');
    print(response.body);
    var responToJson = json.decode(response.body);
    var code = responToJson['code'];

    if (code == "0") {
      Navigator.of(context).pop();
      Warning.showWarning("Reset password berhasil, silahkan cek pesan anda.");
    } else {
      Warning.showWarning(
          "Reset password gagal, silahkan hubungi admin perusahaan anda.");
    }
  }

  void login(
      String encryptedPassword, String companyCode, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = {
      "username": username,
    };
    Warning.loading(context);
    print('hit api <<<<<=========');
    var response = await RestService()
        .restRequestService(SystemParam.fLoginByUserIdOrEmail, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    //var status = convertDataToJson['status'];
    print(convertDataToJson);
    String errorMsg = "";
    bool isLogin = false;
    bool isActive = true;
    var user;

    if (code == "0") {
      print('berhasil hit api');
      await db.deleteUser();
      print('berhasil mengkosongkan data di db local');
      UserModel userModel = userFromJson(response.body.toString());
      List<User> userList = userModel.data;
      print('ini usermodel data');
      print(userModel.data);
      // bool isInsert = false;

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

      if (null != userList &&
          userList.length > 0 &&
          userList[0].encryptedPassword != encryptedPassword) {
        if (errorMsg != "") {
          errorMsg += ", Password";
        } else {
          errorMsg = "Password";
        }
      }

      String errorCompany = "";
      for (var i = 0; i < userList.length; i++) {
        if (userList[i].companyCode.toUpperCase() ==
            companyCode.toUpperCase()) {
          user = userList[i];
          errorCompany = "";
          break;
        } else {
          //cek company tidak cocok
          if (userList[i].companyCode.toUpperCase() !=
              companyCode.toUpperCase()) {
            errorCompany = "Company Code";
          }
        }
      }

      if (errorCompany != "") {
        if (errorMsg != "") {
          errorMsg += ", Company";
        } else {
          errorMsg += "Company";
        }
      }

      if (errorMsg == "") {
        for (var i = 0; i < userList.length; i++) {
          /* INSERT USER */
          var tes = await db.insertUser(userList[i]);
          print('Hasil dari insert user <<<<<<=========');
          print(tes);
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
      Navigator.pop(context);
      Warning.showWarning(errMsg);
      return;
    } else {
      bool isActive = true;
      if (0 == user.employeeStatus) {
        if (1 == user.resignFlag) {
          DateTime dtNow = DateTime.now();
          if (user.resignDate != null) {
            if (dtNow.isAfter(user.resignDate)) {
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
        Warning.showWarning(
            "User is not actived yet. Call the administrator !");
        return;
      } else if (null == user.lastSignInAt) {
        //USER BARU
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewChangePassword(
                user: user,
                rootAsal: 'loginScreen',
              ),
            ));
      } else {
        /* UPDATE IS LOGIN */
        Navigator.pop(context);
        user.isLoginMobile = '1';
        dynamic json = jsonEncode(user);
        prefs.setString("dataUser", json.toString());
        onLoginSuccess(user, "manual");
      }
    }
  }

  onLoginSuccess(User user, String login_via) async {
    print('ini role id nya <<<<<<<<========');
    print(user.roleId);
    updateIsLogin(user, "1");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("login_via", login_via);
    Navigator.push(
        context,
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

  void showDialogAuthentication(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Authentication Required",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Calibre",
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Verify Identity",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Calibre",
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    // scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: availableBiometrics.length,
                    itemBuilder: (context, i) {
                      return SizedBox(
                          width: 10,
                          child: Column(
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    if (availableBiometrics[i] ==
                                        BiometricType.fingerprint) {
                                      print(
                                          'gunakan authentication finger print');
                                      try {
                                        authenticated =
                                            await _localAuthentication
                                                .authenticate(
                                          localizedReason:
                                              "Please Authenticate",
                                          stickyAuth: true,
                                          biometricOnly: true,
                                        );
                                        if (authenticated) {
                                          Navigator.pop(context);
                                          loginBiometrik(
                                              "LOGIN", "fingerprint", user);
                                        } else {
                                          Warning.showWarning(
                                              "Authentication Failed");
                                        }
                                      } on PlatformException catch (e) {
                                        Warning.showWarning(
                                            "Aktifkan terlebih dahulu fungsi fingerprint anda ");
                                        print(
                                            'tidak bisa membuka show dialog authentication<<<<<====');
                                        print(e);
                                      }
                                    } 
                                    // else {
                                    //   try {
                                    //     authenticated =
                                    //         await _localAuthentication
                                    //             .authenticate(
                                    //                 stickyAuth: true,
                                    //                 useErrorDialogs: true,
                                    //                 localizedReason:
                                    //                     "Please Authenticate",
                                    //                 biometricOnly: true);
                                    //     if (authenticated) {
                                    //       loginBiometrik("LOGIN", "faceId");
                                    //     } else {
                                    //       Warning.showWarning(
                                    //           "Authentication Failed");
                                    //     }
                                    //   } on PlatformException catch (e) {
                                    //     print(e);
                                    //   }

                                    //   // print(
                                    //   //     'gunakan autentication face recognition');
                                    // }
                                  },
                                  child: availableBiometrics[i] ==
                                          BiometricType.fingerprint
                                      ? Image.asset(
                                          "images/Icon Biometric/fingerprint white.png",
                                          height: 45,
                                        )
                                      : Container()
                                      // Image.asset(
                                      //     "images/Icon Biometric/face-detection white.png",
                                      //     height: 45,
                                      //   )
                                        ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ));
                    }),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.white,
                //   ),
                //   child: IconButton(
                //     icon: Image.asset("images/Login/Facial Recognition.png"),
                //     iconSize: 50,
                //     onPressed: () {
                //       Navigator.pop(context);
                //       Navigator.pushNamed(context, takePicture, arguments: {
                //         "type": 'LOGIN',
                //         "user": userDb,
                //         "camera": cameraDescription
                //       });
                //       // if (isFaceRecognitionRegistered) {
                //       //   Navigator.pushNamed(context, takePicture, arguments: {
                //       //     "type": 'REGISTER',
                //       //     "user": userDb,
                //       //     "camera": cameraDescription
                //       //   });
                //       // } else {
                //       //   Navigator.pushNamed(context, termsAndConditions,
                //       //       arguments: {"user": user, "type": "LOGIN"});
                //       // }
                //     },
                //   ),
                // ),
                Text(
                  "Authentication for Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Calibre",
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"))
              ],
            ),
          ),
        );
        ;
      },
    );
  }

  void askForPermission() async {
    statusPermission = await Permission().requestLocationPermission();
    // print('from askForPermission = $statusPermission');
  }

  void _checkBiometric() async {
    isBiometricAvaliable = await _localAuthentication.canCheckBiometrics;
    print('ini hasil dari cek biometric : $isBiometricAvaliable');
    if (isBiometricAvaliable) {
      availableBiometrics = await _localAuthentication.getAvailableBiometrics();
      print(availableBiometrics);
    }
  }
}

// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:form_field_validator/form_field_validator.dart';
// // import 'package:get_version/get_version.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:unique_identifier/unique_identifier.dart';
// import 'package:workplan_beta_test/base/system_param.dart';
// import 'package:workplan_beta_test/helper/converter.dart';
// import 'package:workplan_beta_test/helper/database.dart';
// import 'package:workplan_beta_test/helper/rest_service.dart';
// import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
// import 'package:workplan_beta_test/main_pages/session_timer.dart';
// import 'package:workplan_beta_test/model/user_model.dart';
// import 'package:workplan_beta_test/pages/biometrik_termandcondition.dart';
// import 'package:workplan_beta_test/main_pages/constans.dart';
// import 'package:workplan_beta_test/widget/warning.dart';
// import 'package:workplan_beta_test/widget/warning.dart';
// import 'package:workplan_beta_test/widget/warning.dart';

// import 'login_choose_company.dart';
// import 'new_change_password.dart';
// // import 'package:unique_identifier/unique_identifier.dart';

// MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);

// class LoginScreen extends StatefulWidget {
//   static const String idScreen = "login";

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController userIdCtrl = TextEditingController();
//   TextEditingController passwordCtrl = TextEditingController();
//   TextEditingController companyCodeCtrl = TextEditingController();

//   TextEditingController userIdDialogCtrl = TextEditingController();
//   TextEditingController companyCodeDialogCtrl = TextEditingController();

//   TextEditingController nomorHpDialogCtrl = TextEditingController();
//   final _keyForm = GlobalKey<FormState>();
//   // late User user;
//   String projectVersion = "1.0.0";
//   final requiredValidator =
//       RequiredValidator(errorText: 'this field is required');
//   final LocalAuthentication _localAuthentication = LocalAuthentication();
//   String _message = "Not Authorized";
//   var db = new DatabaseHelper();
//   bool loading = false;
//   bool isCheckedBiometrics = false;
//   String _deviceId = 'Unknown';

//   // String smsGatewayAPI =SystemParam.smsGatewayAPIDefault;
//   // String smsGatewayUserKey =SystemParam.smsGatewayUserKeyDefault;
//   // String smsGatewayPassKey =SystemParam.smsGatewayPassKeyDefault;
//   // String tokenUrl = SystemParam.tokenUrlDefault;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initUser();
//     initUniqueIdentifierState();
//   }

//   Future<void> initUniqueIdentifierState() async {
//     String identifier;
//     try {
//       identifier = (await UniqueIdentifier.serial)!;
//     } on PlatformException {
//       identifier = 'Failed to get Unique Identifier';
//     }

//     if (!mounted) return;

//     setState(() {
//       _deviceId = identifier;
//       print(":::_deviceId::::" + _deviceId);
//     });
//   }

//   Future<void> _authenticateMe() async {
// // 8. this method opens a dialog for fingerprint authentication.
// //    we do not need to create a dialog nut it popsup from device natively.
//     print('cek finger pring <<<<<=========');
//     bool authenticated = false;

//     Future<bool> isAvailableBiometrics = getAvailabelBioMetrics();
//     // print(isAvailableBiometrics.then((value) => print(value)));
//     isAvailableBiometrics.then((value) {
//       print("isAvailableBiometrics");
//       print(value);
//       if (value) {
//         Warning.showWarning("Fitur Biometrics tidak tersedia pada device anda");
//         return;
//       }
//     });

//     print('coba menampilkan showdialog finger print');
//     try {
//       authenticated = await _localAuthentication.authenticate(
//         localizedReason: "Authenticate for login", // message for dialog
//         useErrorDialogs: true, // show error in dialog
//         stickyAuth: true,
//         biometricOnly: true,
//         // native process
//       );

//       setState(() async {
//         _message = authenticated ? "Authorized" : "Not Authorized";

//         if (authenticated) {
//           loginBiometrik("LOGIN");
//         }
//       });
//     } on PlatformException catch (e) {
//       print('gagal mencoba buka showdialog finger print');
//       Warning.showWarning('Your Fingerprint Not Supported');
//       print(e);
//     }
//     if (!mounted) return;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//           // return false;
//           exit(0);
//         },
//         child: Scaffold(
//             resizeToAvoidBottomInset: false,
//             backgroundColor: Colors.white,
//             body: loading == true
//                 ? Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 : Form(
//                     key: _keyForm,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             height: 50.0,
//                           ),
//                           Image(
//                             image: AssetImage("images/logo_only.jpg"),
//                             width: 200.0,
//                             height: 150.0,
//                             alignment: Alignment.center,
//                           ),
//                           SizedBox(
//                             height: 1.0,
//                           ),
//                           Text(
//                             "WrkPln",
//                             style: TextStyle(
//                                 fontSize: 24.0, fontFamily: "Brand Bold"),
//                             textAlign: TextAlign.center,
//                           ),
//                           Padding(
//                             padding: EdgeInsets.all(20.0),
//                             child: Column(
//                               children: [
//                                 SizedBox(
//                                   height: 1.0,
//                                 ),
//                                 TextFormField(
//                                   validator: requiredValidator,
//                                   controller: userIdCtrl,
//                                   keyboardType: TextInputType.text,
//                                   decoration: InputDecoration(
//                                     labelText: "User Id/ Email",
//                                     labelStyle: TextStyle(
//                                         fontSize: 14.0,
//                                         fontFamily: "Brand Bold"),
//                                     hintStyle: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 10.0,
//                                     ),
//                                   ),
//                                   style: TextStyle(
//                                       fontSize: 14.0, fontFamily: "Brand Bold"),
//                                 ),
//                                 SizedBox(
//                                   height: 1.0,
//                                 ),
//                                 TextFormField(
//                                   validator: requiredValidator,
//                                   controller: passwordCtrl,
//                                   obscureText: true,
//                                   keyboardType: TextInputType.text,
//                                   decoration: InputDecoration(
//                                     labelText: "Password",
//                                     labelStyle: TextStyle(
//                                         fontSize: 14.0,
//                                         fontFamily: "Brand Bold"),
//                                     hintStyle: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 10.0,
//                                     ),
//                                   ),
//                                   style: TextStyle(
//                                       fontSize: 14.0, fontFamily: "Brand Bold"),
//                                 ),
//                                 SizedBox(
//                                   height: 1.0,
//                                 ),
//                                 TextFormField(
//                                   validator: requiredValidator,
//                                   controller: companyCodeCtrl,
//                                   keyboardType: TextInputType.text,
//                                   decoration: InputDecoration(
//                                     labelText: "Company Code",
//                                     labelStyle: TextStyle(
//                                         fontSize: 14.0,
//                                         fontFamily: "Brand Bold"),
//                                     hintStyle: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 10.0,
//                                     ),
//                                   ),
//                                   style: TextStyle(
//                                       fontSize: 14.0, fontFamily: "Brand Bold"),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: SizedBox(
//                                     height: 1.0,
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                         flex: 1,
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             // if (_keyForm.currentState!.validate()) {
//                                             //   doLogin(context);
//                                             // }
//                                           },
//                                           child: Container(
//                                             alignment: Alignment.topLeft,
//                                             // color: WorkplanPallete.green,
//                                             child: const Text(
//                                               "",
//                                               style: TextStyle(
//                                                 fontSize: 15,
//                                                 color: Colors.black54,
//                                                 fontStyle: FontStyle.italic,
//                                                 decoration:
//                                                     TextDecoration.underline,
//                                               ),
//                                             ),
//                                             height: 20,
//                                           ),
//                                         )),
//                                     Expanded(
//                                         flex: 1,
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             // if (_keyForm.currentState!.validate()) {
//                                             //   doLogin(context);
//                                             // }
//                                             showDeleteDialog(context);
//                                           },
//                                           child: Container(
//                                             alignment: Alignment.topRight,
//                                             // color: WorkplanPallete.green,
//                                             child: const Text('Forgot Password',
//                                                 style: TextStyle(
//                                                   fontSize: 15,
//                                                   color: Colors.black54,
//                                                   fontStyle: FontStyle.italic,
//                                                   // fontWeight: FontWeight.italic,
//                                                   decoration:
//                                                       TextDecoration.underline,
//                                                 )),
//                                             height: 20,
//                                           ),
//                                         )),
//                                   ],
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: SizedBox(
//                                     height: 1.0,
//                                   ),
//                                 ),
//                                 Row(
//                                   children: <Widget>[
//                                     Expanded(
//                                         flex: 2,
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             if (_keyForm.currentState!
//                                                 .validate()) {
//                                               doLogin(context);
//                                             }
//                                           },
//                                           child: Container(
//                                             alignment: Alignment.topCenter,
//                                             color: WorkplanPallete.green,
//                                             child: Center(
//                                                 child: const Text(
//                                               'Login',
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold),
//                                             )),
//                                             height: 50,
//                                           ),
//                                         )),
//                                     Expanded(
//                                       child: Container(
//                                         alignment: Alignment.topCenter,
//                                         //color: Colors.yellow,
//                                         //child: Center(child: const Text('Button')),
//                                         height: 50,
//                                       ),
//                                     ),
//                                     //!isCheckedBiometrics
//                                     //? Container()
//                                     //:
//                                     Expanded(
//                                         child: Container(
//                                             alignment: Alignment.topCenter,
//                                             color: WorkplanPallete.grey,
//                                             child: IconButton(
//                                                 iconSize: 35,
//                                                 onPressed: () {
//                                                   // if (_keyForm.currentState!.validate()) {
//                                                   if (!isCheckedBiometrics) {
//                                                     print('masuk kesini');
//                                                     loginBiometrik("DAFTAR");
//                                                   } else {
//                                                     _authenticateMe();
//                                                   }
//                                                   // }
//                                                 },
//                                                 // onPressed:_authenticateMe,
//                                                 icon: Image.asset(
//                                                     "images/facial_recognition.png")
//                                                 // i
//                                                 ))),
//                                   ],
//                                 ),
//                                 // Row(
//                                 //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 //   children: [
//                                 //     Padding(
//                                 //       padding: const EdgeInsets.all(0.0),
//                                 //       child: ElevatedButton(
//                                 //           style: ElevatedButton.styleFrom(
//                                 //             primary: colorCustom,
//                                 //             shape: new RoundedRectangleBorder(
//                                 //                 borderRadius:
//                                 //                     new BorderRadius.circular(24.0)),
//                                 //           ),
//                                 //           child: Container(
//                                 //             height: 50.0,
//                                 //             // width: 250.0,
//                                 //             child: Center(
//                                 //                 child: Text(
//                                 //               "LOGIN",
//                                 //               style: TextStyle(
//                                 //                   fontSize: 18.0,
//                                 //                   fontFamily: "Brand Bold"),
//                                 //             )),
//                                 //           ),
//                                 //           onPressed: () {
//                                 //             if (_keyForm.currentState!.validate()) {
//                                 //               doLogin(context);
//                                 //             }
//                                 //           }),
//                                 //     ),
//                                 //     Padding(
//                                 //         padding: const EdgeInsets.all(8.0),
//                                 // child: IconButton(
//                                 //   iconSize: 40,
//                                 //   onPressed: _authenticateMe,
//                                 //   icon: Image.asset("images/facial_recognition.png")
//                                 //   // i
//                                 // ))
//                                 //   ],
//                                 // )
//                               ],
//                             ),
//                           ),
//                           Center(
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Container(
//                                 child: Text(
//                                   "version " + projectVersion,
//                                   style: TextStyle(
//                                       fontSize: 9, fontStyle: FontStyle.italic),
//                                 ),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   )));
//   }

//   void doLogin(BuildContext context) async {
//     String encryptedPassword = ConverterUtil().generateMd5(passwordCtrl.text);
//     String companyCode = companyCodeCtrl.text.toUpperCase();
//     String username = userIdCtrl.text;
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         // db.deleteUser();
//         loginApi(username, encryptedPassword, companyCode);
//       }
//     } on SocketException catch (_) {
//       Warning.showWarning("No Internet Connection");
//     }

//     // List<User> userList;

//     /*
//       ok Input User Id benar, Password dan Company Code salah	Tidak menampilkan notifikasi Password dan Company Code salah, tapi incorrect username/email/company code or password (sama untuk semua kondisi)
//       ok Input User Id dan Password benar, Company Code salah	Tidak menampilkan notifikasi Company Code salah, tapi incorrect username/email/company code or password (sama untuk semua kondisi)
//       ok Input User Id salah, Password dan Company Code benar	Tidak menampilkan notifikasi User Id salah, tapi incorrect username/email/company code or password (sama untuk semua kondisi)
//       ok Input User Id dan Password salah, Company Code benar	Tidak menampilkan notifikasi User Id salah, tapi incorrect username/email/company code or password (sama untuk semua kondisi)
//       mikir Input User Id salah, Password benar, Company Code salah	Tidak menampilkan notifikasi User Id dan Company Code salah, tapi incorrect username/email/company code or password (sama untuk semua kondisi)
//       ok Input User Id benar, Password salah, Company Code benar	Tidak menampilkan notifikasi Password salah, tapi incorrect username/email/company code or password (sama untuk semua kondisi)
//     */
//   }

//   // void initPlatformState() async {
//   //   String version;
//   //   try {
//   //     version = await GetVersion.projectVersion;
//   //   } on PlatformException {
//   //     version = 'Failed to get project version.';
//   //   }

//   //   if (!mounted) return;
//   //   setState(() {
//   //     projectVersion = version;
//   //   });
//   // }

//   void loginApi(
//       String username, String encryptedPassword, String companyCode) async {
//     var data = {
//       "username": username,
//     };
//     Warning.loading(context);
//     print('hit api <<<<<=========');
//     var response = await RestService()
//         .restRequestService(SystemParam.fLoginByUserIdOrEmail, data);

//     var convertDataToJson = json.decode(response.body);
//     var code = convertDataToJson['code'];
//     //var status = convertDataToJson['status'];
//     print(convertDataToJson);
//     String errorMsg = "";
//     bool isLogin = false;
//     bool isActive = true;
//     var user;

//     if (code == "0") {
//       await db.deleteUser();

//       UserModel userModel = userFromJson(response.body.toString());
//       List<User> userList = userModel.data;
//       // bool isInsert = false;

//       if (null != userList && userList.length < 1) {
//         errorMsg += "User Id";
//       }

//       if (null != userList &&
//           userList.length > 0 &&
//           userList[0].isLoginMobile == "1" &&
//           userList[0].deviceId != _deviceId) {
//         print("Device ID::::" +
//             userList[0].deviceId.toString() +
//             "::::" +
//             _deviceId.toString());
//         isLogin = true;
//       }

//       if (null != userList &&
//           userList.length > 0 &&
//           userList[0].encryptedPassword != encryptedPassword) {
//         if (errorMsg != "") {
//           errorMsg += ", Password";
//         } else {
//           errorMsg = "Password";
//         }
//       }

//       String errorCompany = "";
//       for (var i = 0; i < userList.length; i++) {
//         if (userList[i].companyCode.toUpperCase() ==
//             companyCode.toUpperCase()) {
//           user = userList[i];
//           errorCompany = "";

//           break;
//         } else {
//           //cek company tidak cocok
//           if (userList[i].companyCode.toUpperCase() !=
//               companyCode.toUpperCase()) {
//             errorCompany = "Company Code";
//           }
//         }
//       }

//       if (errorCompany != "") {
//         if (errorMsg != "") {
//           errorMsg += ", Company";
//         } else {
//           errorMsg += "Company";
//         }
//       }

//       if (errorMsg == "") {
//         for (var i = 0; i < userList.length; i++) {
//           /* INSERT USER */
//           db.insertUser(userList[i]);
//         }
//       }
//     } else {
//       Navigator.pop(context);
//       if (errorMsg != "") {
//         errorMsg += ", User Id";
//       } else {
//         errorMsg += "User Id";
//       }
//     }

//     if (errorMsg != "" || isLogin) {
//       String errMsg = "";
//       if (errorMsg != "") {
//         errMsg = errorMsg + " salah ";
//       } else {
//         errMsg = "User sudah login di device lain";
//       }
//       Navigator.pop(context);
//       Warning.showWarning(errMsg);
//       return;
//     } else {
//       bool isActive = true;
//       if (0 == user.employeeStatus) {
//         if (1 == user.resignFlag) {
//           DateTime dtNow = DateTime.now();
//           if (user.resignDate != null) {
//             if (dtNow.isAfter(user.resignDate)) {
//               //user inactive becouse resign date
//               isActive = false;
//             }
//           }
//         } else {
//           //user inactive
//           isActive = false;
//         }
//       }

//       if (!isActive) {
//         //USER INACTIVE
//         Warning.showWarning(
//             "User is not actived yet. Call the administrator !");
//         return;
//       } else if (null == user.lastSignInAt) {
//         //USER BARU
//         Navigator.pop(context);
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => NewChangePassword(
//                 user: user,
//                 rootAsal: 'loginScreen',
//               ),
//             ));
//       } else {
//         /* UPDATE IS LOGIN */
//         Navigator.pop(context);
//         onLoginSuccess(user);
//       }
//     }
//   }

//   void loginLocal(List<User> userList, String username,
//       String encryptedPassword, String companyCode) async {
//     String errorMsg = "";
//     var user;

//     if (null != userList && userList.length < 1) {
//       errorMsg += "User Id";
//     }

//     if (null != userList &&
//         userList.length > 0 &&
//         userList[0].isLoginMobile == "1" &&
//         userList[0].deviceId != _deviceId) {
//       errorMsg += "User sudah login di device lain";
//     }

//     if (null != userList &&
//         userList.length > 0 &&
//         userList[0].encryptedPassword != encryptedPassword) {
//       if (errorMsg != "") {
//         errorMsg += ", Password";
//       } else {
//         errorMsg = "Password";
//       }
//     }

//     String errorCompany = "";
//     for (var i = 0; i < userList.length; i++) {
//       if (userList[i].companyCode.toUpperCase() == companyCode.toUpperCase()) {
//         user = userList[i];
//         errorCompany = "";

//         break;
//       } else {
//         //cek company tidak cocok
//         if (userList[i].companyCode.toUpperCase() !=
//             companyCode.toUpperCase()) {
//           errorCompany = "Company Code";
//         }
//       }
//     }

//     if (errorCompany != "") {
//       if (errorMsg != "") {
//         errorMsg += ", Company";
//       } else {
//         errorMsg += "Company";
//       }
//     }

//     if (errorMsg != "") {
//       Warning.showWarning(errorMsg + "salah");
//       // Fluttertoast.showToast(
//       //     msg: errorMsg + " salah",
//       //     toastLength: Toast.LENGTH_SHORT,
//       //     gravity: ToastGravity.CENTER,
//       //     timeInSecForIosWeb: 1,
//       //     backgroundColor: Colors.red,
//       //     textColor: Colors.white,
//       //     fontSize: 16.0);
//     } else {
//       /* UPDATE IS LOGIN */
//       onLoginSuccess(user);
//       // updateIsLogin(user, "1");
//       // sessionTimer.startTimer(user);
//       // Navigator.push(
//       //     context,
//       //     MaterialPageRoute(
//       //       builder: (context) => LandingPage(
//       //         user: user,
//       //       ),
//       //     ));
//     }
//   }

//   void loginBiometrik(String type) async {
//     var user;
//     //Future<List<User>> userListFuture = db.getUserList();
//     await db.getUserList().then((value) {
//       if (value != null && value.length > 0) {
//         user = value[0];
//       }
//     });

//     print(user);
//     if (user == null) {
//       Warning.showWarning("Belum ada data Local, silahkan login manual terlebih dahulu");
//     } else {
//       try {
//         final result = await InternetAddress.lookup('example.com');
//         if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//           // db.getUserList().then((value)  {
//           // setState(() async {
//           //print("user.username" + user.username);
//           if (null != user) {
//             var data = {
//               "username": user.username,
//             };

//             var response = await RestService()
//                 .restRequestService(SystemParam.fLoginByUserIdOrEmail, data);

//             var convertDataToJson = json.decode(response.body);
//             var code = convertDataToJson['code'];

//             if (code == "0") {
//               UserModel userModel = userFromJson(response.body.toString());
//               List<User> userList = userModel.data;
//               await db.deleteUser();
//               for (var i = 0; i < userList.length; i++) {
//                 await db.insertUser(userList[i]);
//               }

//               if (userList.length > 1) {
//                 if (type == "LOGIN") {
//                   if (userList[0].isLoginMobile == "1" &&
//                       userList[0].deviceId != _deviceId) {
//                     Warning.showWarning("User sudah login di device lain");
//                     return;
//                   }
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => LoginChooseCompanyCode(
//                             userList: userList, deviceId: _deviceId),
//                       ));
//                 } else {
//                   /* DAFTAR */
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BiometrikTermAndCondition(
//                           user: user,
//                           page: "LOGIN",
//                         ),
//                       ));
//                 }
//               } else if (userList.length == 1) {
//                 for (var i = 0; i < userList.length; i++) {
//                   user = userList[i];
//                 }

//                 if (type == "LOGIN") {
//                   if (user.isLoginMobile == "1" && user.deviceId != _deviceId) {
//                     Warning.showWarning("User sudah login di device lain");
//                     return;
//                   }
//                   /* UPDATE IS LOGIN */
//                   onLoginSuccess(user);
//                   // updateIsLogin(user, "1");
//                   // sessionTimer.startTimer(user);
//                   // /* LOGIN */
//                   // Navigator.push(
//                   //     context,
//                   //     MaterialPageRoute(
//                   //       builder: (context) => LandingPage(
//                   //         user: user,
//                   //       ),
//                   //     ));
//                 } else {
//                   /* DAFTAR */
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => BiometrikTermAndCondition(
//                           user: user,
//                           page: "LOGIN",
//                         ),
//                       ));
//                 }
//               } else {
//                 Warning.showWarning("Silahkan login terlebih dahulu");
//               }
//             }
//           }
//           // });
//           // });
//         }
//       } on SocketException catch (_) {
//         //print('not connected');

//         db.getUserList().then((userList) {
//           // setState(() {
//           if (userList.length > 1) {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => LoginChooseCompanyCode(
//                     userList: userList,
//                     deviceId: _deviceId,
//                   ),
//                 ));
//           } else if (userList.length == 1) {
//             for (var i = 0; i < userList.length; i++) {
//               user = userList[i];
//             }

//             if (type == "LOGIN") {
//               /* UPDATE IS LOGIN */
//               onLoginSuccess(user);
//               // updateIsLogin(user, "1");
//               // sessionTimer.startTimer(user);
//               // /* LOGIN */
//               // Navigator.push(
//               //     context,
//               //     MaterialPageRoute(
//               //       builder: (context) => LandingPage(
//               //         user: user,
//               //       ),
//               //     ));
//             } else {
//               /* DAFTAR */
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => BiometrikTermAndCondition(
//                       user: user,
//                       page: "LOGIN",
//                     ),
//                   ));
//             }
//           } else {
//             Warning.showWarning("Silahkan login terlebih dahulu");
//           }
//           // });
//         });
//       }
//     }
//   }

//   Future<bool> getAvailabelBioMetrics() async {
//     List<BiometricType> availableBiometrics =
//         await _localAuthentication.getAvailableBiometrics();
//     bool isAvailable = true;
//     if (Platform.isIOS) {
//       if (!availableBiometrics.contains(BiometricType.face)) {
//         // !Face ID.
//         isAvailable = false;
//       }
//     }

//     if (Platform.isAndroid) {
//       if (!availableBiometrics.contains(BiometricType.face)) {
//         // !Face ID.
//         isAvailable = false;
//       }
//     }
//     return isAvailable;
//   }

//   showDeleteDialog(BuildContext context) async {
//     // set up the buttons
//     Widget cancelButton = ElevatedButton(
//       child: Text("Cancel"),
//       style: ElevatedButton.styleFrom(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         primary: Colors.green,
//       ),
//       onPressed: () {
//         Navigator.of(context).pop();
//       },
//     );
//     Widget continueButton = ElevatedButton(
//       child: Text("Reset Password"),
//       style: ElevatedButton.styleFrom(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//           primary: Colors.red),
//       onPressed: resetPassword,
//     );
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("Reset Password"),
//       content: SingleChildScrollView(
//           child: Column(
//         children: [
//           TextFormField(
//             validator: requiredValidator,
//             controller: nomorHpDialogCtrl,
//             keyboardType: TextInputType.phone,
//             decoration: InputDecoration(
//               labelText: "Input Nomor HP",
//               labelStyle: TextStyle(fontSize: 14.0, fontFamily: "Brand Bold"),
//               hintStyle: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 10.0,
//               ),
//             ),
//             style: TextStyle(fontSize: 14.0, fontFamily: "Brand Bold"),
//           ),
//           // TextFormField(
//           //   validator: requiredValidator,
//           //   controller: userIdDialogCtrl,
//           //   keyboardType: TextInputType.text,
//           //   decoration: InputDecoration(
//           //     labelText: "User Id/ Email",
//           //     labelStyle: TextStyle(fontSize: 14.0, fontFamily: "Brand Bold"),
//           //     hintStyle: TextStyle(
//           //       color: Colors.grey,
//           //       fontSize: 10.0,
//           //     ),
//           //   ),
//           //   style: TextStyle(fontSize: 14.0, fontFamily: "Brand Bold"),
//           // ),
//           // SizedBox(
//           //   height: 1.0,
//           // ),
//           // TextFormField(
//           //   validator: requiredValidator,
//           //   controller: companyCodeDialogCtrl,
//           //   keyboardType: TextInputType.text,
//           //   decoration: InputDecoration(
//           //     labelText: "Company Code",
//           //     labelStyle: TextStyle(fontSize: 14.0, fontFamily: "Brand Bold"),
//           //     hintStyle: TextStyle(
//           //       color: Colors.grey,
//           //       fontSize: 10.0,
//           //     ),
//           //   ),
//           //   style: TextStyle(fontSize: 14.0, fontFamily: "Brand Bold"),
//           // ),
//         ],
//       )),
//       actions: [
//         cancelButton,
//         continueButton,
//       ],
//     );
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }

//   void resetPassword() async {
//     if (nomorHpDialogCtrl.text == "") {
//       Warning.showWarning("Nomor HP harus diisi");

//       return;
//     }

//     String datetime = SystemParam.formatDateTimeUnique.format(DateTime.now());
//     String token = datetime + nomorHpDialogCtrl.text;
//     // String pesan ="Jika anda melakukan permintaan reset password WrkPln klik link berikut, "+tokenUrl+token.toUpperCase();

//     //fUpdateUserToken
//     var data = {
//       "token": token.toUpperCase(),
//       "phone": nomorHpDialogCtrl.text,
//       //"message":pesan
//     };

//     // var response = await RestService()
//     //     .restRequestService(SystemParam.fUpdateUserToken, data);
//     var response = await RestService()
//         .restRequestService(SystemParam.fResetPassword, data);
//     var responToJson = json.decode(response.body);
//     var code = responToJson['code'];

//     if (code == "0") {
//       //delete users
//       //await db.deleteUser();

//       // var dataPesan = {
//       //   "userkey": smsGatewayUserKey,
//       //   "passkey": smsGatewayPassKey,
//       //   "nohp": nomorHpDialogCtrl.text,
//       //   "pesan": pesan
//       // };

//       // var responsePesan = await RestService()
//       //     .restRequestServiceOthers(smsGatewayAPI, dataPesan);
//       // print("convertDataToJsonPesan:"+responsePesan.body);

//       Navigator.of(context).pop();

//       Warning.showWarning("Reset password berhasil, silahkan cek pesan anda.");

//       // Navigator.push(
//       //     context, MaterialPageRoute(builder: (context) => LoginScreen()));
//     } else {
//       Warning.showWarning(
//           "Reset password gagal, silahkan hubungi admin perusahaan anda.");
//     }
//   }

//   void initUser() async {
//     loading = true;
//     print('masuk ke init device');
//     db.getUserList().then((value) {
//       print(value);
//       if (value.length > 0) {
//         print('ada db local');
//         setState(() {
//           late User userDb = value[0];
//           print("isBiometrik");
//           print(userDb.isBiometrik);
//           if (userDb.isBiometrik == "1") {
//             isCheckedBiometrics = true;
//             _authenticateMe();
//           } else {
//             isCheckedBiometrics = false;
//           }

//           loading = false;
//         });
//       }
//     });
//     loading = false;
//   }

//   void updateIsLogin(User user, String isLogin) async {
//     // Flutter
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         var dataPassword = {
//           "id": user.id,
//           "updated_by": user.id,
//           "is_login_mobile": isLogin,
//           "device_id": _deviceId
//         };

//         var response = await RestService()
//             .restRequestService(SystemParam.fUpdateIsLogin, dataPassword);

//         var convertDataToJson = json.decode(response.body);
//         var code = convertDataToJson['code'];
//         print("code is login response:" + code);
//       }
//     } on SocketException catch (_) {
//       Warning.showWarning('No Internet Connection');
//     }
//   }

//   onLoginSuccess(user) {
//     SessionTimer sessionTimer = new SessionTimer(user);
//     sessionTimer.startTimer(user);
//     updateIsLogin(user, "1");

//     Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               LandingPage(user: user, sessionTimer: sessionTimer),
//         ));
//   }

//   // void initSmsGateway() async{
//   //   setState(() {
//   //       db.getParameterByCode(SystemParam.parameterCodeSmsGatewayAPI).then((value) {
//   //         smsGatewayAPI = value.parameterValue;
//   //       });

//   //       db.getParameterByCode(SystemParam.parameterCodeSmsGatewayUserKey).then((value) {
//   //         smsGatewayUserKey = value.parameterValue;
//   //       });

//   //       db.getParameterByCode(SystemParam.parameterCodeSmsGatewayPassKey).then((value) {
//   //         smsGatewayPassKey = value.parameterValue;
//   //       });

//   //       db.getParameterByCode(SystemParam.parameterCodeTokenUrl).then((value) {
//   //         tokenUrl = value.parameterValue;
//   //       });

//   //   });
//   // }
// }
