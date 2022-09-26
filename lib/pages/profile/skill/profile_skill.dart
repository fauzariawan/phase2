import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/personal_certificate_model.dart';
import 'package:workplan_beta_test/model/personal_info_model.dart';
import 'package:workplan_beta_test/model/personal_language_model.dart';
import 'package:workplan_beta_test/model/personal_training_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/profile/profile_page.dart';
import 'package:workplan_beta_test/pages/profile/skill/profile_skill_certificate_edit.dart';
import 'package:workplan_beta_test/pages/profile/skill/profile_skill_language_edit.dart';
import 'package:workplan_beta_test/pages/profile/skill/profile_skill_training_edit.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

class ProfileSkill extends StatefulWidget {
  final User user;
  final PersonalInfoProfilData profileInfo;
  // final Timer timer;
  const ProfileSkill(
      {Key? key,
      required this.user,
      required this.profileInfo,
      // required this.timer
      })
      : super(key: key);

  @override
  _ProfileSkillState createState() => _ProfileSkillState();
}

class _ProfileSkillState extends State<ProfileSkill> {
  bool loading = false;
  int languageCount = 0;
  List<PersonalLanguage> languageList = <PersonalLanguage>[];
  int certificateCount = 0;
  List<PersonalCertificate> certificateList = <PersonalCertificate>[];

  int trainingCount = 0;
  List<PersonalTraining> trainingList = <PersonalTraining>[];
  Timer? timer;
  int count = 0;

