import 'dart:async';
import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/model/personal_certificate_model.dart';
import 'package:workplan_beta_test/model/personal_info_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/profile/skill/profile_skill.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

class ProfileSkillCertificateEdit extends StatefulWidget {
  final User user;
  final PersonalInfoProfilData profileInfo;
  final int certificateId;

  
  const ProfileSkillCertificateEdit(
      {Key? key,
      required this.user,
      required this.profileInfo,
      required this.certificateId})
      : super(key: key);

  @override
  _ProfileSkillCertificateEditState createState() =>
      _ProfileSkillCertificateEditState();
}

class _ProfileSkillCertificateEditState extends State<ProfileSkillCertificateEdit> {
  bool loading = false;
  final _keyForm = GlobalKey<FormState>();
  final requiredValidator =
      RequiredValidator(errorText: 'this field is required');
  TextEditingController _institutionNameCtrl = new TextEditingController();
  TextEditingController _certificateNameCtrl = new TextEditingController();
  String _certivicateDateValueStr = "";
  dynamic _certivicateDateValue;
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
    if (widget.certificateId != 0) {
      getCertificateList();
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
                  builder: (context) => ProfileSkill(
                    user: widget.user,
                    profileInfo: widget.profileInfo, /*timer: timer!,*/
                  ),
                ));
            return false;
          },
          child: Scaffold(
              //drawer: NavigationDrawerWidget(),
              appBar: AppBar(
                title: Text('Sertifikat Add/ Edit'),
                centerTitle: true,
                backgroundColor: SystemParam.colorCustom,
                automaticallyImplyLeading: false
                // leading: IconButton(
                //   icon: Icon(Icons.arrow_back, color: Colors.black),
                //   //onPressed: () => Navigator.of(context).pop(),
                //   onPressed: () {
                //     // Navigator.push(
                //     //     context,
                //     //     MaterialPageRoute(
                //     //       builder: (context) => ProfileSkill(
                //     //         user: widget.user,
                //     //         profileInfo: widget.profileInfo,
                //     //       ),
                //     //     ));
                //   },
                // ),
              ),
              body: loading == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Form(
                      key: _keyForm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Nama Institusi',
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
                          controller: _institutionNameCtrl,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),   
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Nama Training',
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
                          controller: _certificateNameCtrl,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Tanggal Sertifikat',
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
                        widget.certificateId==0?
                         DateTimeField(
                          //initialValue: _mulaiValue ?? DateTime.now(),
                          validator: (value) {
                            if (value == null) {
                              return "this field is required";
                            }
                            return null;
                          },
                          onSaved: (valueDate) {
                            _certivicateDateValueStr= SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          onChanged: (valueDate) {
                            _certivicateDateValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          format: SystemParam.formatDateDisplay,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                locale: Locale('id'),
                                firstDate: DateTime(SystemParam.firstDate),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(SystemParam.lastDate),
                                fieldHintText: SystemParam.strFormatDateHint);
                          },
                          decoration: Reuseable.inputDecorationDate
                        )
                        : DateTimeField(
                          initialValue: _certivicateDateValue ?? DateTime.now(),
                          validator: (value) {
                            if (value == null) {
                              return "this field is required";
                            }
                            return null;
                          },
                          onSaved: (valueDate) {
                            _certivicateDateValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          onChanged: (valueDate) {
                            _certivicateDateValueStr = SystemParam.formatDateValue
                                .format(valueDate!);
                          },
                          format: SystemParam.formatDateDisplay,
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                context: context,
                                locale: Locale('id'),
                                firstDate: DateTime(SystemParam.firstDate),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(SystemParam.lastDate),
                                fieldHintText: SystemParam.strFormatDateHint);
                          },
                          decoration: Reuseable.inputDecorationDate
                        ),
                        Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
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
                      ),),),),
    );
  }

  void getCertificateList() async{
    //fPersonalWorkExperienceById
    loading = true;
    var data = {
      "id": widget.certificateId,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonalCertificateById, data);

    setState(() {
      // print("response.body.toString():" + response.body.toString());
      PersonalCertificateModel model =
          personalCertificateModelFromJson(response.body.toString());

      if (model.data.length > 0) {
        PersonalCertificate certificate = model.data[0];
        _institutionNameCtrl.text = certificate.institutionName;
         // ignore: unnecessary_null_comparison
         if(certificate.certificateName!=null){
          _certificateNameCtrl.text = certificate.certificateName;
        }

        if (certificate.certificateDate != null) {
          _certivicateDateValue = certificate.certificateDate;
          _certivicateDateValueStr =
              SystemParam.formatDateValue.format(certificate.certificateDate);
        }

      
      }

      loading = false;
    });
  }

  void saveData()  async {
    
    var data = {
      "id": widget.certificateId,
      "created_by": widget.user.id,
      "user_id": widget.user.id,
      "company_id": widget.user.userCompanyId,
      "institution_name":_institutionNameCtrl.text,
      "certificate_name":_certificateNameCtrl.text,
      "certificate_date":_certivicateDateValueStr,
    };

    print(data);

    String function = SystemParam.fPersonalCertificateCreate;
    if(widget.certificateId!=0){
      function = SystemParam.fPersonalCertificateUpdate;
    }

    var response = await RestService() .restRequestService(function, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    print(status);

    if (code == "0") {
      timer!.cancel();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileSkill(
                    user: widget.user,
                    profileInfo: widget.profileInfo, /*timer: timer!,*/
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
