import 'dart:async';
import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/model/personal_family_model.dart';
import 'package:workplan_beta_test/model/personal_info_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/profile/info/profile_personal.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

class ProfileFamilyEdit extends StatefulWidget {
  final User user;
  final PersonalInfoProfilData profileInfo;
  final int familyId;

  const ProfileFamilyEdit(
      {Key? key,
      required this.user,
      required this.profileInfo,
      required this.familyId})
      : super(key: key);

  @override
  _ProfileFamilyEditState createState() => _ProfileFamilyEditState();
}

class _ProfileFamilyEditState extends State<ProfileFamilyEdit> {
  bool loading = false;
  final _keyForm = GlobalKey<FormState>();
  final requiredValidator =
      RequiredValidator(errorText: 'this field is required');
  TextEditingController _familyNameCtrl = new TextEditingController();
  TextEditingController _relationCtrl = new TextEditingController();
  String _dateOfBirthValueStr = "";
  dynamic _dateOfBirthValue;
  Timer? timer;
  int count = 0;

  // late PersonalCertificate  certificate;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      int? limit = widget.user.timeoutLogin * 60;
      print('ini limit time logout nhya');
      print(limit);
      if (count < limit) {
        print(count);
        setState(() {
          count++;
        });
      } else {
        timer.cancel();
        Helper.updateIsLogin(widget.user, 0);
        Navigator.of(context).pushNamedAndRemoveUntil(
            loginScreen, (Route<dynamic> route) => false);
      }
    });

    if (widget.familyId != 0) {
      getFamily();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        count = 0;
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePersonal(
                        user: widget.user,
                        profile: widget.profileInfo,
                        /*timer: timer!,*/
                      )));
          return false;
        },
        child: Scaffold(
          //drawer: NavigationDrawerWidget(),
          appBar: AppBar(
            title: Text('Keluarga Add/ Edit'),
            centerTitle: true,
            backgroundColor: SystemParam.colorCustom,
            automaticallyImplyLeading: false,
            // leading: IconButton(
            //   icon: Icon(Icons.arrow_back, color: Colors.black),
            //   //onPressed: () => Navigator.of(context).pop(),
            //   onPressed: () {
            //     // Navigator.push(
            //     //     context,
            //     //     MaterialPageRoute(
            //     //         builder: (context) => ProfilePersonal(
            //     //               user: widget.user,
            //     //               profile: widget.profileInfo,
            //     //             )));
            //   },
            // ),
          ),
          body: loading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _keyForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Nama', style: Reuseable.titleStyle),
                            TextSpan(
                                text: ' * ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                      SizedBox(height: Reuseable.jarak1),
                      TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _familyNameCtrl,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration),
                      SizedBox(height: Reuseable.jarak2),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Hubungan keluarga',
                                style: Reuseable.titleStyle),
                            TextSpan(
                                text: ' * ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                      SizedBox(height: Reuseable.jarak1),
                      TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _relationCtrl,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration),
                      SizedBox(height: Reuseable.jarak2),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Tanggal Lahir',
                                style: Reuseable.titleStyle),
                            TextSpan(
                                text: ' * ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                      SizedBox(height: Reuseable.jarak1),
                      widget.familyId == 0
                          ? DateTimeField(
                              //initialValue: _mulaiValue ?? DateTime.now(),
                              validator: (value) {
                                if (value == null) {
                                  return "this field is required";
                                }
                                return null;
                              },
                              onSaved: (valueDate) {
                                _dateOfBirthValueStr = SystemParam
                                    .formatDateValue
                                    .format(valueDate!);
                              },
                              onChanged: (valueDate) {
                                _dateOfBirthValueStr = SystemParam
                                    .formatDateValue
                                    .format(valueDate!);
                              },
                              format: SystemParam.formatDateDisplay,
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                    context: context,
                                    firstDate:
                                        DateTime(SystemParam.firstDate),
                                    initialDate:
                                        currentValue ?? DateTime.now(),
                                    lastDate: DateTime(SystemParam.lastDate),
                                    fieldHintText:
                                        SystemParam.strFormatDateHint);
                              },
                              decoration: Reuseable.inputDecorationDate)
                          : DateTimeField(
                              initialValue:
                                  _dateOfBirthValue ?? DateTime.now(),
                              validator: (value) {
                                if (value == null) {
                                  return "this field is required";
                                }
                                return null;
                              },
                              onSaved: (valueDate) {
                                _dateOfBirthValueStr = SystemParam
                                    .formatDateValue
                                    .format(valueDate!);
                              },
                              onChanged: (valueDate) {
                                _dateOfBirthValueStr = SystemParam
                                    .formatDateValue
                                    .format(valueDate!);
                              },
                              format: SystemParam.formatDateDisplay,
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                    context: context,
                                    firstDate:
                                        DateTime(SystemParam.firstDate),
                                    initialDate:
                                        currentValue ?? DateTime.now(),
                                    lastDate: DateTime(SystemParam.lastDate),
                                    fieldHintText:
                                        SystemParam.strFormatDateHint);
                              },
                              decoration: Reuseable.inputDecorationDate
                            ),
                      Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),),
                              primary: SystemParam.colorCustom),
                          child: Text("SIMPAN"),
                          onPressed: () {
                            if (_keyForm.currentState!.validate()) {
                              saveData();
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  void getFamily() async {
    //fPersonalWorkExperienceById
    loading = true;
    var data = {
      "id": widget.familyId,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonalFamilyById, data);

    setState(() {
      // print("response.body.toString():" + response.body.toString());
      PersonalFamilyModel model =
          personalFamilyModelFromJson(response.body.toString());

      if (model.data.length > 0) {
        FamilyData certificate = model.data[0];
        _familyNameCtrl.text = certificate.familyName;
        // ignore: unnecessary_null_comparison
        if (certificate.familyRelationship != null) {
          _relationCtrl.text = certificate.familyRelationship;
        }

        if (certificate.dateOfBirth != null) {
          _dateOfBirthValue = certificate.dateOfBirth;
          _dateOfBirthValueStr =
              SystemParam.formatDateValue.format(certificate.dateOfBirth);
        }
      }

      loading = false;
    });
  }

  void saveData() async {
    var data = {
      "id": widget.familyId,
      "created_by": widget.user.id,
      "user_id": widget.user.id,
      "company_id": widget.user.userCompanyId,
      "family_name": _familyNameCtrl.text,
      "family_relationship": _relationCtrl.text,
      "date_of_birth": _dateOfBirthValueStr,
    };

    print(data);

    String function = SystemParam.fPersonalFamilyCreate;
    if (widget.familyId != 0) {
      function = SystemParam.fPersonalFamilyUpdate;
    }

    var response = await RestService().restRequestService(function, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    print(status);

    if (code == "0") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePersonal(
                    user: widget.user,
                    profile: widget.profileInfo,
                    // timer: timer!,
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