  @override
  void initState() {
    super.initState();
    // widget.timer.cancel();
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

    getLanguageList();
    getCertificateList();
    getTrainingList();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        count = 0;
      },
      child: WillPopScope(
        onWillPop: () async {
          timer!.cancel();
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
            title: Text('Skill'),
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
            //     //       builder: (context) => ProfilePage(
            //     //         user: widget.user,
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
                        vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Reuseable.mainTitle("Bahasa"),
                            IconButton(
                                onPressed: () {
                                  timer!.cancel();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileSkillLanguageEdit(
                                        user: widget.user,
                                        languageId: 0,
                                        profileInfo: widget.profileInfo,
                                      ),
                                    ),
                                  );
                                },
                                icon:
                                    Image.asset("images/Profile_Menu/add2.png"))
                          ],
                        ),
                        createListViewLanguage(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Reuseable.mainTitle("Certificate"),
                            IconButton(
                                onPressed: () {
                                  timer!.cancel();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileSkillCertificateEdit(
                                        user: widget.user,
                                        certificateId: 0,
                                        profileInfo: widget.profileInfo,
                                      ),
                                    ),
                                  );
                                },
                                icon:
                                    Image.asset("images/Profile_Menu/add2.png"))
                          ],
                        ),
                        createListViewCertificate(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Reuseable.mainTitle("Training"),
                            IconButton(
                                onPressed: () {
                                  timer!.cancel();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileSkillTrainingEdit(
                                        user: widget.user,
                                        profileInfo: widget.profileInfo,
                                        trainingId: 0,
                                      ),
                                    ),
                                  );
                                },
                                icon:
                                    Image.asset("images/Profile_Menu/add2.png"))
                          ],
                        ),
                        createListViewTraining(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void getLanguageList() async {
    loading = true;
    var data = {
      "user_id": widget.user.id,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonalLanguageByUserId, data);

    setState(() {
      // print("response.body.toString():" + response.body.toString());
      PersonalLanguageModel model =
          personalLanguageModelFromJson(response.body.toString());
      languageCount = model.data.length;
      languageList = model.data;

      loading = false;
    });
  }

  void getCertificateList() async {
    loading = true;
    var data = {
      "user_id": widget.user.id,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonalCertificateByUserId, data);

    setState(() {
      PersonalCertificateModel model =
          personalCertificateModelFromJson(response.body.toString());
      certificateCount = model.data.length;
      certificateList = model.data;

      loading = false;
    });
  }

  ListView createListViewLanguage() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: languageCount,
      itemBuilder: (BuildContext context, int index) {
        return customListItemLanguage(
          languageList[index],
        );
      },
    );
  }

  customListItemLanguage(PersonalLanguage langugae) {
    return Card(
      color: SystemParam.colorbackgroud,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Divider(
            color: SystemParam.colorDivider,
            thickness: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                langugae.languageType,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        timer!.cancel();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileSkillLanguageEdit(
                                      user: widget.user,
                                      languageId: langugae.id,
                                      profileInfo: widget.profileInfo,
                                    )));
                      },
                      child: Icon(Icons.edit_rounded)),
                  GestureDetector(
                      onTap: () {
                        showDeleteDialog(context, langugae.id,
                            SystemParam.fPersonalLanguageUpdateStatus);
                      },
                      child: Icon(Icons.delete_forever))
                ],
              )
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // ignore: unnecessary_null_comparison
                langugae.readingScore == null
                    ? "Reading Score : "
                    : "Reading Score : " +
                        langugae.readingScore.toString() +
                        " %",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              // Icon(Icons.edit),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // ignore: unnecessary_null_comparison
                langugae.writtingScore == null
                    ? "Writting Score : "
                    : "Writting Score : " +
                        langugae.writtingScore.toString() +
                        " %",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              // Icon(Icons.edit),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // ignore: unnecessary_null_comparison
                langugae.speakingScore == null
                    ? "Speaking Score : "
                    : "Speaking Score : " +
                        langugae.speakingScore.toString() +
                        " %",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
              // Icon(Icons.edit),
            ],
          ),
        ]),
      ),
    );
  }

  ListView createListViewCertificate() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: certificateCount,
      itemBuilder: (BuildContext context, int index) {
        return customListItemCertificate(
          certificateList[index],
        );
      },
    );
  }

  customListItemCertificate(PersonalCertificate we) {
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
                  we.institutionName == null ? "" : we.institutionName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          timer!.cancel();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileSkillCertificateEdit(
                                        user: widget.user,
                                        certificateId: we.id,
                                        profileInfo: widget.profileInfo,
                                      )));
                        },
                        child: Icon(Icons.edit_rounded)),
                    GestureDetector(
                        onTap: () {
                          showDeleteDialog(context, we.id,
                              SystemParam.fPersonalCertificateUpdateStatus);
                        },
                        child: Icon(Icons.delete_forever))
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // ignore: unnecessary_null_comparison
                  we.certificateName == null ? "" : we.certificateName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                // Icon(Icons.edit),
              ],
            ),
            SizedBox(height: 5),
            Text(
              we.certificateDate == null
                  ? ""
                  : SystemParam.formatDateDisplay.format(we.certificateDate),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  void getTrainingList() async {
    loading = true;
    var data = {
      "user_id": widget.user.id,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonalTrainingByUserId, data);

    setState(() {
      // print("response.body.toString():" + response.body.toString());
      PersonalTrainingModel model =
          personalTrainingModelFromJson(response.body.toString());
      trainingCount = model.data.length;
      trainingList = model.data;

      loading = false;
    });
  }

  ListView createListViewTraining() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trainingCount,
      itemBuilder: (BuildContext context, int index) {
        return customListItemTrainingCount(
          trainingList[index],
        );
      },
    );
  }

  customListItemTrainingCount(PersonalTraining tl) {
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
                  tl.institutionName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          timer!.cancel();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileSkillTrainingEdit(
                                        user: widget.user,
                                        profileInfo: widget.profileInfo,
                                        trainingId: tl.id,
                                      )));
                        },
                        child: Icon(Icons.edit_rounded)),
                    GestureDetector(
                        onTap: () {
                          showDeleteDialog(context, tl.id,
                              SystemParam.fPersonalTrainingUpdateStatus);
                        },
                        child: Icon(Icons.delete_forever))
                  ],
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tl.trainingName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                // Icon(Icons.edit),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tl.trainingDateStart == null
                      ? ""
                      : SystemParam.formatDateDisplay
                          .format(tl.trainingDateStart),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Text(
                  tl.trainingDateEnd == null
                      ? ""
                      : SystemParam.formatDateDisplay
                          .format(tl.trainingDateEnd),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  showDeleteDialog(BuildContext context, int id, function) {
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
        updateStatus(id, function);
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

  void updateStatus(id, function) async {
    var data = {
      "id": id,
      "updated_by": widget.user.id,
      "status": 0,
    };

    // print(data);
    //String function = SystemParam.fPersonalEducationUpdateStatus;
    var response = await RestService().restRequestService(function, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    // print(status);

    if (code == "0") {
      timer!.cancel();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileSkill(
                    user: widget.user,
                    profileInfo: widget.profileInfo,
                    /*timer: timer!,*/
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
