import 'dart:async';
import 'dart:convert';

//import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/dropdown_item.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/parameter_model.dart';
import 'package:workplan_beta_test/model/personal_family_model.dart';
import 'package:workplan_beta_test/model/personal_info_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/profile/info/profile_family_edit.dart';
import 'package:workplan_beta_test/pages/profile/profile_page.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class ProfilePersonal extends StatefulWidget {
  // final
  final User user;
  final PersonalInfoProfilData profile;
  // final Timer timer;

  //const SkillEditLanguage({ Key? key }) : super(key: key);

  const ProfilePersonal({
    Key? key,
    required this.user,
    required this.profile,
    // required this.timer
  }) : super(key: key);

  @override
  _ProfilePersonalState createState() => _ProfilePersonalState();
}

class _ProfilePersonalState extends State<ProfilePersonal> {
  // late String _valGender;
  // List _listGender = ["Male","Female"];  //Array gender
  final _keyForm = GlobalKey<FormState>();
  final format = DateFormat("yyyy-MM-dd HH:mm:ss");
  // var userId = 1;
  bool enabled = true;
  bool loading = false;
  Timer? timer;
  // late PersonalInfoProfilData widget.personalInfoProfilData;
  // ignore: avoid_init_to_null
  // var dateOfBirthday = null;
  // DateTime? dateOfBirthday;

  TextEditingController _nama = TextEditingController();
  TextEditingController _nama2 = TextEditingController();
  TextEditingController _nama3 = TextEditingController();
  String _dateOfBirthValue = "";
  TextEditingController _taxnumber = TextEditingController();
  TextEditingController _taxaddress = TextEditingController();
  TextEditingController _identityCardNumber = TextEditingController();
  TextEditingController _identityCardAddress = TextEditingController();
  TextEditingController _placebirthday = TextEditingController();

  TextEditingController _heightCtrl = TextEditingController();
  TextEditingController _weightCtrl = TextEditingController();
  TextEditingController _sickHistoryCtrl = TextEditingController();
  // TextEditingController _birthDateCtrl  = TextEditingController();
//  late List<Parameter> genderList;
  late List<Parameter> genderList;
  List<DropdownMenuItem<int>> itemsGender = <DropdownMenuItem<int>>[];
  int genderValue = SystemParam.defaultValueOptionId;

  late List<Parameter> maritalStatusList;
  List<DropdownMenuItem<int>> itemsMaritalStatus = <DropdownMenuItem<int>>[];
  int maritalStatusValue = SystemParam.defaultValueOptionId;

  late List<Parameter> religionList;
  List<DropdownMenuItem<int>> itemsReligion = <DropdownMenuItem<int>>[
    DropdownMenuItem(
      value: 1,
      child: Text('A', style: TextStyle(fontSize: 14, color: Colors.black)),
    ),
    DropdownMenuItem(
      value: 2,
      child: Text('B', style: TextStyle(fontSize: 14, color: Colors.black)),
    ),
  ];
  int religionValue = SystemParam.defaultValueOptionId;

  late List<Parameter> nationalityList;
  List<DropdownMenuItem<int>> itemsNationality = <DropdownMenuItem<int>>[];
  int nationalityValue = SystemParam.defaultValueOptionId;

  late List<Parameter> bloodGroupList;
  List<DropdownMenuItem<int>> itemsBloodGroup = <DropdownMenuItem<int>>[
    DropdownMenuItem(
      value: 1,
      child: Text('A', style: TextStyle(fontSize: 14, color: Colors.black)),
    ),
    DropdownMenuItem(
      value: 2,
      child: Text('B', style: TextStyle(fontSize: 14, color: Colors.black)),
    ),
    DropdownMenuItem(
      value: 3,
      child: Text('AB', style: TextStyle(fontSize: 14, color: Colors.black)),
    ),
    DropdownMenuItem(
      value: 4,
      child: Text('O', style: TextStyle(fontSize: 14, color: Colors.black)),
    )
  ];
  int bloodGroupValue = SystemParam.defaultValueOptionId;

