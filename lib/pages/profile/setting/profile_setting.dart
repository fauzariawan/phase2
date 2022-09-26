import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/converter.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/dropdown_item.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/parameter_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/loginscreen.dart';
import 'package:workplan_beta_test/pages/profile/profile_page.dart';
import 'package:workplan_beta_test/main_pages/constans.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

import '../../biometrik_termandcondition.dart';

class ProfileSetting extends StatefulWidget {
  final User user;
  // final Timer timer;
  // final PersonalInfoProfilData profileInfo;
  const ProfileSetting({
    Key? key,
    required this.user,
    // required this.timer
  }) : super(key: key);

  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  bool loading = false;

  late List<Parameter> languageTypeList;
  List<DropdownMenuItem<int>> itemsLanguageType = <DropdownMenuItem<int>>[];
  int languageTypeValue = SystemParam.defaultValueOptionId;

  TextEditingController _currentPasswordCtrl = new TextEditingController();
  TextEditingController _newPasswordCtrl = new TextEditingController();
  TextEditingController _confirmPasswordCtrl = new TextEditingController();
  bool isCheckedBiometrics = false;
  var isBiometrics = "0";
  var db = new DatabaseHelper();
  late User user = widget.user;
  User? updateUser;
  Timer? timer;
  int count = 0;

