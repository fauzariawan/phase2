import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:datetime_setting/datetime_setting.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/visit_checkin_log_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/model/workplan_visit_model.dart';
import 'package:workplan_beta_test/pages/workplan/visit_checkin.dart';
import 'package:workplan_beta_test/pages/workplan/visit_checkout.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_visit_list.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';
import 'package:location_permissions/location_permissions.dart' as lp;
import 'package:geolocator/geolocator.dart' as gl;

class VisitProcess extends StatefulWidget {
  final WorkplanInboxData workplan;
  final WorkplanVisit workplanVisit;
  final User user;
  final int nomor;
  final bool isMaximumUmur;
  final dynamic role;


  const VisitProcess(
      {Key? key,
      required this.workplan,
      required this.workplanVisit,
      required this.user,
      required this.nomor,
      required this.isMaximumUmur, required this.role})
      : super(key: key);
  @override
  _VisitProcessState createState() => _VisitProcessState();
}

class _VisitProcessState extends State<VisitProcess> {
  final _keyForm = GlobalKey<FormState>();
  MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);
  late WorkplanInboxData wid;
  bool loading = false;
  bool isPhotoFromCamCheckIn = false;
  bool isPhotoFromCamCheckOut = false;
  // late Timer _timer;
  var db = new DatabaseHelper();
  int count = 0;
  Timer? timer;
  String? userString;
  // SessionTimer sessionTimer = new SessionTimer();
  // cons twentyMillis = Duration(milliseconds: 20);

  @override
  void initState() {
    // Timer.periodic(Duration(minutes: 1), (Timer timer) {
    //   checkInTimeOutNotification();
    // });
    super.initState();
    userString = jsonEncode(widget.user);
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
    wid = widget.workplan;
    getWorkplanById();

    //print("widget.workplanVisit.flagUpdate:"+widget.workplanVisit.flagUpdate.toString());
  }

  @override
  Widget build(BuildContext context) {
    var lblCheckInOut = "CHECK IN";
    //if (widVisit.checkIn != null && widVisit.checkIn != "") {
    // if (wid.isCheckIn == "1" ) {
    // ignore: unnecessary_null_comparison
    if (widget.workplanVisit.isCheckIn == "1" &&
        // ignore: unnecessary_null_comparison
        (widget.workplanVisit.isCheckOut == null ||
            widget.workplanVisit.isCheckOut == "0")) {
      lblCheckInOut = "CHECK OUT";
      isPhotoFromCamCheckIn = true;
    }

    if (widget.workplanVisit.isCheckOut == "1") {
      isPhotoFromCamCheckOut = true;
    }

    return Listener(
      onPointerDown: (PointerDownEvent event) {
       TimerCountDown().activityDetected();
      },
      child: WillPopScope(
        onWillPop: () async {
          // timer!.cancel();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkplanVisitList(
                  role: widget.role,
                    workplan: widget.workplan,
                    user: widget.user,
                    isMaximumUmur: widget.isMaximumUmur),
              ));
          return false;
        },
        child: Scaffold(
          //drawer: NavigationDrawerWidget(),
          appBar: AppBar(
            title: Text('Visit Activity Task'),
            centerTitle: true,
            backgroundColor: colorCustom,
            automaticallyImplyLeading: false,
          ),
          body: Form(
            key: _keyForm,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Card(
                      color: Colors.white,
                      elevation: 0.1,
                      child: ListTile(
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 0.0, top: 8.0),
                          child: Image.asset(
                            "images/Menu_Task/List_Task/Icon_List_Task2.png",
                          ),
                        ),
                        title: Text(widget.workplan.nomorWorkplan,
                            style: TextStyle(
                                fontSize: 12,
                                color: SystemParam.colorCustom,
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.workplan.fullName,
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Badge(
                                toAnimate: false,
                                shape: BadgeShape.square,
                                badgeColor: SystemParam.colorCustom,
                                borderRadius: BorderRadius.circular(20),
                                badgeContent: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                      widget.workplan.progresStatusDescription,
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.white)),
                                ),
                              ),
                            ),
                            Icon(Icons.more_vert)
                          ],
                        ),
                        onTap: () {},
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: SystemParam.colorDivider),
                            Text(
                              "Rencana Kunjungan ke " + widget.nomor.toString(),
                              style: TextStyle(
                                  color: SystemParam.colorCustom, fontSize: 14),
                            ),
                            TextFormField(
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              style: new TextStyle(color: Colors.black),
                              initialValue: SystemParam.formatDateDisplay
                                  .format(widget.workplanVisit.visitDatePlan),
                              readOnly: true,
                              //validator: requiredValidator,
                              enabled: true,
                              onSaved: (em) {
                                //if (em != null) {}
                              },
                              decoration: InputDecoration(
                                icon: new Icon(Icons.date_range),
                                fillColor: colorCustom,
                                // labelText: labelUdfTextA1,
                                labelStyle: TextStyle(
                                    color: colorCustom,
                                    fontStyle: FontStyle.normal),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red.withOpacity(0),
                                      width: 2.0,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colorCustom.withOpacity(0)),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Reuseable.jarak3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text(lblCheckInOut),
                          style: ElevatedButton.styleFrom(
                            primary: colorCustom,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            // timer!.cancel();
                            cekAkses(lblCheckInOut == 'CHECK IN'
                                ? 'CHECK IN'
                                : 'CHECK OUT');
                            // try {
                            //   Warning.loading(context);
                            //   final result =
                            //       await InternetAddress.lookup('example.com');
                            //   if (result.isNotEmpty &&
                            //       result[0].rawAddress.isNotEmpty) {
                            //     _getLocation().then((value) {
                            //       print(
                            //           'ini value dari get device location <<<<<<========');
                            //       next() {
                            //         if (value!) {
                            //           if (lblCheckInOut == "CHECK OUT") {
                            //             print('masuk checkout');
                            //             Navigator.pop(context);
                            //             Navigator.push(
                            //                 context,
                            //                 MaterialPageRoute(
                            //                   builder: (context) =>
                            //                       VisitCheckOut(
                            //                     workplan: wid,
                            //                     workplanVisit:
                            //                         widget.workplanVisit,
                            //                     user: widget.user,
                            //                     lblCheckInOut: lblCheckInOut,
                            //                     isMaximumUmur:
                            //                         widget.isMaximumUmur,
                            //                     nomor: widget.nomor,
                            //                     isPhotoFromCam:
                            //                         isPhotoFromCamCheckOut,
                            //                   ),
                            //                 ));
                            //           } else if (lblCheckInOut == "CHECK IN") {
                            //             print('masuk checkin');
                            //             Navigator.pop(context);
                            //             Navigator.push(
                            //                 context,
                            //                 MaterialPageRoute(
                            //                   builder: (context) =>
                            //                       VisitCheckIn(
                            //                     workplan: wid,
                            //                     workplanVisit:
                            //                         widget.workplanVisit,
                            //                     user: widget.user,
                            //                     lblCheckInOut: lblCheckInOut,
                            //                     isMaximumUmur:
                            //                         widget.isMaximumUmur,
                            //                     nomor: widget.nomor,
                            //                     isPhotoFromCam:
                            //                         isPhotoFromCamCheckIn,
                            //                   ),
                            //                 ));
                            //           }
                            //         } else {
                            //           Navigator.pop(context);
                            //           Warning.showWarning(
                            //               'Aktifkan GPS Terlebih Dahulu!!!');
                            //         }
                            //       }

                            //       warning() {
                            //         Navigator.pop(context);
                            //         Warning.showWarning(
                            //             'Berikan Akses Lokasi Terlebih Dahulu!!!');
                            //       }

                            //       print(value);
                            //       value == null ? warning() : next();
                            //     });
                            //   }
                            // } on SocketException catch (_) {
                            //   Navigator.pop(context);
                            //   Warning.showWarning('No Internet Connection');
                            // }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  cekAkses(String type) async {
    bool? timeAuto = await DatetimeSetting.timeIsAuto();
    bool? timezoneAuto = await DatetimeSetting.timeZoneIsAuto();
    try {
      Warning.loading(context);
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _getLocation().then((value) {
          print('ini value dari get device location <<<<<<========');
          next() {
            if (value!) {
              if (!timeAuto || !timezoneAuto) {
                Navigator.pop(context);
                Warning.showWarning(
                    "Aktifkan Auto DateTime dan Auto TimeZone Terlebih dahulu !!!");
                return;
              } else {
                if (type == "CHECK IN") {
                  print('masuk checkin');
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisitCheckIn(
                          role: widget.role,
                          workplan: wid,
                          workplanVisit: widget.workplanVisit,
                          user: widget.user,
                          lblCheckInOut: type,
                          isMaximumUmur: widget.isMaximumUmur,
                          nomor: widget.nomor,
                          isPhotoFromCam: isPhotoFromCamCheckIn,
                        ),
                      ));
                } else {
                  print('masuk checkout');
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisitCheckOut(
                          role: widget.role,
                          workplan: wid,
                          workplanVisit: widget.workplanVisit,
                          user: widget.user,
                          lblCheckInOut: type,
                          isMaximumUmur: widget.isMaximumUmur,
                          nomor: widget.nomor,
                          isPhotoFromCam: isPhotoFromCamCheckOut,
                        ),
                      ));
                }
                // Navigator.pop(context);
                // Navigator.pushNamed(
                //   context,
                //   locationClockInClockOut,
                //   arguments: {"type": type, "user": userString},
                // );
              }
            } else {
              Navigator.pop(context);
              Warning.showWarning('Aktifkan GPS Terlebih Dahulu!!!');
            }
          }

          warning() {
            Navigator.pop(context);
            Warning.showWarning('Berikan Akses Lokasi Terlebih Dahulu!!!');
          }

          print(value);
          value == null ? warning() : next();
        });
      }
    } on SocketException catch (_) {
      Navigator.pop(context);
      Warning.showWarning('No Internet Connection');
    }
  }

  Future<bool?> _getLocation() async {
    print('masuk get location');
    var currentLocation;
    lp.PermissionStatus permission = await _getLocationPermission();
    if (permission == lp.PermissionStatus.granted) {
      print('disini permission status grand');
      try {
        currentLocation = await gl.Geolocator.getCurrentPosition(
            desiredAccuracy: gl.LocationAccuracy.best);
        print(currentLocation);
        if (currentLocation != null) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        currentLocation = null;
        return false;
      }
    } else if (permission == lp.PermissionStatus.denied) {
      print('disini permission status denied <<<====');
      return null;
    } else if (permission == lp.PermissionStatus.restricted) {
      print('disini permission status restricted <<<====');
      return null;
    } else {
      return false;
    }
    // return currentLocation;
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

  void getWorkplanById() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        loading = true;
        var data = {
          "id": widget.workplan.id,
        };

        var response = await RestService()
            .restRequestService(SystemParam.fWorkplanById, data);

        setState(() {
          WorkplanInboxModel wi =
              workplanInboxFromJson(response.body.toString());
          wid = wi.data[0];
          loading = false;
        });
      }
    } on SocketException catch (_) {}
  }

  void checkInTimeOutNotification() {
    var now = DateTime.now();
    DatabaseHelper().db.then((database) {
      Future<List<VisitChecInLog>> vlFuture = db.getVisitCheckInLogList();
      vlFuture.then((vl) {
        setState(() {
          List<VisitChecInLog> vlData = vl;
          //print("checkInBatas:"+vlData[0].checkInBatas);
          // print("vlData.length :"+vlData.length.toString());
          for (var i = 0; i < vlData.length; i++) {
            var checkInBatas = DateTime.parse(vlData[0].checkInBatas);
            //var checkInBatas = DateTime.parse("2021-09-29 16:09:00");

            if (now.isAfter(checkInBatas)) {
              //print("notif timeout");
              notification(context, vlData[0]);
            }

            print("checkInBatas:" +
                checkInBatas.toString() +
                ",now:" +
                now.toString());
          }
        });
      });
    });
  }

  void notification(context, VisitChecInLog vlData) {
    showOverlayNotification((context) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: SafeArea(
          child: ListTile(
            leading: SizedBox.fromSize(
                size: const Size(40, 40),
                child: ClipOval(
                    child: Container(
                  color: Colors.black,
                ))),
            //title: Text('Batas Waktu Kunjungan'),
            subtitle: Text(
                ' Anda telah melampaui batas waktu kunjungan workplan, Simpan segera selesaikan aktifitas Anda dan lakukan check out'),
            trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  OverlaySupportEntry.of(context)!.dismiss();
                }),
          ),
        ),
      );
    }, duration: Duration(milliseconds: 8000));
  }
}
