// import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/utility_image.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/main_pages/session_timer.dart';
import 'package:workplan_beta_test/model/personal_info_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/loginscreen.dart';
import 'package:workplan_beta_test/pages/profile/contact/profile_contact.dart';
import 'package:workplan_beta_test/pages/profile/history/profile_history.dart';
import 'package:workplan_beta_test/pages/profile/profile_image_pick.dart';
import 'package:workplan_beta_test/pages/profile/profile_image_take_picture.dart';
import 'package:workplan_beta_test/pages/profile/info/profile_personal.dart';
import 'package:workplan_beta_test/pages/profile/setting/profile_setting.dart';
import 'package:workplan_beta_test/pages/profile/skill/profile_skill.dart';
import 'package:workplan_beta_test/main_pages/constans.dart';
import 'package:workplan_beta_test/routerName.dart';

String _s3Url = "";
// import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:typed_data';

class ProfilePage extends StatefulWidget {
  final User user;
  // final Timer timer;
  // final Timer timer;
  const ProfilePage({
    Key? key,
    required this.user,
    // required this.timer,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool loading = false;
  late PersonalInfoProfilData profileData;
  Image imageFromPreferences = new Image.asset("images/man.png");
  bool isImageExist = false;
  String fullname = "";
  var db = new DatabaseHelper();
  String _base64Photo = "";
  String _s3Url = "";
  String profileImageURl = "";

  @override
  void initState() {
    super.initState();
    // initS3Url();
    getMyPersonal();

    //loading = false;
  }

  getMyPersonal() async {
    await db.getEnvByName(SystemParam.EnvAWS).then((value) {
      setState(() {
        loading = true;
        _s3Url = value.value;
        print('ini _s3Url dari UAT <<<<<<========');
        print(_s3Url);
        loading = false;
      });
    });

    // loading = true;

    var data = {
      "user_id": widget.user.id,
      "company_id": widget.user.userCompanyId
    };
    

    var response =
        await RestService().restRequestService(SystemParam.fPersonalInfo, data);
    print('Ini data Personal Info <<<<<<<<<<<==========');
    print(response.body);
    setState(() {
      PersonalInfoModel personalInfoModel =
          personalInfoFromJson(response.body.toString());
      profileData = personalInfoModel.data[0];

      if (profileData.image != null && profileData.image != "") {
        print('ini url path image fram UAT <<<<<========');
        print(profileData.image);
        isImageExist = true;
        //loadImageFromPreferences(profileData.image);
        profileImageURl = _s3Url + "/" + profileData.image;
        print('ini url Full untuk menampilkan image <<<========');
        print(profileImageURl);
      }

      String firstName = "", middleName = "", lastName = "";
      if (profileData.firstName != null) {
        firstName = profileData.firstName;
      }

      if (profileData.middleName != null) {
        middleName = profileData.middleName;
      }

      if (profileData.lastName != null) {
        lastName = profileData.lastName;
      }

      fullname = firstName + " " + middleName + " " + lastName;

      // loadPhotoProfile();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Personal Information'),
          centerTitle: true,
          backgroundColor: SystemParam.colorCustom,
        ),
        body: loading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      isImageExist
                          ? Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 9),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green[200]),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 7),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green[300]),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 5),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green[400]),
                                        child: CachedNetworkImage(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          imageUrl: profileImageURl,
                                          imageBuilder: (context, image) =>
                                              CircleAvatar(
                                            radius: 100,
                                            backgroundImage: image,
                                          ),
                                          placeholder: (context, url) => Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 100,
                                                  vertical: 100),
                                              child:
                                                  CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Center(
                                                  child: Text(
                                                      "Cannot Read Image From URL")),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  widthFactor: 5,
                                  heightFactor: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      doPickImage(profileData);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white),
                                        child: Icon(Icons.edit)),
                                  ),
                                )
                              ],
                            )
                          : Stack(
                              children: [
                                new CircleAvatar(
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      AssetImage("images/person.png"),
                                  radius: 100.0,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  widthFactor: 5,
                                  heightFactor: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      doPickImage(profileData);
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white),
                                        child: Icon(Icons.edit)),
                                  ),
                                )
                              ],
                            ),
                      Text(
                        fullname,
                        style: TextStyle(
                            color: WorkplanPallete.green, fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      PersonalInformation('images/Profile_Menu/Personal.png',
                          'Personal', 'Data Personal'),
                      PersonalInformation('images/Profile_Menu/History.png',
                          'History', 'Data History'),
                      PersonalInformation('images/Profile_Menu/Skill.png',
                          'Skill', 'Data Skill'),
                      PersonalInformation('images/Profile_Menu/Contact.png',
                          'Contact', 'Data Contact'),
                      PersonalInformation('images/Profile_Menu/Setting.png',
                          'Setting', 'Setting'),
                      PersonalInformation('images/Profile_Menu/Logout.png',
                          'Logout', 'Keluar Aplikasi'),
                    ],
                  ),
                ),
              ),
      );

  void doCapture(PersonalInfoProfilData personalInfoProfilData) async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileImageTakePicture(
            camera: firstCamera,
            user: widget.user,
            personalInfoProfilData: personalInfoProfilData,
          ),
        ));
  }

  loadImageFromPreferences(String photo) {
    loading = true;
    Utility.getImageFromPreferences(photo.split('/').last).then((img) {
      //print("img check null" +img.toString());
      if (null == img) {
        //print("null image");
        setState(() {
          downloadImageToPreference(photo);
          print("image from api");
        });
        return;
      }
      setState(() {
        imageFromPreferences = Utility.imageFromBase64String(img);
        // loading = false;
      });
    });
  }

  downloadImageToPreference(String photo) async {
    var data = {
      "filename": photo,
    };

    print(data);
    var response = await RestService()
        .restRequestService(SystemParam.fImageDownload, data);

    //print("response" + response.toString());
    // ImageProvider imageRes = Image.memory(response.bodyBytes).image;

    setState(() {
      imageFromPreferences = Image.memory(response.bodyBytes);
    });
  }

  void doPickImage(PersonalInfoProfilData personalInfoProfilData) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickImagePage(
            profileData: personalInfoProfilData,
            user: widget.user, /*timer: widget.timer*/
          ),
        ));
  }

  // void loadPhotoProfile() async {
  //   db.getPersonalInfoPhoto(profileData.userId.toString()).then((value) {
  //     setState(() {
  //       print("value.hashCode:" + value.hashCode.toString());
  //       _base64Photo = value!.imagePath;
  //     });
  //   });
  // }

  // Future<void> updateIsLogin(User user, int isLogin) async {
  //   try {
  //     final result = await InternetAddress.lookup('example.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       var dataPassword = {
  //         "id": user.id,
  //         "updated_by": user.id,
  //         "is_login_mobile": isLogin,
  //       };

  //       var response = await RestService()
  //           .restRequestService(SystemParam.fUpdateIsLogin, dataPassword);

  //       var convertDataToJson = json.decode(response.body);
  //       var code = convertDataToJson['code'];
  //       print("code:::" + code);
  //     }
  //   } on SocketException catch (_) {}
  // }

  PersonalInformation(String icon, String title, String subTitle) {
    return Card(
      color: Colors.white,
      //elevation: 2.0,
      child: ListTile(
        leading: Image.asset(icon),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 16,
              color: SystemParam.colorCustom,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subTitle),
        onTap: () async {
          if (title == 'Personal')
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePersonal(
                          user: widget.user,
                          profile: profileData, /*timer: widget.timer*/
                        )));
          if (title == 'History')
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileHistory(
                          user: widget.user,
                          profileInfo: profileData, /*timer: widget.timer*/
                        )));
          if (title == 'Skill')
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileSkill(
                          user: widget.user,
                          profileInfo: profileData, /*timer: widget.timer*/
                        )));
          if (title == 'Contact')
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileContact(
                          user: widget.user,
                          profile: profileData, /*timer: widget.timer*/
                        )));
          if (title == 'Setting')
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileSetting(
                          user: widget.user, /*timer: widget.timer*/
                        )));
          if (title == 'Logout') {
            Helper.updateIsLogin(widget.user, 0);
            // widget.timer.cancel();
            Helper.updateIsLogin(widget.user, 0);
            Navigator.of(context).pushNamedAndRemoveUntil(
                loginScreen, (Route<dynamic> route) => false);
          }
        },
      ),
    );
  }
}