  @override
  void initState() {
    super.initState();
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   int? limit = widget.user.timeoutLogin * 60;
    //   print('ini limit time logout nhya');
    //   print(limit);
    //   if (count < limit) {
    //     print(count);
    //     setState(() {
    //       count++;
    //     });
    //   } else {
    //     timer.cancel();
    //     Helper.updateIsLogin(widget.user, 0);
    //     Navigator.of(context).pushNamedAndRemoveUntil(
    //         loginScreen, (Route<dynamic> route) => false);
    //   }
    // });

    initUser();
    // initParameterLanguageType();
    // ignore: unnecessary_null_comparison
  }

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
      },
      child: WillPopScope(
        onWillPop: () async {
          // timer!.cancel();
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LandingPage(
                  user: widget.user,
                  currentIndex: 1,
                ),
              ));
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Setting'),
            centerTitle: true,
            backgroundColor: SystemParam.colorCustom,
            automaticallyImplyLeading: false,
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back, color: Colors.black),
            //   onPressed: () {
            //     // Navigator.push(
            //     //     context,
            //     //     MaterialPageRoute(
            //     //       builder: (context) => ProfilePage(
            //     //         user: user,
            //     //       ),
            //     //     ));
            //   },
            // ),
          ),
          body: loading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // ini file pemilihan bahasa
                        // Padding(
                        //   padding: const EdgeInsets.only(left: 8.0),
                        //   child: RichText(
                        //     text: TextSpan(
                        //       children: <TextSpan>[
                        //         TextSpan(
                        //             text: 'Bahasa',
                        //             style: TextStyle(
                        //                 backgroundColor: Theme.of(context)
                        //                     .scaffoldBackgroundColor,
                        //                 color: SystemParam.colorCustom,
                        //                 fontWeight: FontWeight.w400,
                        //                 fontSize: 14)),
                        //         TextSpan(
                        //             text: ' ',
                        //             style: TextStyle(
                        //                 fontWeight: FontWeight.w500,
                        //                 fontSize: 14,
                        //                 backgroundColor: Theme.of(context)
                        //                     .scaffoldBackgroundColor,
                        //                 color: Colors.red)),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   // child: DropdownButtonHideUnderline(
                        //   child: DropdownButtonFormField<int>(
                        //     decoration: InputDecoration(
                        //       //icon: new Icon(Ionicons.person),
                        //       //errorText: "this field is required",
                        //       fillColor: SystemParam.colorCustom,
                        //       labelStyle: TextStyle(
                        //           color: SystemParam.colorCustom,
                        //           fontStyle: FontStyle.normal),
                        //       enabledBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //               color: SystemParam.colorCustom),
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(10))),
                        //       focusedBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //               color: SystemParam.colorCustom),
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(10))),
                        //       contentPadding: EdgeInsets.all(10),
                        //     ),
                        //     validator: (value) {
                        //       //print("validaor select:" + value.toString());
                        //       // ignore: unrelated_type_equality_checks
                        //       if (value == 0 || value == null) {
                        //         return "this field is required";
                        //       }
                        //       return null;
                        //     },
                        //     value: languageTypeValue,
                        //     items: itemsLanguageType,
                        //     onChanged: (object) {
                        //       setState(() {
                        //         // genderSelected = object!;
                        //         languageTypeValue = object!;
                        //       });
                        //     },
                        //   ),
                        // ),
                        if (widget.user.validationFaceType == 2)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                      checkColor: Colors.white,
                                      fillColor:
                                          MaterialStateProperty.resolveWith(
                                              getColor),
                                      value: isCheckedBiometrics, //isChecked,
                                      onChanged: (bool? value) {
                                        if (updateUser!.isBiometrik == "1") {
                                          print(value);
                                          setState(() {
                                            isCheckedBiometrics = value!;
                                          });
                                          return;
                                        }
                                        setState(() {
                                          if (!isCheckedBiometrics) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BiometrikTermAndCondition(
                                                          user: widget.user,
                                                          page: "PROFILE"),
                                                ));
                                          }
                                          isCheckedBiometrics = value!;
                                        });
                                        // setState(() {
                                        //   isChecked = value!;
                                        // });
                                      }),
                                  // Checkbox(
                                  //   checkColor: Colors.white,
                                  //   fillColor:
                                  //       MaterialStateProperty.resolveWith(
                                  //           getColor),
                                  //   value: isCheckedBiometrics,
                                  //   onChanged: (bool? value) {
                                  //     print(value);
                                  //     // setState(() {
                                  //     //   if (!isCheckedBiometrics) {
                                  //     //     timer!.cancel();
                                  //     //     Navigator.push(
                                  //     //         context,
                                  //     //         MaterialPageRoute(
                                  //     //           builder: (context) =>
                                  //     //               BiometrikTermAndCondition(
                                  //     //                   user: widget.user,
                                  //     //                   page: "PROFILE"),
                                  //     //         ));
                                  //     //   }
                                  //     //   isCheckedBiometrics = value!;
                                  //     // });
                                  //   },
                                  // ),
                                  Text(
                                    "Login dengan pengenalan wajah (biometrics)",
                                    // "Login dengan Face Recognition",
                                    style: TextStyle(
                                        color: SystemParam.colorDivider),
                                  ),
                                ],
                              ),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text('Register Face Recognition'),
                              //     SizedBox(
                              //         height: 30,
                              //         child: ElevatedButton(
                              //             onPressed: () {
                              //               if (user.isFaceRecognitionRegistered ==
                              //                   1) {
                              //                 if (user.isFaceRecognitionValidated ==
                              //                         0 ||
                              //                     user.isFaceRecognitionValidated ==
                              //                         1) {
                              //                   Warning.showWarning(
                              //                       'Proses register sedang menunggu persetujuan');
                              //                 } else {
                              //                   Navigator.pushNamed(
                              //                       context, termsAndConditions,
                              //                       arguments: {
                              //                         "user": user,
                              //                         "type": user.isFaceRecognitionRegistered ==
                              //                                     1 &&
                              //                                 (user.isFaceRecognitionValidated ==
                              //                                         2 ||
                              //                                     user.isFaceRecognitionValidated ==
                              //                                         1 ||
                              //                                     user.isFaceRecognitionValidated ==
                              //                                         3)
                              //                             ? "Ulang"
                              //                             : "awal"
                              //                       });
                              //                 }
                              //               } else {
                              //                 Navigator.pushNamed(
                              //                     context, termsAndConditions,
                              //                     arguments: {
                              //                       "user": user,
                              //                       "type": user.isFaceRecognitionRegistered ==
                              //                                   1 &&
                              //                               (user.isFaceRecognitionValidated ==
                              //                                       2 ||
                              //                                   user.isFaceRecognitionValidated ==
                              //                                       1 ||
                              //                                   user.isFaceRecognitionValidated ==
                              //                                       3)
                              //                           ? "Ulang"
                              //                           : "awal"
                              //                     });
                              //               }
                              //             },
                              //             child: Text('Register')))
                              //   ],
                              // )
                            ],
                          ),
                        // if (user.isFaceRecognitionRegistered == 1 &&
                        //     (user.isFaceRecognitionValidated == 0 ||
                        //         user.isFaceRecognitionValidated == 1))
                        //   Text(
                        //     "Proses register sedang menunggu persetujuan",
                        //     style: TextStyle(fontSize: 10, color: Colors.red),
                        //   ),
                        // SizedBox(height: Reuseable.jarak3),
                        Divider(
                          color: SystemParam.colorDivider,
                          thickness: 2,
                        ),
                        SizedBox(
                          height: Reuseable.jarak2,
                        ),
                        Text("Current Password", style: Reuseable.titleStyle),
                        SizedBox(
                          height: Reuseable.jarak1,
                        ),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: new TextStyle(color: Colors.black),
                            controller: _currentPasswordCtrl,
                            //initialValue: widget.datum.writtingScore.toString(),
                            readOnly: false,
                            obscureText: true,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(
                          height: Reuseable.jarak2,
                        ),
                        Text("New Password", style: Reuseable.titleStyle),
                        SizedBox(
                          height: Reuseable.jarak1,
                        ),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: new TextStyle(color: Colors.black),
                            controller: _newPasswordCtrl,
                            //initialValue: widget.datum.writtingScore.toString(),
                            readOnly: false,
                            obscureText: true,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(
                          height: Reuseable.jarak2,
                        ),
                        Text("Password Confirmation",
                            style: Reuseable.titleStyle),
                        SizedBox(
                          height: Reuseable.jarak2,
                        ),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            style: new TextStyle(color: Colors.black),
                            controller: _confirmPasswordCtrl,
                            readOnly: false,
                            obscureText: true,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(
                          height: Reuseable.jarak3,
                        ),
                        // Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: SystemParam.colorCustom,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text("UPDATE"),
                            onPressed: () {
                              saveData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void saveData() async {
    if (_currentPasswordCtrl.text == "" &&
        _newPasswordCtrl.text == "" &&
        _confirmPasswordCtrl.text == "") {
      //UPDATE BAHASA dan biometrik saja
      doSave(SystemParam.fUpdateLanguageBiometrik);
    } else {
      var userCurrentPassword = user.encryptedPassword;
      var currentPassword =
          ConverterUtil().generateMd5(_currentPasswordCtrl.text);

      if (userCurrentPassword != currentPassword) {
        Fluttertoast.showToast(
            msg: "Current Password tidak sesuai ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      // if (!validateStructure(_newPasswordCtrl.text)) {
      if (_newPasswordCtrl.text.length < 8) {
        Fluttertoast.showToast(
            // msg:"Password harus mengandung: \n Minimum 8 Character \n Minimum 1 Upper case \n Minimum 1 lowercase \n Minimum 1 Numeric Number ",
            msg: "Password harus mengandung minimum 8 character ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

        return;
      }

      if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
        Fluttertoast.showToast(
            msg: "New Password dan Confirmation Password tidak sesuai ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        return;
      }

      doSave(SystemParam.fChangePassword);
    }
  }

  void initParameterLanguageType() async {
    itemsLanguageType.clear();
    languageTypeList = <Parameter>[];
    //loading = true;
    ParameterModel parameterModel;
    var data = {
      "parameter_type": SystemParam.parameterTypeLanguageType,
      "company_id": user.userCompanyId
    };

    var response = await RestService()
        .restRequestService(SystemParam.fParameterByTypeCompanyId, data);

    setState(() {
      parameterModel = parameterModelFromJson(response.body.toString());
      languageTypeList = parameterModel.data;
      itemsLanguageType.add(DropdownItem.getItemParameter(
          SystemParam.defaultValueOptionId,
          SystemParam.defaultValueOptionDesc));
      for (var i = 0; i < languageTypeList.length; i++) {
        itemsLanguageType.add(DropdownItem.getItemParameter(
            languageTypeList[i].id, languageTypeList[i].parameterValue));

        if (user.languageType != null &&
            languageTypeList[i].id == user.languageType) {
          languageTypeValue = user.languageType;
        }
      }

      //loading = false;
    });
  }

  bool validateStructure(String value) {
    /*
      Minimum 1 Upper case
      Minimum 1 lowercase
      Minimum 1 Numeric Number
      ----- tifak pake Special Character
      Minimum 1 Special Character
      Common Allow Character ( ! @ # $ & * ~ )
      String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    */
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  void doSave(function) async {
    if (isCheckedBiometrics) {
      isBiometrics = "1";
    } else {
      isBiometrics = "0";
    }

    var data = {
      "id": user.id,
      "encrypted_password": ConverterUtil().generateMd5(_newPasswordCtrl.text),
      "language_type": languageTypeValue,
      "is_biometrik": isBiometrics

      // "new_password": _newPasswordCtrl.text,
      // "confirmation_password": _confirmPasswordCtrl.text,
    };

    //minimal password = 8 digit terdiri dari Angka, Huruf Besar dan huruf kecil

    print(data);

    var response = await RestService().restRequestService(function, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];

    if (code == "0") {
      if (function == SystemParam.fChangePassword) {
        /* UPDATE USER */
        user.encryptedPassword =
            ConverterUtil().generateMd5(_newPasswordCtrl.text);
        db.updateUser(user);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        /* UPDATE USER */
        user.isBiometrik = isBiometrics;
        user.languageType = languageTypeValue;

        db.updateUser(user);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfileSetting(
                      user: user, /*timer: timer!*/
                      // profileInfo: widget.profileInfo,
                    )));
      }

      Fluttertoast.showToast(
          msg: "Update Data Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: SystemParam.colorCustom,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      print(status);
      Fluttertoast.showToast(
          msg: "Mohon Maaf, Anda Gagal Update Data :",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void initUser() async {
    // loading = true;
    late User dataUser;
    var data = {
      "username": widget.user.username,
    };

    print('hit api <<<<<=========');
    var response = await RestService()
        .restRequestService(SystemParam.fLoginByUserIdOrEmail, data);
    print('ini data user');
    var responseToJson = jsonDecode(response.body);
    var users = responseToJson['data'];
    print(users);
    for (var user in users) {
      if (user['id'] == widget.user.id &&
          user['company_id'] == widget.user.userCompanyId) {
        dataUser = User.fromJson(user);
        updateUser = dataUser;
      }
    }

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // User dataUser =
    //     User.fromJson(jsonDecode(prefs.getString("dataUser").toString()));
    print(dataUser);
    print("IS FACE RECOGNITION REGISTERED");
    print(dataUser.isFaceRecognitionRegistered);
    print("IS FACE RECOGNITION VALIDATED");
    print(dataUser.isFaceRecognitionValidated);
    // super.initState();
    // widget.timer.cancel();
    setState(() {
      isChecked = dataUser.isFaceRecognitionRegistered == 1 &&
              (dataUser.isFaceRecognitionValidated == 2 ||
                  dataUser.isFaceRecognitionValidated == 1 ||
                  dataUser.isFaceRecognitionValidated == 3)
          ? true
          : false;
    });

    print('apakah di cheklist');
    print(isChecked);
    isBiometrics = dataUser.isBiometrik;
    print('apakah bisa biometrik');
    print(isBiometrics);
    if (dataUser.isBiometrik == "1") {
      isCheckedBiometrics = true;
    } else {
      isCheckedBiometrics = false;
    }
    print('masuk ke sini');
    // loading = false;
    // db.getUserListByUsername(userDb.username).then((value) {
    //   setState(() {
    //     userDb = value[0];
    //     // ignore: unnecessary_null_comparison
    //     if (userDb.languageType != null) {
    //       languageTypeValue = userDb.languageType;
    //     }

    //     isBiometrics = userDb.isBiometrik;
    //     if (userDb.isBiometrik == "1") {
    //       isCheckedBiometrics = true;
    //     } else {
    //       isCheckedBiometrics = false;
    //     }

    //     loading = false;
    //   });
    // });
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var data = prefs.getString("dataUser");
    // print(data);

    // print('masuk ke init user local db <<<<<<<====');
    // print(user.userCompanyId);
    // db.getUserById(user.userCompanyId.toString()).then((value) {
    //   setState(() {
    //     // user = value;
    //     // ignore: unnecessary_null_comparison
    //     user = widget.user;
    //     isBiometrics = user.isBiometrik;
    //     if (user.isBiometrik == "1") {
    //       isCheckedBiometrics = true;
    //     } else {
    //       isCheckedBiometrics = false;
    //     }

    //     loading = false;
    //   });
    // });
  }
}