  int familyCount = 0;
  List<FamilyData> familyList = <FamilyData>[];

  var _radioIsUseGlasses = "0";
  String _useGlasses = "1";
  String _noUseGlasses = "0";
  int count = 0;

  @override
  void initState() {
    super.initState();
    // widget.timer.cancel();
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
    loading = true;
    _radioIsUseGlasses = "0";

    getFamilyList();
    initParameterGender();
    initParameterMaritalStatus();
    initParameterReligion();
    initParameterNationality();
    // initParameterBloodGroup();
    // getMyPersonal();
    initPersonalData();
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    double jarak1 = 5;
    double jarak2 = 10;

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        count = 0;
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
              //drawer: NavigationDrawerWidget(),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text('Personal'),
                centerTitle: true,
                backgroundColor: SystemParam.colorCustom,
                // leading: IconButton(
                //   icon: Icon(Icons.arrow_back, color: Colors.black),
                //   //onPressed: () => Navigator.of(context).pop(),
                //   onPressed: () {
                //     // Navigator.push(
                //     //     context,
                //     //     MaterialPageRoute(
                //     //       builder: (context) =>
                //     //           ProfilePage(user: widget.user),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          children: [
                            Form(
                              key: _keyForm,
                              // autovalidate: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 10),
                                  mainTitle('Basic Info'),
                                  Text('Nama Depan',
                                      style: Reuseable.titleStyle),
                                  SizedBox(
                                    height: jarak1,
                                  ),
                                  TextFormField(
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _nama,
                                      //initialValue: "",
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(height: jarak2),
                                  Text('Nama Tengah',
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  TextFormField(
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _nama2,
                                      //initialValue: "",
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(
                                    height: jarak2,
                                  ),
                                  Text('Nama Belakang',
                                      style: Reuseable.titleStyle),
                                  SizedBox(
                                    height: jarak1,
                                  ),
                                  TextFormField(
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _nama3,
                                      //initialValue: "",
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(height: jarak2),
                                  Text("Jenis Kelamin",
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  DropdownButtonFormField<int>(
                                    decoration: Reuseable.inputDecoration,
                                    value: genderValue,
                                    items: itemsGender,
                                    onChanged: !enabled
                                        ? null
                                        : (object) {
                                            setState(() {
                                              genderValue = object!;
                                            });
                                          },
                                  ),
                                  SizedBox(
                                    height: jarak2,
                                  ),
                                  Text("Tempat Lahir",
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  TextFormField(
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _placebirthday,
                                      //initialValue: widget.datum.writtingScore.toString(),
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(height: jarak2),
                                  Text("Tanggal Lahir"),
                                  SizedBox(height: jarak1),
                                  DateTimeField(
                                      initialValue:
                                          widget.profile.dateOfBirthday,
                                      enabled: enabled,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      onSaved: (valueDate) {
                                        _dateOfBirthValue = SystemParam
                                            .formatDateValue
                                            .format(valueDate!);
                                      },
                                      onChanged: (valueDate) {
                                        _dateOfBirthValue = SystemParam
                                            .formatDateValue
                                            .format(valueDate!);
                                      },
                                      format: SystemParam.formatDateDisplay,
                                      onShowPicker: (context, currentValue) {
                                        return showDatePicker(
                                            context: context,
                                            locale: Locale('id'),
                                            firstDate:
                                                DateTime(SystemParam.firstDate),
                                            initialDate:
                                                currentValue ?? DateTime.now(),
                                            lastDate:
                                                DateTime(SystemParam.lastDate),
                                            fieldHintText:
                                                SystemParam.strFormatDateHint);
                                      },
                                      decoration:
                                          Reuseable.inputDecorationDate),
                                  SizedBox(height: jarak2),
                                  Text("Agama", style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  DropdownButtonFormField<int>(
                                    decoration: Reuseable.inputDecoration,
                                    value: religionValue,
                                    items: itemsReligion,
                                    onChanged: !enabled
                                        ? null
                                        : (object) {
                                            setState(() {
                                              religionValue = object!;
                                            });
                                          },
                                  ),
                                  SizedBox(height: jarak2),
                                  Text("Status Pernikahan",
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  DropdownButtonFormField<int>(
                                    decoration: Reuseable.inputDecoration,
                                    value: maritalStatusValue,
                                    items: itemsMaritalStatus,
                                    onChanged: !enabled
                                        ? null
                                        : (object) {
                                            setState(() {
                                              // genderSelected = object!;
                                              maritalStatusValue = object!;
                                            });
                                          },
                                  ),
                                  SizedBox(height: jarak2),
                                  Text("Kewarganegaraan",
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  DropdownButtonFormField<int>(
                                    decoration: Reuseable.inputDecoration,
                                    value: nationalityValue,
                                    items: itemsNationality,
                                    onChanged: !enabled
                                        ? null
                                        : (object) {
                                            setState(() {
                                              // genderSelected = object!;
                                              nationalityValue = object!;
                                            });
                                          },
                                  ),
                                  SizedBox(height: 20),
                                  mainTitle('Identitas'),
                                  SizedBox(height: 20),
                                  Text("Nomor KTP",
                                      style: Reuseable.titleStyle),
                                  SizedBox(
                                    height: jarak1,
                                  ),
                                  TextFormField(
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _identityCardNumber,
                                      //initialValue: widget.datum.writtingScore.toString(),
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(height: jarak2),
                                  Text("Nomor NPWP",
                                      style: Reuseable.titleStyle),
                                  SizedBox(width: jarak1),
                                  TextFormField(
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _taxnumber,
                                      inputFormatters: [
                                        SystemParam.maskFormatterNPWP
                                      ],
                                      //initialValue: widget.datum.writtingScore.toString(),
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(height: 20),
                                  mainTitle('Kesehatan'),
                                  SizedBox(height: 20),
                                  Text("Golongan Darah",
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  DropdownButtonFormField<int>(
                                    decoration: Reuseable.inputDecoration,
                                    value: bloodGroupValue,
                                    items: itemsBloodGroup,
                                    onChanged: !enabled
                                        ? null
                                        : (object) {
                                            setState(() {
                                              bloodGroupValue = object!;
                                            });
                                          },
                                  ),
                                  SizedBox(height: jarak2),
                                  Text("Memakai Kacamata",
                                      style: Reuseable.titleStyle),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Radio(
                                        activeColor: SystemParam.colorCustom,
                                        // fillColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                                        value: _noUseGlasses,
                                        groupValue: _radioIsUseGlasses,
                                        onChanged: (em) {
                                          // if (em != null) {
                                          setState(() {
                                            _radioIsUseGlasses = _noUseGlasses;
                                          });
                                          // }
                                        },
                                      ),
                                      new Text(
                                        'Tidak',
                                        style: new TextStyle(fontSize: 16.0),
                                      ),
                                      new Radio(
                                        activeColor: SystemParam.colorCustom,
                                        value: _useGlasses,
                                        groupValue: _radioIsUseGlasses,
                                        onChanged: (em) {
                                          // if (em != null) {
                                          setState(() {
                                            _radioIsUseGlasses = _useGlasses;
                                          });
                                          // }
                                        },
                                      ),
                                      new Text(
                                        'Ya',
                                        style: new TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text("Tinggi Badan",
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  TextFormField(
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _heightCtrl,
                                      //initialValue: widget.datum.writtingScore.toString(),
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(height: jarak2),
                                  Text("Berat Badan",
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  TextFormField(
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _weightCtrl,
                                      //initialValue: widget.datum.writtingScore.toString(),
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(height: jarak2),
                                  Text("Riwayat Penyakit",
                                      style: Reuseable.titleStyle),
                                  SizedBox(height: jarak1),
                                  TextFormField(
                                      keyboardType: TextInputType.text,
                                      maxLines: 2,
                                      textInputAction: TextInputAction.next,
                                      style: new TextStyle(color: Colors.black),
                                      controller: _sickHistoryCtrl,
                                      //initialValue: widget.datum.writtingScore.toString(),
                                      readOnly: false,
                                      // validator: validasiUsername,
                                      onSaved: (em) {
                                        if (em != null) {}
                                      },
                                      decoration: Reuseable.inputDecoration),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      mainTitle("Keluarga"),
                                      IconButton(
                                          onPressed: () {
                                            // timer!.cancel();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileFamilyEdit(
                                                  user: widget.user,
                                                  familyId: 0,
                                                  profileInfo: widget.profile,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Image.asset(
                                              "images/Profile_Menu/add2.png"))
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  createListViewFamily(),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: SystemParam.colorCustom,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: Text("UPDATE"),
                                      onPressed: () {
                                        saveData();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
    );
  }

  // void initParameterGender() async {
  //   loading = true;
  //   ParameterModel parameterModel;
  //   var data = {
  //     "parameter_type": SystemParam.paramTypeGender,
  //     "company_id": widget.user.userCompanyId
  //   };

  //   var response = await RestService()
  //       .restRequestService(SystemParam.fParameterByType, data);

  //   setState(() {
  //     parameterModel = parameterModelFromJson(response.body.toString());
  //     genderList = parameterModel.data;
  //     itemsGender.add(DropdownItem.getItemParameter(
  //         SystemParam.defaultValueOptionId,
  //         SystemParam.defaultValueOptionDesc));
  //     for (var i = 0; i < genderList.length; i++) {
  //       itemsGender.add(DropdownItem.getItemParameter(
  //           genderList[i].id, genderList[i].parameterValue));
  //     }

  //     //loading = false;
  //   });
  // }

  void saveData() async {
    //urlWorkplanInboxUpdate
//var userId = 1;

    var data = {
      "user_id": widget.user.id,
      "company_id": widget.user.userCompanyId,
      "id": widget.profile.id,
      "first_name": _nama.text,
      "middle_name": _nama2.text,
      "last_name": _nama3.text,
      "gender": genderValue == 0 ? null : genderValue,
      "religion": religionValue == 0 ? null : religionValue,
      "nationality": nationalityValue == 0 ? null : nationalityValue,
      "tax_number": _taxnumber.text,
      "tax_address": _taxaddress.text,
      "identity_card_number": _identityCardNumber.text,
      "identity_card_address": _identityCardAddress.text,
      "blood_group": bloodGroupValue == 0 ? null : bloodGroupValue,
      "status": maritalStatusValue == 0 ? null : maritalStatusValue,
      "date_of_birthday": _dateOfBirthValue == "" ? null : _dateOfBirthValue,
      "place_of_birthday": _placebirthday.text,
      "is_use_glasses": _radioIsUseGlasses,
      "weight": _weightCtrl.text == "" ? null : _weightCtrl.text,
      "height": _heightCtrl.text == "" ? null : _heightCtrl.text,
      "sick_history": _sickHistoryCtrl.text
    };

    print(data);

    var response = await RestService()
        .restRequestService(SystemParam.fPersonalInfoUpdate, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    print('Ini response setelah tekan tombol update <<<<<<<<<<<<============');
    print(convertDataToJson);

    if (code == "0") {
      // timer!.cancel();
      Warning.showWarning("Update Data Berhasil");
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LandingPage(
              user: widget.user,
              currentIndex: 1,
            ),
          ));

      // Fluttertoast.showToast(
      //     msg: "",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: SystemParam.colorCustom,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
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

  void initParameterGender() async {
    itemsGender.clear();
    genderList = <Parameter>[];
    //loading = true;
    ParameterModel parameterModel;
    var data = {
      "parameter_type": SystemParam.parameterTypeGender,
      "company_id": widget.user.userCompanyId
    };

    var response = await RestService()
        .restRequestService(SystemParam.fParameterByTypeCompanyId, data);

    setState(() {
      parameterModel = parameterModelFromJson(response.body.toString());
      genderList = parameterModel.data;
      print('ini list gender <<<<<<=======');
      print(genderList);
      itemsGender.add(DropdownItem.getItemParameter(
          SystemParam.defaultValueOptionId,
          SystemParam.defaultValueOptionDesc));
      for (var i = 0; i < genderList.length; i++) {
        itemsGender.add(DropdownItem.getItemParameter(
            genderList[i].id, genderList[i].parameterValue));
      }

      //loading = false;
    });
  }

  void initParameterMaritalStatus() async {
    maritalStatusList = <Parameter>[];
    itemsMaritalStatus.clear();
    // loading = true;
    ParameterModel parameterModel;
    var data = {
      "parameter_type": SystemParam.parameterTypeMaritalStatus,
      "company_id": widget.user.userCompanyId
    };

    var response = await RestService()
        .restRequestService(SystemParam.fParameterByTypeCompanyId, data);

    setState(() {
      parameterModel = parameterModelFromJson(response.body.toString());
      maritalStatusList = parameterModel.data;
      itemsMaritalStatus.add(DropdownItem.getItemParameter(
          SystemParam.defaultValueOptionId,
          SystemParam.defaultValueOptionDesc));
      for (var i = 0; i < maritalStatusList.length; i++) {
        itemsMaritalStatus.add(DropdownItem.getItemParameter(
            maritalStatusList[i].id, maritalStatusList[i].parameterValue));
      }

      //loading = false;
    });
  }

  void initParameterReligion() async {
    itemsReligion.clear();
    religionList = <Parameter>[];
    //loading = true;
    ParameterModel parameterModel;
    var data = {
      "parameter_type": SystemParam.parameterTypeReligion,
      "company_id": widget.user.userCompanyId
    };
    print('DATA PARAMETER RELIGION <<<<<<<<<<<<<================');
    print(data);

    var response = await RestService()
        .restRequestService(SystemParam.fParameterByTypeCompanyId, data);
    var dataReligion = json.decode(response.body);
    print("INI DATA RELIGION");
    print(dataReligion['data']);

    setState(() {
      parameterModel = parameterModelFromJson(response.body.toString());
      religionList = parameterModel.data;
      print('ini list RELIGION <<<<<<=======');
      print(religionList);
      itemsReligion.add(DropdownItem.getItemParameter(
          SystemParam.defaultValueOptionId,
          SystemParam.defaultValueOptionDesc));
      for (var i = 0; i < religionList.length; i++) {
        itemsReligion.add(DropdownItem.getItemParameter(
            religionList[i].id, religionList[i].parameterValue));
      }

      //loading = false;
    });
  }

  void initParameterNationality() async {
    itemsNationality.clear();
    nationalityList = <Parameter>[];
    //loading = true;
    ParameterModel parameterModel;
    var data = {
      "parameter_type": SystemParam.parameterTypeNationality,
      "company_id": widget.user.userCompanyId
    };

    var response = await RestService()
        .restRequestService(SystemParam.fParameterByTypeCompanyId, data);

    setState(() {
      parameterModel = parameterModelFromJson(response.body.toString());
      nationalityList = parameterModel.data;
      itemsNationality.add(DropdownItem.getItemParameter(
          SystemParam.defaultValueOptionId,
          SystemParam.defaultValueOptionDesc));
      for (var i = 0; i < nationalityList.length; i++) {
        itemsNationality.add(DropdownItem.getItemParameter(
            nationalityList[i].id, nationalityList[i].parameterValue));
      }

      //loading = false;
    });
  }

  void initPersonalData() {
    print(
        'MASUK KE INIT PERSONAL DATA <<<<<<<<<<<<<<<<<<<<<<====================================================');
    print('ini gender value nya <<<====');
    print(widget.profile.gender);
    print(widget.profile.religion);
    genderValue = widget.profile.gender;
    maritalStatusValue = widget.profile.status;
    // ignore: unnecessary_null_comparison
    if (widget.profile.dateOfBirthday != null) {
      _dateOfBirthValue =
          SystemParam.formatDateValue.format(widget.profile.dateOfBirthday);
      // dateOfBirthday = widget.personalInfoProfilData.dateOfBirthday;
      // _birthDateCtrl.text = _dateOfBirthValue;

    }
    //dateOfBirthday = widget.personalInfoProfilData.dateOfBirthday;

    _placebirthday.text = widget.profile.placeOfBirthday;
    // ignore: unnecessary_null_comparison
    if (widget.profile.isUseGlasses != null ||
        widget.profile.isUseGlasses != "") {
      _radioIsUseGlasses = widget.profile.isUseGlasses;
    }

    _nama.text = widget.profile.firstName;
    _nama2.text = widget.profile.middleName;
    _nama3.text = widget.profile.lastName;
    _taxnumber.text = widget.profile.taxNumber;
    _taxaddress.text = widget.profile.taxAddress;
    _identityCardNumber.text = widget.profile.identityCardNumber;
    _identityCardAddress.text = widget.profile.identityCardAddress;
    _sickHistoryCtrl.text = widget.profile.sickHistory;
    // ignore: unnecessary_null_comparison
    if (widget.profile.weight != null) {
      _weightCtrl.text = widget.profile.weight.toString();
    }

    // ignore: unnecessary_null_comparison
    if (widget.profile.height != null) {
      _heightCtrl.text = widget.profile.height.toString();
    }

    bloodGroupValue = widget.profile.bloodGroup;
    nationalityValue = widget.profile.nationality;
    religionValue = widget.profile.religion;
  }

  void getFamilyList() async {
    loading = true;
    var data = {
      "user_id": widget.user.id,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonalFamilyByUserId, data);

    setState(() {
      PersonalFamilyModel model =
          personalFamilyModelFromJson(response.body.toString());
      familyCount = model.data.length;
      familyList = model.data;

      loading = false;
    });
  }

  ListView createListViewFamily() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: familyCount,
      itemBuilder: (BuildContext context, int index) {
        return customListItemFamily(
          familyList[index],
        );
      },
    );
  }

  customListItemFamily(FamilyData we) {
    return Card(
      color: SystemParam.colorbackgroud,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Divider(
                color: SystemParam.colorDivider,
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    // ignore: unnecessary_null_comparison
                    we.familyName == null ? "" : we.familyName,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  ),
                  //Icon(Icons.edit),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            // timer!.cancel();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileFamilyEdit(
                                          user: widget.user,
                                          familyId: we.id,
                                          profileInfo: widget.profile,
                                        )));
                          },
                          child: Icon(Icons.edit_rounded)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                            onTap: () {
                              showDeleteDialog(context, we.id);
                            },
                            child: Icon(Icons.delete_forever)),
                      )
                    ],
                  )
                ],
              ),
              Text(
                // ignore: unnecessary_null_comparison
                we.familyRelationship == null ? "" : we.familyRelationship,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                we.dateOfBirth == null
                    ? ""
                    : SystemParam.formatDateDisplay.format(we.dateOfBirth),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ]),
      ),
    );
  }

  showDeleteDialog(BuildContext context, int familyId) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("Cancel"),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        primary: Colors.green,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Continue"),
      // style: Elevate,
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          primary: Colors.red),
      onPressed: () {
        updateStatusFamily(familyId);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Konfirmasi Hapus"),
      content: Text("Anda yakin menghapus data ini ?"),
      actions: [
        cancelButton,
        continueButton,
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

  void updateStatusFamily(familyId) async {
    var data = {
      "id": familyId,
      "updated_by": widget.user.id,
      "status": 0,
    };

    // print(data);

    String function = SystemParam.fPersonalFamilyUpdateStatus;
    var response = await RestService().restRequestService(function, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    // print(status);

    if (code == "0") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePersonal(
                    user: widget.user,
                    profile: widget.profile, /*timer: widget.timer*/
                  )));
    } else {
      Fluttertoast.showToast(
          msg: status,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

mainTitle(String title) {
  return Center(
    child: Text(title,
        style: TextStyle(
            fontFamily: 'Calibre',
            color: SystemParam.colorCustom,
            fontWeight: FontWeight.bold,
            fontSize: 18)),
  );
}
