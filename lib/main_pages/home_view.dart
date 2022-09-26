import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/utility_image.dart';
import 'package:workplan_beta_test/main_pages/attendance/adjust_attendance.dart';
import 'package:workplan_beta_test/main_pages/attendance/attendance.dart';
import 'package:workplan_beta_test/main_pages/declaration/declaration.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/choose_user_to_track_live_location.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/liveTracking.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/viewLiveTrackingLocation.dart';
import 'package:workplan_beta_test/main_pages/task_menu.dart';
import 'package:workplan_beta_test/model/device_location_model.dart';
import 'package:workplan_beta_test/model/env_model.dart';
import 'package:workplan_beta_test/model/menu_otorize_model.dart';
import 'package:workplan_beta_test/model/notice_model.dart';
import 'package:workplan_beta_test/model/parameter_activity_model.dart';
import 'package:workplan_beta_test/model/parameter_hasil_kunjungan.dart';
import 'package:workplan_beta_test/model/parameter_kategori_produk_model.dart';
import 'package:workplan_beta_test/model/parameter_mapping_aktifitas_model.dart';
import 'package:workplan_beta_test/model/parameter_model.dart';
import 'package:workplan_beta_test/model/parameter_produk_model.dart';
import 'package:workplan_beta_test/model/parameter_progres_status_model.dart';
import 'package:workplan_beta_test/model/parameter_tujuan_kunjungan.dart';
import 'package:workplan_beta_test/model/parameter_udf_model.dart';
import 'package:workplan_beta_test/model/parameter_udf_option_model.dart';
import 'package:workplan_beta_test/model/parameter_usaha_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_dokumen_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/model/workplan_messages.dart';
import 'package:workplan_beta_test/model/workplan_visit_model.dart';
import 'package:geocoding/geocoding.dart' as gc;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:location_permissions/location_permissions.dart' as lp;
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:workplan_beta_test/pages/marquee_page.dart';
import 'package:workplan_beta_test/widget/warning.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final User user;
  // final Timer timer;
  const HomePage({
    Key? key,
    required this.user,
    // required this.timer,
  }) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var db = new DatabaseHelper();
  final Location location = Location();
  LocationData? _location;
  List<Notice> _noticeListDashboard = [];
  List<Notice> _noticeListMarquee = [];
  List<Widget> messageSliders = [];
  String marqueeText = "";
  final CarouselController _controller = CarouselController();
  int currentIndex = 0;
  int _current = 0;
  bool? isHoliday;
  final screens = [HomePage];
  DateTime now = DateTime.now();
  bool cutoff = false;
  var jadwalKerjaSebelumnya;
  num? distanceBetweenPoints;
  dynamic dataAttendance;
  Timer? timerNotice;
  // Timer? timerLocation;
  bool initMenu = false;
  List<dynamic> subMenuTask = [];
  String? keterangan;
  String? keterangan2;
  List<dynamic> menu = [
    // {
    //   "title": "Task",
    //   "picture": "images/Menu/Ok.png",
    //   // "routing": listOperator,
    //   // "data": {"kode": "9", "nama": "Roaming", "routing": produkPromo}
    // },
    // {
    //   "title": "Attendance",
    //   "picture": "images/Menu/chat 1.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
    // {
    //   "title": "Declaration",
    //   "picture": "images/Menu/declaration.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
    // {
    //   "title": "Live Tracking",
    //   "picture": "images/Menu/liveTracking.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
    // {
    //   "title": "Adjust Attendance",
    //   "picture": "images/Menu/adjust attendance 2.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
    // {
    //   "title": "Meeting Room",
    //   "picture": "images/Menu/meetingRoomDisable.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
    // {
    //   "title": "Reimbursement",
    //   "picture": "images/Menu/Refund.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
    // {
    //   "title": "More",
    //   "picture": "images/Menu/miscellaneous 3.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
  ];

  Timer? _updateLocation;

  @override
  void initState() {
    getRoleId();
    updateDataLocation();
    getMenuOtorize();
    getEnv();
    userNotice();
    initMessageMarqueeAndDashboard();
    getParameterUdf();
    getParameterUdfOption();
    getParameterActivity();
    getParameterProgresStatus();
    getParameter();
    getParameterUsaha();
    getParameterKategoriProduk();
    getParameterProduk();
    getWorkplanMessages();
    getParameterTujuanKunjungan();
    getParameterHasilKunjungan();
    getParameterMappingActivity();
    getDataAttendance();

    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   Workmanager().registerOneOffTask(
    //     'taskOne',
    //     'updateLocation',
    //     initialDelay: Duration(seconds: 1),
    //   );
    // });

    /* TASK */
    // getWorkplanList();
    // getWorkplanVisitList();
    // getWorkplanDokumenList();
    //getDeviceLocation();

    timerNotice = Timer.periodic(Duration(seconds: 10), (Timer timer) async {
      bool hasInternetConnection = await Helper.internetCek();
      if (hasInternetConnection) {
        userNotice();
      } else {
        print('No Internet Connection');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Image.asset("images/Menu/Rectangle.png", width: screenWidth),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:
                            AssetImage('images/App_Splash/icon launcher.jpg'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.notifications),
                    color: SystemParam.colorBell,
                    onPressed: () {
                      print('sudah di hit');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 95,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: messageSliders.length == 0
                    ? Center(
                        child: Text("Tidak Ada Pesan"),
                      )
                    : Column(
                        children: [
                          CarouselSlider(
                            items: messageSliders,
                            carouselController: _controller,
                            options: CarouselOptions(
                                autoPlay: true,
                                enlargeCenterPage: true,
                                aspectRatio: 2.0,
                                viewportFraction: 0.9,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                }),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  _noticeListDashboard.asMap().entries.map(
                                (entry) {
                                  return GestureDetector(
                                    onTap: () =>
                                        _controller.animateToPage(entry.key),
                                    child: Container(
                                      width: 10.0,
                                      height: 10.0,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black)
                                              .withOpacity(_current == entry.key
                                                  ? 0.9
                                                  : 0.4)),
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                // Center(child: SingleChildScrollView(child: Text(_noticeListDashboard[1].noticeBody, textAlign: TextAlign.center,))),
              ),
              SizedBox(
                height: 10,
              ),
              // Text(distanceBetweenPoints.toString()),
              // Text(keterangan ?? ''),
              // Text(keterangan2 ?? ''),
              Stack(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      height: 40,
                      decoration: BoxDecoration(
                          color: SystemParam.colorContainerMarqueeText,
                          border: Border.all(
                              color:
                                  SystemParam.colorBorderContainerMarqueeText),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10))),
                      child: marqueeText == ""
                          ? TulisanBerjalan(
                              text: "Tidak Ada Pesan",
                            )
                          : TulisanBerjalan(text: marqueeText)),
                  Positioned(
                      height: 50,
                      right: -4,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            lingkaran(),
                            lingkaran(),
                            lingkaran(),
                            lingkaran()
                          ]))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              initMenu == true
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      // color: Colors.yellow,
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                      child: GridView.builder(
                        padding: EdgeInsets.all(0),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          // mainAxisExtent: 100,
                        ),
                        itemCount: menu.length,
                        itemBuilder: (BuildContext context, i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: ElevatedButton(
                              onPressed: () {
                                timerNotice!.cancel();
                                switch (menu[i]["title"]) {
                                  case 'Task':
                                    // widget.timer.cancel();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TaskMenu(
                                          user: widget.user,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 'Attendance':
                                    print(isHoliday);

                                    if (isHoliday!) {
                                      Warning.showWarning(
                                          "hari ini bukan merupakan periode shift anda sehingga anda tidak bisa melakukan clock in dan clock out");
                                    } else {
                                      // widget.timer.cancel();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Attendance(
                                              user: widget.user, role: menu[i]),
                                        ),
                                      );
                                    }
                                    break;
                                  case 'Declaration':
                                    // widget.timer.cancel();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Declaration(
                                            user: widget.user, role: menu[i]),
                                      ),
                                    );
                                    break;
                                  case 'Live Tracking':
                                    // widget.timer.cancel();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChooseUserToTrackLiveLocation(
                                          user: widget.user,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 'Adjust Attendance':
                                    // widget.timer.cancel();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AdjustAttendance(
                                            user: widget.user, role: menu[i]),
                                      ),
                                    );
                                    break;
                                  default:
                                    print('menuju halaman yang lain');
                                }
                                // if (menu[i]['title'] == 'Task') {
                                //   print('sudah di hit');
                                //   widget.timer.cancel();
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => TaskMenu(
                                //         user: widget.user,
                                //       ),
                                //     ),
                                //   );
                                // } else if (menu[i]['title'] == 'Attendance') {
                                //   print('sudah di hit');
                                //   widget.timer.cancel();
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => Attendance(
                                //         user: widget.user,
                                //       ),
                                //     ),
                                //   );
                                // } else {
                                //   print('menuju halaman yang lain');
                                // }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12), // <-- Radius
                                ),
                              ),
                              child: Column(
                                // mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    menu[i]['picture'],
                                    fit: BoxFit.fill,
                                    width: menu[i]['title'] == "Declaration" ||
                                            menu[i]['title'] ==
                                                "Booking Seat" ||
                                            menu[i]['title'] ==
                                                "Adjust Attendance"
                                        ? 25
                                        : 35,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    menu[i]['title'],
                                    style: TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        fontFamily: "Calibre"),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              Image.asset("images/Menu/Group.png")
            ],
          ),
        )
      ],
    );
  }

  void getDataAttendance() async {
    print("masuk ke get attendance <<<<<<<<<=======");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await RestService().requestServiceGet(SystemParam.attendance,
        "${widget.user.id}", "company_id=${widget.user.userCompanyId}");
    var responseJson = json.decode(response.body);
    dataAttendance = responseJson['data'];
    print('ini data attendance <<<<<<<<======');
    print(dataAttendance);
    var isJadwalKerjaSebelumnya = prefs.containsKey('jadwalKerjaSebelumnya');
    print('ini jadwal kerja sebelumnya : $isJadwalKerjaSebelumnya');
    print(prefs.getString('jadwalKerjaSebelumnya'));

    // validasi kondisi libur dan yang belum clockout
    // shiftnya lintas hari
    if (dataAttendance['shift']['type'] == 'Fixed Hour' ||
        dataAttendance['shift']['type'] == 'Flexible Hour') {
      if (dataAttendance['shift']['detail'] == null) {
        isHoliday = true;
        return;
      }
      if (dataAttendance['shift']['detail']['is_selected'] == true &&
          isJadwalKerjaSebelumnya == true) {
        setState(() {
          isHoliday = false;
        });
        return;
      }
      if (dataAttendance['shift']['detail']['is_selected'] == true &&
          isJadwalKerjaSebelumnya == false) {
        isHoliday = false;
        return;
      }
      if (dataAttendance['shift']['detail']['is_selected'] == false &&
          isJadwalKerjaSebelumnya == false) {
        setState(() {
          isHoliday = true;
        });
        // Warning.showWarning('Hari Ini tidak ada jadwal kerja');
        return;
      }
      if (dataAttendance['shift']['detail']['is_selected'] == false &&
          isJadwalKerjaSebelumnya == true) {
        jadwalKerjaSebelumnya =
            jsonDecode(prefs.getString('jadwalKerjaSebelumnya')!);
        // cek apakah jam cutoff nya masih berlaku atau tidak
        // kalau jam cutoff nya sudah lewat maka tidak bisa masuk attendance lagi
        // kalau jam cutoff nya belum lewat cek sudah melakukan clockout atau belum
        // kalau sudah melakukan clockout berarti tidak bisa masuk attendace
        // kalau belum melakukan clockout berarti bisa masuk attendace untuk melakukan clock out
        // Warning.showWarning(
        //     'cek dulu cutoff timenya, kalau belum clock out, dan cutoff timemnya masih berlaku bisa masuk tapi hanya untuk clock out');
        // return;
      }
    } else if (dataAttendance['shift']['type'] == 'Flexi Date') {
      if (dataAttendance['shift']['detail'] == null) {
        isHoliday = true;
      } else {
        isHoliday = false;
      }
    } else if (dataAttendance['shift']['type'] == 'Free Shift') {
      if (dataAttendance['shift']['detail'] == null) {
        isHoliday = true;
      } else {
        if (dataAttendance['shift']['detail']["is_selected"] == false) {
          isHoliday = true;
        } else {
          isHoliday = false;
        }
      }
    }

    // // jangan lupa tambahkan untuk validasi cutoff
    // if (data['data']['shift']['detail'] == false) {
    //   isHoliday = true;
    // }
  }

  getMenuOtorize() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "role_id": widget.user.roleId,
          "company_id": widget.user.userCompanyId
        };

        var response =
            await RestService().restRequestService(SystemParam.fMenu, data);

        // setState(() async {
        MenuOtorizeModel model =
            menuOtorizeModelFromJson(response.body.toString());
        List<MenuOtorize> wdList = model.data;
        await db.deleteMenuOtorize();
        for (var i = 0; i < wdList.length; i++) {
          await db.insertMenuOtorize(wdList[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getEnv() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "user_id": widget.user.id,
          "company_id": widget.user.userCompanyId
        };

        var response =
            await RestService().restRequestService(SystemParam.fGetEnvS3, data);

        // setState(() async {
        EnvModel model = envModelFromJson(response.body.toString());
        List<Env> wdList = model.data;
        await db.deleteEnv();
        for (var i = 0; i < wdList.length; i++) {
          await db.insertEnv(wdList[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  void userNotice() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');

        var data = {
          "user_id": widget.user.id,
          "company_id": widget.user.userCompanyId,
          "organization_id": widget.user.organizationId,
          "function_id": widget.user.functionId,
          "structure_id": widget.user.structureId,
        };

        var response =
            await RestService().restRequestService(SystemParam.fNotice, data);

        var convertDataToJson = json.decode(response.body);
        var code = convertDataToJson['code'];

        if (code == "0") {
          await db.deleteNotice();
          NoticeModel messageModel =
              noticeModelFromJson(response.body.toString());
          List<Notice> messageList = messageModel.data;
          for (var i = 0; i < messageList.length; i++) {
            await db.insertNotice(messageList[i]);
          }
        }
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  void getParameterUdf() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');

        var data = {"company_id": widget.user.userCompanyId};
        var response = await RestService()
            .restRequestService(SystemParam.fParameterUdfList, data);
        ParameterUdfModel parameterUdfModel =
            parameterUdfModelFromJson(response.body.toString());
        List<ParameterUdf> parameterUdfList = parameterUdfModel.data;

        await db.deleteParameterUdf();
        for (var i = 0; i < parameterUdfList.length; i++) {
          await db.insertParameterUdf(parameterUdfList[i]);
        }
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameterUdfOption() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');

        var data = {"company_id": widget.user.userCompanyId};
        var response = await RestService()
            .restRequestService(SystemParam.fParameterUdfOption, data);
        ParameterUdfOptionModel udfOptionModel =
            parameterUdfOptionModelFromJson(response.body.toString());
        List<ParameterUdfOption> parameterUdfList = udfOptionModel.data;

        await db.deleteParameterUdfOption();
        for (var i = 0; i < parameterUdfList.length; i++) {
          await db.insertParameterUdfOption(parameterUdfList[i]);
        }
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameterActivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');
        ParameterActivityModel parameterModel;
        var data = {"company_id": widget.user.userCompanyId};

        var response = await RestService()
            .restRequestService(SystemParam.fParameterActivity, data);

        parameterModel =
            parameterActivityModelFromJson(response.body.toString());
        List<ParameterActivity> parameterActivityList = parameterModel.data;

        await db.deleteParameterActivity();
        for (var i = 0; i < parameterActivityList.length; i++) {
          await db.insertParameterActivity(parameterActivityList[i]);
        }
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameterProgresStatus() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');
        ParameterProgresStatusModel parameterModel;
        var data = {"company_id": widget.user.userCompanyId};

        var response = await RestService()
            .restRequestService(SystemParam.fParameterProgresStatus, data);

        parameterModel =
            parameterProgresStatusModelFromJson(response.body.toString());
        List<ParameterProgresStatus> parameterList = parameterModel.data;

        await db.deleteParameterProgresStatus();
        for (var i = 0; i < parameterList.length; i++) {
          await db.insertParameterProgresStatus(parameterList[i]);
        }
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameter() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');

        var data = {"company_id": widget.user.userCompanyId};
        var response = await RestService()
            .restRequestService(SystemParam.fParameter, data);
        //print("parameter " + response.body.toString());
        ParameterModel parameterModel =
            parameterModelFromJson(response.body.toString());
        List<Parameter> parameterList = parameterModel.data;

        await db.deleteParameter();
        for (var i = 0; i < parameterList.length; i++) {
          await db.insertParameter(parameterList[i]);
        }
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameterUsaha() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');

        var data = {"company_id": widget.user.userCompanyId};
        var response = await RestService()
            .restRequestService(SystemParam.fParameterUsaha, data);

        //print("parameter usaha" + response.body.toString());
        ParameterUsahaModel parameterModel =
            parameterUsahaModelFromJson(response.body.toString());
        List<ParameterUsaha> parameterList = parameterModel.data;

        await db.deleteParameterUsaha();
        for (var i = 0; i < parameterList.length; i++) {
          await db.insertParameterUsaha(parameterList[i]);
        }
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameterKategoriProduk() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "company_id": widget.user.userCompanyId,
        };

        // print(data);

        var response = await RestService().restRequestService(
            SystemParam.fParameterKategoriProdukByCompanyId, data);

        // print("kategori produk"+response.body.toString());

        // setState(() async {
        ParameterKategoriProdukModel parameterModel =
            parameterKategoriProdukModelFromJson(response.body.toString());
        print('ini kategori produk <<<========');
        print(parameterModel.data);
        List<ParameterKategoriProduk> parameterKategoriProdukList =
            parameterModel.data;

        await db.deleteParameterKategoriProduk();
        for (var i = 0; i < parameterKategoriProdukList.length; i++) {
          // db.insertParameter
          await db
              .insertParameterKategoriProduk(parameterKategoriProdukList[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameterProduk() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "company_id": widget.user.userCompanyId,
        };

        var response = await RestService()
            .restRequestService(SystemParam.fParameterProdukByCompanyId, data);
        // print("produk:"+response.body.toString());
        // setState(() async {
        ParameterProdukModel parameterModel =
            parameterProdukModelFromJson(response.body.toString());
        List<ParameterProduk> parameterProdukList = parameterModel.data;

        await db.deleteParameterProduk();
        for (var i = 0; i < parameterProdukList.length; i++) {
          // db.insertParameter
          await db.insertParameterProduk(parameterProdukList[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  void getWorkplanMessages() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // var userId = widget.user.data.id;
        var data = {
          "user_id": widget.user.id
          // ,"progres_status_id": progresStatusId
        };

        var response = await RestService()
            .restRequestService(SystemParam.fWorkplanMessagesByUserId, data);

        // setState(() async {
        WorkplanMessagesModel wmM =
            workplanMessagesFromJson(response.body.toString());
        // List<WorkplanMessagesData> data = wmM.data;
        await db.deleteWorkplanMessages();
        for (var i = 0; i < wmM.data.length; i++) {
          await db.insertWorkplanMessages(wmM.data[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameterTujuanKunjungan() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "company_id": widget.user.userCompanyId,
        };

        var response = await RestService().restRequestService(
            SystemParam.fParameterTujuanKunjunganByCompanyId, data);

        // print("response.body.toString()"+response.body.toString());
        // setState(() async {
        ParameterTujuanKunjunganModel parameterModel =
            parameterTujuanKunjunganFromJson(response.body.toString());
        List<ParameterTujuanKunjungan> parameterList = parameterModel.data;
        db.deleteParameterTujuanKunjungan();
        for (var i = 0; i < parameterList.length; i++) {
          await db.insertParameterTujuanKunjungan(parameterList[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getParameterHasilKunjungan() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "company_id": widget.user.userCompanyId,
        };

        var response = await RestService().restRequestService(
            SystemParam.fParameterHasilKunjunganByCompanyId, data);

        // setState(() async {
        ParameterHasilKunjunganModel parameterModel =
            parameterHasilKunjunganFromJson(response.body.toString());
        List<ParameterHasilKunjungan> parameterList = parameterModel.data;
        db.deleteParameterHasilKunjungan();
        for (var i = 0; i < parameterList.length; i++) {
          await db.insertParameterHasilKunjungan(parameterList[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getDeviceLocation() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _getLocation().then((value) {
          // setState(() {
          gl.Position userLocation = value;
          //String currentAddress = "";
          String datetime =
              SystemParam.formatDateTimeValue.format(DateTime.now());

          getAddress(userLocation).then((addrss) {
            DeviceLocation dl = DeviceLocation(
                address: addrss,
                latitude: userLocation.latitude.toString(),
                longitude: userLocation.longitude.toString(),
                createdDate: datetime);
            db.deleteDeviceLocation();
            db.insertDeviceLocation(dl);
          });
          // });
        });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  Future<gl.Position> _getLocation() async {
    //loading = true;
    var currentLocation;
    lp.PermissionStatus permission = await _getLocationPermission();
    if (permission == lp.PermissionStatus.granted) {
      try {
        currentLocation = await gl.Geolocator.getCurrentPosition(
            desiredAccuracy: gl.LocationAccuracy.best);
      } catch (e) {
        currentLocation = null;
      }
    }
    return currentLocation;
  }

  Future<lp.PermissionStatus> _getLocationPermission() async {
    final lp.PermissionStatus permission = await lp.LocationPermissions()
        .checkPermissionStatus(level: lp.LocationPermissionLevel.location);

    if (permission != lp.PermissionStatus.granted) {
      final lp.PermissionStatus permissionStatus =
          await lp.LocationPermissions().requestPermissions(
              permissionLevel: lp.LocationPermissionLevel.location);

      return permissionStatus;
    } else {
      return permission;
    }
  }

  Future<String> getAddress(gl.Position userLocation) async {
    String address = "";
    List<gc.Placemark> placemark = await gc.placemarkFromCoordinates(
        userLocation.latitude, userLocation.longitude);

    // setState(() {
    try {
      // ignore: unnecessary_null_comparison
      if (placemark[0] != null) {
        String fulladdress = placemark[0].toString();

        // String name = placemark[0].street != null
        //     ? placemark[0].street.toString()
        //     : "";
        String subThoroughfare = placemark[0].subThoroughfare != null
            ? placemark[0].subThoroughfare.toString()
            : "";

        String thoroughfare = placemark[0].thoroughfare != null
            ? placemark[0].thoroughfare.toString()
            : "";
        String subLocality = placemark[0].subLocality != null
            ? placemark[0].subLocality.toString()
            : "";
        String locality = placemark[0].locality != null
            ? placemark[0].locality.toString()
            : "";
        String administrativeArea = placemark[0].administrativeArea != null
            ? placemark[0].administrativeArea.toString()
            : "";
        String postalCode = placemark[0].postalCode != null
            ? placemark[0].postalCode.toString()
            : "";
        String country =
            placemark[0].country != null ? placemark[0].country.toString() : "";

        address = thoroughfare +
            ", " +
            subThoroughfare +
            ", " +
            subLocality +
            ", " +
            locality +
            ", " +
            administrativeArea +
            ", " +
            postalCode +
            ", " +
            country;

        address = fulladdress;
        // _currentAddress = address;
        // _addressCtr.text = address;
      }
    } catch (e) {
      address = "";
    }
    // });
    return address;
  }

  Future<void> uploadImageVisit(WorkplanVisit visit) async {
    try {
      var uri =
          Uri.parse(SystemParam.baseUrl + SystemParam.fUploadImageCheckInOut);
      var request = new http.MultipartRequest("POST", uri);

      final tempDir = await getTemporaryDirectory();

      if (visit.baseImageCheckIn != null && visit.baseImageCheckIn != "") {
        String baseImageCheckIn = visit.baseImageCheckIn;
        Uint8List bytesCheckIn = base64.decode(baseImageCheckIn);
        Utility.getImageFromPreferences(visit.photoCheckIn.split('/').last)
            .then((img) {
          if (null == img) {
            return;
          }
          bytesCheckIn = base64.decode(img);
        });

        File fileCheckIn =
            await File('${tempDir.path}/' + visit.photoCheckIn.split('/').last)
                .create();
        fileCheckIn.writeAsBytesSync(bytesCheckIn);

        var streamCheckIn =
            new http.ByteStream(Stream.castFrom(fileCheckIn.openRead()));
        var lengthCheckIn = await fileCheckIn.length();

        var multipartFileCheckIn = new http.MultipartFile(
            'image_check_in', streamCheckIn, lengthCheckIn,
            filename: basename(fileCheckIn.path));

        request.fields['file_name_check_in'] = visit.photoCheckIn;
        request.files.add(multipartFileCheckIn);
      }

      if (visit.baseImageCheckOut != null && visit.baseImageCheckOut != "") {
        String baseImageCheckOut = visit.baseImageCheckOut;
        Uint8List bytesCheckOut = base64.decode(baseImageCheckOut);

        Utility.getImageFromPreferences(visit.photoCheckOut.split('/').last)
            .then((img) {
          if (null == img) {
            return;
          }
          //Image imageCheckIn = Utility.imageFromBase64String(img);
          bytesCheckOut = base64.decode(img);
        });

        File fileCheckOut =
            await File('${tempDir.path}/' + visit.photoCheckOut.split('/').last)
                .create();
        fileCheckOut.writeAsBytesSync(bytesCheckOut);

        var streamCheckOut =
            new http.ByteStream(Stream.castFrom(fileCheckOut.openRead()));
        var lengthCheckOut = await fileCheckOut.length();

        var multipartFileCheckOut = new http.MultipartFile(
            'image_check_out', streamCheckOut, lengthCheckOut,
            filename: basename(fileCheckOut.path));
        request.files.add(multipartFileCheckOut);
        request.fields['file_name_check_out'] = visit.photoCheckOut;
      }

      request.fields['updated_by'] = widget.user.id.toString();
      request.fields['visit_id'] = visit.id.toString();
      request.fields['company_id'] = widget.user.userCompanyId.toString();

      var response = await request.send();
      //print("response.statusCode:"+response.statusCode.toString());

      // listen for response
      response.stream.transform(utf8.decoder).listen((value) {
        // print(value);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  getParameterMappingActivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "company_id": widget.user.userCompanyId,
        };

        var response = await RestService()
            .restRequestService(SystemParam.fParameterMappingAktifitas, data);

        // setState(() async {
        ParameterMappingAktifitasModel parameterModel =
            parameterMappingAktifitasModelFromJson(response.body.toString());
        List<ParameterMappingAktifitas> parameterList = parameterModel.data;
        db.deleteParameterMappingActivity();
        for (var i = 0; i < parameterList.length; i++) {
          await db.insertParameterMappingActivity(parameterList[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getWorkplanDokumenList() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "user_id": widget.user.id,
        };

        var response = await RestService()
            .restRequestService(SystemParam.fWorkplanDokumenByUserId, data);

        // setState(() async {
        WorkplanDokumenModel model =
            workplanDokumenModelFromJson(response.body.toString());
        List<WorkplanDokumen> wdList = model.data;
        db.deleteWorkplanDokumen();
        for (var i = 0; i < wdList.length; i++) {
          await db.insertWorkplanDokumen(wdList[i]);
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getWorkplanList() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');

        //get to update Inbox
        await db.getWorkplanActivityUpdateInbox().then((value) async {
          //print("value"+value.length.toString());
          var jsonData = value;
          //print(jsonData);
          var data = {"worklan_inbox_list": jsonData};
          // print(data);
          // var respons =
          await RestService()
              .restRequestService(SystemParam.fWorkplanInboxUpdateList, data);
          //print("getWorkplanActivityInboxForUpdate :" + respons.body.toString());
        });

        await db.getWorkplanActivityUpdatePersonal().then((value) async {
          print(value.length);
          if (null != value && value.length > 0) {
            // var jsonData = value;
            //print(jsonData);
            var data = {"worklan_personal_list": value};
            // print(data);
            var respons = await RestService().restRequestService(
                SystemParam.fWorkplanPersonalUpdateList, data);
            print("fWorkplanPersonalUpdateList :" + respons.body.toString());
          }
        });

        await db.getWorkplanActivityUpdateProduk().then((value) async {
          //print("value"+value.length.toString());
          var jsonData = value;
          //print(jsonData);
          var data = {"worklan_produk_list": jsonData};
          // print(data);
          // var respons =
          await RestService()
              .restRequestService(SystemParam.fWorkplanProdukUpdateList, data);
          //print("getWorkplanActivityInboxForUpdate :" + respons.body.toString());
        });

        await db.getWorkplanActivityUpdateUdf().then((value) async {
          //print("value"+value.length.toString());
          var jsonData = value;
          //print(jsonData);
          var data = {"worklan_udf_list": jsonData};
          // print(data);
          // var respons =
          await RestService()
              .restRequestService(SystemParam.fWorkplanUdfUpdateList, data);
          //print("getWorkplanActivityInboxForUpdate :" + respons.body.toString());
        });

        var data = {"user_id": widget.user.id};
        var response = await RestService()
            .restRequestService(SystemParam.fWorkplanListAll, data);

        // setState(() {
        WorkplanInboxModel wi = workplanInboxFromJson(response.body.toString());
        // db.deleteWorkplanActivityInbox();
        await db.deleteWorkplanActivityAll();
        for (var i = 0; i < wi.data.length; i++) {
          await db.insertWorkplanActivity(wi.data[i].toMap());
        }
        // });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  getWorkplanVisitList() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //print('connected');

        List<WorkplanVisit> visitList = <WorkplanVisit>[];

        await db.getVisitListUpdate().then((value) async {
          visitList = value;
          var data = {"worklan_visit_list": value};
          await RestService()
              .restRequestService(SystemParam.fWorkplanVisitUpdateList, data);
        });

        for (var i = 0; i < visitList.length; i++) {
          uploadImageVisit(visitList[i]);
        }

        var data = {
          "user_id": widget.user.id,
        };

        var response = await RestService()
            .restRequestService(SystemParam.fWorkplanVisitListByUserId, data);

        WorkplanVisitModel workplanVisitModel =
            workplanVisitModelFromJson(response.body.toString());
        int count = workplanVisitModel.data.length;

        await db.deleteWorkplanVisit();
        for (var i = 0; i < count; i++) {
          await db.insertWorkplanVisit(workplanVisitModel.data[i]);
        }
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  void initMessageMarqueeAndDashboard() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "user_id": widget.user.id,
          "company_id": widget.user.userCompanyId,
          "organization_id": widget.user.organizationId,
          "function_id": widget.user.functionId,
          "structure_id": widget.user.structureId,
        };

        var response =
            await RestService().restRequestService(SystemParam.fNotice, data);

        var convertDataToJson = json.decode(response.body);
        print("ini pesan dashboard dan marquee");
        print(convertDataToJson);
        var code = convertDataToJson['code'];
        if (code == "0") {
          setState(() {
            NoticeModel messageModel =
                noticeModelFromJson(response.body.toString());
            List<Notice> noticeList = messageModel.data;
            _noticeListMarquee.clear();
            _noticeListDashboard.clear();
            marqueeText = "";
            for (var i = 0; i < noticeList.length; i++) {
              if (noticeList[i].mediaTypeCode == "PESAN_BERJALAN") {
                _noticeListMarquee.add(noticeList[i]);
                // ignore: unnecessary_null_comparison
                if (noticeList[i].noticeBody != null) {
                  marqueeText += noticeList[i].noticeBody + ".           ";
                }
              } else if (noticeList[i].mediaTypeCode == "DASHBOARD") {
                _noticeListDashboard.add(noticeList[i]);
              }
            }
            messageSliders = _noticeListDashboard
                .map(
                  (notice) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Text(notice.noticeBody,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "Poppins")),
                      ),
                    );
                  },
                )
                .cast<Widget>()
                .toList();
          });
        }
      }
      //loading = false;
    } on SocketException catch (_) {
      print("no internet access");
      //loading = true;
      // setState(() {
      //   db
      //       .getNoticeList(widget.user.userCompanyId.toString())
      //       .then((noticeList) {
      //     _noticeListMarquee.clear();
      //     _noticeListDashboard.clear();
      //     marqueeText = "";
      //     for (var i = 0; i < noticeList.length; i++) {
      //       if (noticeList[i].mediaTypeCode == "PESAN_BERJALAN") {
      //         _noticeListMarquee.add(noticeList[i]);
      //         marqueeText += noticeList[i].noticeBody + ".           ";
      //       } else if (noticeList[i].mediaTypeCode == "DASHBOARD") {
      //         _noticeListDashboard.add(noticeList[i]);
      //       }
      //     }
      //   });
      // });
      //
    }
  }

  lingkaran() {
    return Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
            border:
                Border.all(color: SystemParam.colorBorderContainerMarqueeText),
            color: Colors.white,
            shape: BoxShape.circle));
  }

  void getRoleMenu(int roleId) async {
    setState(() {
      initMenu = true;
    });

    Uri url = Uri.parse(
        "https://workplan-phase2-be.aplikasidev.com/api/menu?role_id=$roleId");
    try {
      var response = await http.get(url);
      var responseJson = jsonDecode(response.body);
      List<dynamic> data = responseJson['data'];
      data.removeWhere((item) => item['menu_order'] == null);
      // print("Data Type Of data = ${data.runtimeType}");
      // print(data[0]);
      // data.sort((a, b) => a["menu_order"].compareTo(b["menu_order"]));
      print(
          'SETELAH DIBUANG NULL NYA <<<<<<<<<<<<<<<<<<<<<<<==========================');
      print(data);
      data.sort((a, b) => a['menu_order'].compareTo(b['menu_order']));
      print(' SETELAH DI SORTING <<<<<<<<<<<<<<<<==============');
      print(data);
      for (var item in data) {
        var picture = null;
        if (item['menu_name'] == "Task") {
          picture = "images/Menu/Ok.png";
        } else if (item['menu_name'] == "Attendance") {
          picture = "images/Menu/chat 1.png";
        } else if (item['menu_name'] == "Declaration") {
          picture = "images/Menu/declaration.png";
        } else if (item['menu_name'] == "Live Tracking") {
          picture = "images/Menu/liveTracking.png";
        } else if (item['menu_name'] == "Adjust Attendance") {
          picture = "images/Menu/adjust attendance 2.png";
        } else if (item['menu_name'] == "Inbox Task") {
          picture = "images/Menu_Task/List_Task/Inbox_Task.png";
        } else if (item['menu_name'] == "List Task") {
          picture = "images/Menu_Task/List_Task/List_Task.png";
        } else if (item['menu_name'] == "GPS Tracking") {
          picture = "images/Menu_Task/List_Task/Gps_Tracking.png";
        }

        var data = {
          "title": item['menu_name'],
          "picture": picture,
          "isView": item['can_read'],
          "isAdd": item['can_write'],
          "isEdit": item['can_update'],
          "isApprove": item['can_approve']
        };
        if (data['title'] == 'Inbox Task' ||
            data['title'] == 'List Task' ||
            data['title'] == 'GPS Tracking') {
          if (data['isView'] == 0) {
          } else {
            subMenuTask.add(data);
            print(subMenuTask);
          }
        } else {
          if (data['isView'] == 0) {
          } else {
            menu.add(data);
            print(menu);
          }
        }
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isSubMenuTaskExist = prefs.containsKey('subMenuTask');
      var dataSubMenuTask = jsonEncode(subMenuTask);
      if (isSubMenuTaskExist) {
        prefs.remove('subMenuTask');
        prefs.setString('subMenuTask', dataSubMenuTask);
      } else {
        prefs.setString('subMenuTask', dataSubMenuTask);
      }
    } catch (e) {
      print('error konneksi http');
      print(e);
      Warning.showWarning('No Internet Connection');
    }
    setState(() {
      initMenu = false;
    });
    // print(widget.user.roleId);
    // var data = {
    //   "role_id": widget.user.roleId.toString(),
    // };
    // print(data);
    // var path = SystemParam.getRoleMenu;
    // var response = await RestService().restRequestServicePost(path, data);
    // print(response);
  }

  void getRoleId() async {
    var data = {
      "username": widget.user.username,
    };
    print('hit api <<<<<=========');
    var response = await RestService()
        .restRequestService(SystemParam.fLoginByUserIdOrEmail, data);
    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var roleId;

    if (code == "0") {
      print('berhasil hit api');
      await db.deleteUser();
      print('berhasil hapus data di db local');
      UserModel userModel = userFromJson(response.body.toString());
      List<User> userList = userModel.data;
      for (var i = 0; i < userList.length; i++) {
        if (userList[i].companyCode.toUpperCase() ==
            widget.user.companyCode.toUpperCase()) {
          roleId = userList[i].roleId;
          break;
        }
      }
      print(
          'INI ROLE ID DARI FUNGSI GET ROLE ID <<<<<<<<<<<<<================');
      print(roleId);
      getRoleMenu(roleId);
    }
  }

  void updateLocation(
      Map<String, String> body, LocationData newLocation) async {
    try {
      var respon = await http.post(
        Uri.parse(SystemParam.baseUrl + SystemParam.liveTracking),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          // "Content-Type": "application/json",
        },
        body: body,
      );
      var result = jsonDecode(respon.body);
      if (result['code'] == 0 && result['status'] == 'Success') {
        print('update lokasi berhasil');
        _location = newLocation;
      }
      print(respon.body);
      print(result['code']);
      print(result['status']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  void updateDataLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('updateLocation')) {
      return;
    } else {
      prefs.setString('updateLocation', '1');
      print('MASUK UPDATE DATA LOCATION <<<<=====');
      // CEK LOCATION SECARA BERKALA DAN MENGUPDATE DATA LOCATION YANG TERBARU SETIAP 100 METER
      _updateLocation =
          Timer.periodic(Duration(seconds: 5), (Timer timer) async {
        // Warning.showWarning("proses cek lokasi dan update");
        final LocationData _locationResult = await location.getLocation();
        String longitude = _locationResult.longitude.toString();
        String latitude = _locationResult.latitude.toString();
        var body = {
          "user_id": widget.user.id.toString(),
          "company_id": widget.user.userCompanyId.toString(),
          "longitude": longitude,
          "latitude": latitude
        };
        // Warning.showWarning(body.toString());

        if (_location == null) {
          // var uniqueId = DateTime.now().second.toString();
          // await Workmanager().registerOneOffTask(uniqueId, 'updateLocation',
          //     inputData: body,
          //     initialDelay: Duration(seconds: 1),
          //     constraints: Constraints(networkType: NetworkType.connected));
          updateLocation(body, _locationResult);
          print(body);
        } else {
          String latString = _location!.latitude.toString();
          String longString = _location!.longitude.toString();
          String latStringNew = _locationResult.latitude.toString();
          String longStringNew = _locationResult.longitude.toString();

          double latitude = double.parse(latString);
          double longitude = double.parse(longString);
          double latitudeNew = double.parse(latStringNew);
          double longitudeNew = double.parse(longStringNew);
          LatLng location = LatLng(latitude, longitude);
          LatLng newLocation = LatLng(latitudeNew, longitudeNew);

          setState(() {
            distanceBetweenPoints =
                SphericalUtil.computeDistanceBetween(location, newLocation);
          });
          print('data location sudah ada <<<<<<<<<<<<<<<================');
          print(
              'jarak antara location lama ke location yang baru <<<<<<<=========');
          if (distanceBetweenPoints! >= 5) {
            print(
                'jarak lebih besar sama dari 5 meter <<<<<<<<<<<<<<===============');
            setState(() {
              keterangan = 'jarak diatas 5 meter';
            });
            // Workmanager().registerOneOffTask(
            //   'taskOne',
            //   'updateLocation',
            //   inputData: body,
            //   initialDelay: Duration(seconds: 1),
            // );
            // _location = _locationResult;
            // Timer.periodic(Duration(seconds: 1), (timer) {
            //   Workmanager().registerOneOffTask(
            //     'taskOne',
            //     'updateLocation',
            //     inputData: body,
            //     initialDelay: Duration(seconds: 1),
            //   );
            // });
            updateLocation(body, _locationResult);
            // Warning.showWarning('jarak > 5m, lokasi sudah di update');
          }
          // else {
          //   Warning.showWarning('jarak kurang dari 5 meter');
          //   print('jarak di bawah 5 meter <<<===');
          //   keterangan = 'jarak di bawah 5 meter';
          //   keterangan2 = 'tidak ada update lokasi';
          // }
          print(distanceBetweenPoints);
        }
      });
    }
  }
}

class TulisanBerjalan extends StatelessWidget {
  final String text;
  const TulisanBerjalan({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MarqueeWidget(
          direction: Axis.horizontal,
          child: Text(
            text,
            style: TextStyle(
                color: SystemParam.colorCustom,
                fontSize: 14,
                fontFamily: "Poppins"),
          )),
    );
  }
}

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:marquee/marquee.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:workplan_beta_test/base/system_param.dart';
// import 'package:workplan_beta_test/helper/database.dart';
// import 'package:workplan_beta_test/helper/rest_service.dart';
// import 'package:workplan_beta_test/main_pages/constans.dart';
// import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
// import 'package:workplan_beta_test/main_pages/session_timer.dart';
// import 'package:workplan_beta_test/main_pages/task_menu.dart';
// import 'package:workplan_beta_test/main_pages/workplan_appbar.dart';
// import 'package:workplan_beta_test/model/home_model.dart';
// import 'package:workplan_beta_test/model/notice_model.dart';
// import 'package:workplan_beta_test/model/user_model.dart';
// import 'package:workplan_beta_test/pages/marquee_page.dart';
// import 'package:workplan_beta_test/pages/workplan/workplan_inbox.dart';

// import 'basic_page.dart';

// // class BerandaPage extends StatefulWidget {
// //   final User user;
// //   const BerandaPage({Key? key, required this.user}) : super(key: key);
// //   @override
// //   _BerandaPageState createState() => new _BerandaPageState();
// // }

// class BerandaPage extends BasePage {
//   final User user;
//   final SessionTimer sessionTimer;
//   //const BerandaPage({Key? key, required this.user}) : super(key: key);
//   BerandaPage({required this.user, required this.sessionTimer}) : super(user);
//   @override
//   _BerandaPageState createState() => new _BerandaPageState();
// }

// class ReceivedNotification {
//   ReceivedNotification({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.payload,
//   });

//   final int id;
//   final String? title;
//   final String? body;
//   final String? payload;
// }

// // class _BerandaPageState extends State<BerandaPage> {
// class _BerandaPageState extends BaseState<BerandaPage> with BasicPage {
//   List<WorkplanMenu> _workplanServiceList = [];
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       new FlutterLocalNotificationsPlugin();
//   BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
//       BehaviorSubject<ReceivedNotification>();

//   BehaviorSubject<String?> selectNotificationSubject =
//       BehaviorSubject<String?>();

//   // int _noticeCount = 0, _noticeCountMarquee = 0;
//   List<Notice> _noticeListDashboard = [];
//   List<Notice> _noticeListMarquee = [];
//   bool loading = false;
//   // bool _useRtlText = false;
//   String marqueeText = "";
//   var db = new DatabaseHelper();
//   int newMessage = 0;
//   late Timer timer;
//   int counter = 0;
//   int itemCountMenu = 0;
//   // SessionTimer sessionTimer = new SessionTimer();

//   Future onSelectNotification(String? payload) async {
//     showDialog(
//       context: context,
//       builder: (_) {
//         return new AlertDialog(
//           title: Text("PayLoad"),
//           content: Text("Payload : $payload"),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     didReceiveLocalNotificationSubject.close();
//     selectNotificationSubject.close();
//     timer.cancel();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();

//     setState(() {
//       //loading = true;
//       // SessionTimer().startTimer(widget.user.timeoutLogin);
//       initNotice();
//       initNoticePersonalCount();

//       timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
//         initNoticePersonalCount();
//       });

//       _requestPermissions();
//       _configureDidReceiveLocalNotificationSubject();
//       _configureSelectNotificationSubject();

//       // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//       // If you have skipped STEP 3 then change app_icon to @mipmap/ic_launcher
//       var initializationSettingsAndroid =
//           new AndroidInitializationSettings('app_icon');
//       var initializationSettingsIOS = new IOSInitializationSettings();
//       var initializationSettings = new InitializationSettings(
//           android: initializationSettingsAndroid,
//           iOS: initializationSettingsIOS);
//       flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//       flutterLocalNotificationsPlugin.initialize(initializationSettings,
//           onSelectNotification: onSelectNotification);

//       // initNoticeApi();

//       //  IconData comingSoonIcon = ImageIcon(AssetImage("images/coming_soon.png")) as IconData;
//       //Image.asset('images/coming_soon.png');

//       initMenu();
//       //loading = false;
//     });
//   }

//   void _requestPermissions() {
//     flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//     flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             MacOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//   }


//   void _configureDidReceiveLocalNotificationSubject() {
//     didReceiveLocalNotificationSubject.stream
//         .listen((ReceivedNotification receivedNotification) async {
//       await showDialog(
//         context: context,
//         builder: (BuildContext context) => CupertinoAlertDialog(
//           title: receivedNotification.title != null
//               ? Text(receivedNotification.title!)
//               : null,
//           content: receivedNotification.body != null
//               ? Text(receivedNotification.body!)
//               : null,
//           actions: <Widget>[
//             CupertinoDialogAction(
//               isDefaultAction: true,
//               onPressed: () async {
//                 Navigator.of(context, rootNavigator: true).pop();
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => LandingPage(
//                         user: widget.user,
//                         sessionTimer: widget.sessionTimer,
//                       ),
//                     ));
//                 // Navigator.of(context, rootNavigator: true).pop();
//                 // await Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute<void>(
//                 //     builder: (BuildContext context) =>
//                 //         SecondPage(receivedNotification.payload),
//                 //   ),
//                 // );
//               },
//               child: const Text('Ok'),
//             )
//           ],
//         ),
//       );
//     });
//   }

//   void _configureSelectNotificationSubject() {
//     selectNotificationSubject.stream.listen((String? payload) async {
//       // await Navigator.pushNamed(context, '/secondPage');
//       await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => LandingPage(
//               user: widget.user,
//               sessionTimer: widget.sessionTimer,
//             ),
//           ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new SafeArea(
//       child: new Scaffold(
//         appBar: new WorkPlanAppBar(context, widget.user, newMessage,widget.sessionTimer),
//         backgroundColor: WorkplanPallete.grey,
//         body: loading == true
//             ? Center(
//                 child: CircularProgressIndicator(),
//               )
//             : SingleChildScrollView(
//                 child: Container(
//                     padding:
//                         EdgeInsets.only(left: 13.0, right: 13.0, top: 13.0),
//                     color: Colors.white,
//                     child: new Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         //_buildGopayMenu(),
//                         _buildGojekServicesMenu(),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//                           child: new Container(
//                             child: createListViewNotice(),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8.0, left: 13.0),
//                           child: Text("Pesan Berjalan:",
//                               style: TextStyle(
//                                   color: WorkplanPallete.green, fontSize: 14)),
//                         ),
//                         Padding(
//                           padding:
//                               const EdgeInsets.only(left: 13.0, right: 8.0),
//                           child: marqueeText == ""
//                               ? Container()
//                               : Container(
//                                   color: WorkplanPallete.green,
//                                   // width: 200.0,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(13.0),
//                                     child: MarqueeWidget(
//                                         direction: Axis.horizontal,
//                                         child: Text(
//                                           marqueeText,
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 14),
//                                         )),
//                                   )),
//                         ),
//                         Padding(
//                             padding: const EdgeInsets.all(15.0),
//                             child: Container())
//                         // Padding(
//                         //   padding:
//                         //       const EdgeInsets.only(left: 8.0, right: 8.0),
//                         //   child: new Container(
//                         //     child: createListViewNoticeMarquee(),
//                         //   ),
//                         // ),
//                       ],
//                     )),
//               ),
//       ),
//     );
//   }


//   Widget _buildGojekServicesMenu() {
//     return itemCountMenu == 0
//         ? new Container()
//         : new SizedBox(
//             width: double.infinity,
//             height: 120.0,
//             child: new Container(
//                 margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
//                 child: GridView.builder(
//                     physics: ClampingScrollPhysics(),
//                     itemCount: itemCountMenu,
//                     gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 4),
//                     itemBuilder: (context, position) {
//                       return _rowGojekService(_workplanServiceList[position]);
//                     })));
//   }

//   Widget _rowGojekService(WorkplanMenu menu) {
//     return new Container(
//       child: new Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           new GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () {
//               //sessionTimer.userActivityDetected(context, widget.user);
//               if (menu.title == "TASK") {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => TaskMenu(
//                         user: widget.user,
//                         sessionTimer: widget.sessionTimer,
//                       ),
//                     ));
//               } else if (menu.title == "INBOX") {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           WorkplanInboxPage(user: widget.user),
//                     ));
//               } else if (menu.title == "OTHER") {}
//             },
//             child: new Container(
//               decoration: new BoxDecoration(
//                   border:
//                       Border.all(color: WorkplanPallete.grey200, width: 1.0),
//                   borderRadius:
//                       new BorderRadius.all(new Radius.circular(20.0))),
//               padding: EdgeInsets.all(12.0),
//               // child: new Icon(
//               //   menu.image,
//               //   color: menu.color,
//               //   size: 32.0,
//               // ),
//               child: menu.image,
//             ),
//           ),
//           new Padding(
//             padding: EdgeInsets.only(top: 6.0),
//           ),
//           new Text(menu.title, style: new TextStyle(fontSize: 10.0))
//         ],
//       ),
//     );
//   }

//   void initNoticeApi() async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        
//           var data = {
//             "user_id": widget.user.id,
//             "company_id": widget.user.userCompanyId,
//             "organization_id": widget.user.organizationId,
//             "function_id": widget.user.functionId,
//             "structure_id": widget.user.structureId,
//           };

//           print(data);

//           print(data);
//           var response =
//               await RestService().restRequestService(SystemParam.fNotice, data);
//         setState(() {
//           loading = true;
//           // setState(() {
//           NoticeModel model = noticeModelFromJson(response.body.toString());

//           for (var i = 0; i < model.data.length; i++) {
//             if (model.data[i].mediaTypeCode == "PESAN_BERJALAN") {
//               _noticeListMarquee.add(model.data[i]);
//               marqueeText += model.data[i].noticeBody + ".           ";
//             } else if (model.data[i].mediaTypeCode == "DASHBOARD") {
//               _noticeListDashboard.add(model.data[i]);
//             }
//           }

//           loading = false;
//         });
//       }
//     } on SocketException catch (_) {}
//   }

//   getNoticeList(Notice dt) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(),
//         child: Container(
//             width: MediaQuery.of(context).size.width,
//             child: Card(
//               color: WorkplanPallete.green,
//               child: Container(
//                   child: Column(
//                 children: <Widget>[
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(left: 8.0, right: 8.0, top: 0),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Text(
//                           dt.noticeBody == null ? " " : "" + dt.noticeBody,
//                           style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.normal,
//                               fontStyle: FontStyle.italic,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding:
//                         const EdgeInsets.only(left: 8.0, right: 8.0, top: 0),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Align(
//                             alignment: Alignment.bottomLeft,
//                             child: Text(
//                               dt.createdName == null
//                                   ? " "
//                                   : " " + dt.createdName,
//                               style:
//                                   TextStyle(fontSize: 14, color: Colors.white),
//                             ),
//                           ),
//                           Align()
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               )),
//             )),
//       ),
//     );
//   }

//   ListView createListViewNotice() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _noticeListDashboard.length,
//       itemBuilder: (BuildContext context, int index) {
//         return getNoticeList(
//           _noticeListDashboard[index],
//         );
//       },
//     );
//   }

//   ListView createListViewNoticeMarquee() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _noticeListMarquee.length,
//       itemBuilder: (BuildContext context, int index) {
//         return getNoticeListMarquee(
//           _noticeListMarquee[index],
//         );
//       },
//     );
//   }

//   getNoticeListMarquee(Notice dt) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Marquee(
//         key: Key("__" + dt.id.toString()),
//         text: dt.noticeBody,
//         velocity: 50.0,
//       ),
//     );
//   }

//   void initNotice() async {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         var data = {
//           "user_id": widget.user.id,
//           "company_id": widget.user.userCompanyId,
//           "organization_id": widget.user.organizationId,
//           "function_id": widget.user.functionId,
//           "structure_id": widget.user.structureId,
//         };

//         var response =
//             await RestService().restRequestService(SystemParam.fNotice, data);

//         var convertDataToJson = json.decode(response.body);
//         // print(convertDataToJson);
//         var code = convertDataToJson['code'];
//         if (code == "0") {
//           setState(() {
//             loading = true;
//             NoticeModel messageModel =
//                 noticeModelFromJson(response.body.toString());
//             List<Notice> noticeList = messageModel.data;
//             _noticeListMarquee.clear();
//             _noticeListDashboard.clear();
//             marqueeText = "";
//             for (var i = 0; i < noticeList.length; i++) {
//               if (noticeList[i].mediaTypeCode == "PESAN_BERJALAN") {
//                 _noticeListMarquee.add(noticeList[i]);
//                 // ignore: unnecessary_null_comparison
//                 if (noticeList[i].noticeBody != null) {
//                   marqueeText += noticeList[i].noticeBody + ".           ";
//                 }
//               } else if (noticeList[i].mediaTypeCode == "DASHBOARD") {
//                 _noticeListDashboard.add(noticeList[i]);
//               }
//             }
//             loading = false;
//           });
//         }
//       }
//       //loading = false;
//     } on SocketException catch (_) {
//       //loading = true;
//       setState(() {
//         loading = true;
//         db
//             .getNoticeList(widget.user.userCompanyId.toString())
//             .then((noticeList) {
//           _noticeListMarquee.clear();
//           _noticeListDashboard.clear();
//           marqueeText = "";
//           for (var i = 0; i < noticeList.length; i++) {
//             if (noticeList[i].mediaTypeCode == "PESAN_BERJALAN") {
//               _noticeListMarquee.add(noticeList[i]);
//               marqueeText += noticeList[i].noticeBody + ".           ";
//             } else if (noticeList[i].mediaTypeCode == "DASHBOARD") {
//               _noticeListDashboard.add(noticeList[i]);
//             }
//           }
//         });
//         loading = false;
//       });
//       //
//     }
//   }

//   void initNoticePersonalCount() async {
//     setState(() {
//       loading = true;
//       db.countNoticeByMediaTypeCode("KOTAK_PERSONAL").then((value) {
//         newMessage = value;
//       });
//       loading = false;
//     });
//   }

//   initMenu() async {
//     _workplanServiceList.add(
//       new WorkplanMenu(
//           image: Image.asset(
//             "images/checked.png",
//             width: 36,
//             height: 36,
//           ),
//           color: WorkplanPallete.menuPulsa,
//           title: "TASK"),
//     );

//     _workplanServiceList.add(new WorkplanMenu(
//         image: Image.asset("images/coming_soon2.png", width: 35, height: 35),
//         color: WorkplanPallete.menuBluebird,
//         title: "ATTENDANCES"));

//     _workplanServiceList.add(new WorkplanMenu(
//         image: Image.asset("images/coming_soon2.png", width: 35, height: 35),
//         color: WorkplanPallete.menuDeals,
//         title: "APPROVAL"));

//     _workplanServiceList.add(new WorkplanMenu(
//         image: Image.asset("images/coming_soon2.png", width: 35, height: 35),
//         color: WorkplanPallete.menuTix,
//         title: "DAILY JOURNEY"));

//     itemCountMenu = 4;
//   }

//   @override
//   Widget rootWidget(BuildContext context) {
//     // TODO: implement rootWidget
//     throw UnimplementedError();
//   }
// }
