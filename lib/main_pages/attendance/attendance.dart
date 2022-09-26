import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/direction_repository.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/directions_model.dart';
import 'package:workplan_beta_test/model/attendance/attendance.dart';
import 'package:workplan_beta_test/model/attendance/shift.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';
import 'package:location_permissions/location_permissions.dart' as lp;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:datetime_setting/datetime_setting.dart';
import 'package:maps_toolkit/maps_toolkit.dart';

class Attendance extends StatefulWidget {
  final User user;
  final dynamic role;
  // final dynamic dataAttendance;
  const Attendance({
    Key? key,
    required this.user,
    required this.role,
  }) : super(key: key);

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  TextStyle style = TextStyle(
    fontFamily: "Poppins",
    fontSize: 14,
    color: Colors.white,
  );

  TextStyle styleClock = TextStyle(
      fontFamily: "Poppins",
      fontSize: 18,
      color: Colors.white,
      fontWeight: FontWeight.bold);

  // final _activityStreamController = StreamController<Activity>();
  // final _geofenceStreamController = StreamController<Geofence>();

  // // Create a [GeofenceService] instance and set options.
  // final _geofenceService = GeofenceService.instance.setup(
  //     interval: 500, //5000,
  //     accuracy: 100,
  //     loiteringDelayMs: 1000,
  //     statusChangeDelayMs: 5000, //10000,
  //     useActivityRecognition: true,
  //     allowMockLocations: false,
  //     printDevLog: false,
  //     geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  // List<Geofence> absenceLocationClockIn = [];
  // List<Geofence> absenceLocationClockOut = [];

  // dynamic loc;
  // String geofanceStatus = "";
  // String? pilihan;

  // Future<void> _onGeofenceStatusChanged(
  //     Geofence geofence,
  //     GeofenceRadius geofenceRadius,
  //     GeofenceStatus geofenceStatus,
  //     Location location) async {
  //   print('geofence: ${geofence.toJson()}');
  //   print('geofenceRadius: ${geofenceRadius.toJson()}');
  //   print('geofenceStatus: ${geofenceStatus.toString()}');
  //   setState(() {
  //     geofanceStatus = geofenceStatus.toString();
  //   });
  //   _geofenceStreamController.sink.add(geofence);
  // }

  // // This function is to be called when the activity has changed.
  // void _onActivityChanged(Activity prevActivity, Activity currActivity) {
  //   print('prevActivity: ${prevActivity.toJson()}');
  //   print('currActivity: ${currActivity.toJson()}');
  //   _activityStreamController.sink.add(currActivity);
  // }

  // // This function is to be called when the location has changed.
  // void _onLocationChanged(Location location) {
  //   print('location: ${location.toJson()}');
  //   setState(() {
  //     loc = location.toJson();
  //   });
  // }

  // // This function is to be called when a location services status change occurs
  // // since the service was started.
  // void _onLocationServicesStatusChanged(bool status) {
  //   print('isLocationServicesEnabled: $status');
  // }

  // // This function is used to handle errors that occur in the service.
  // void _onError(error) {
  //   final errorCode = getErrorCodesFromError(error);
  //   if (errorCode == null) {
  //     print('Undefined error: $error');
  //     return;
  //   }

  //   print('ErrorCode: $errorCode');
  //   if (errorCode == ErrorCodes.ALREADY_STARTED) {
  //     print('masuk ke error sudah start');
  //     _geofenceService.stop();
  //     _geofenceService
  //         .start(pilihan == 'check in'
  //             ? absenceLocationClockIn
  //             : absenceLocationClockOut)
  //         .catchError(_onError);
  //   }
  // }

  int count = 0;
  Timer? timer;
  String? userString;
  String clockInTime = '-';
  String clockOutTime = '-';
  String clockInDate = '-';
  String clockOutDate = '-';
  String shiftName = '-';
  String shiftIn = '-';
  String shiftOut = '-';
  DateTime? shiftInDt;
  DateTime? shiftOutDt;
  String absenceType = '-';
  DateTime now = DateTime.now();
  int clockout = 0;
  bool isExpired = false;
  String shiftType = '-';
  bool isCutoffExist = false;
  String cutoffTime = '-';
  bool jadwalKerjaSebelumnya = false;
  bool isAbsenceLocationCheckIn = false;
  bool isAbsenceLocationCheckOut = false;
  bool isWorkingOut = true;
  bool isQuota = false;
  bool isDeklarasi = false;
  List<dynamic> listDeklarasi = [];
  List<LatLng> listAbsenceLocationCheckIn = [];
  List<LatLng> listAbsenceLocationCheckOut = [];
  List<dynamic> listRadiusCheckIn = [];
  List<dynamic> listRadiusCheckOut = [];
  List<num> listJarakCheckIn = [];
  List<num> listJarakCheckOut = [];
  late LatLng originCheckIn;
  late LatLng originCheckOut;
  late LatLng destiny;
  late int radiusCheckIn;
  late int radiusCheckOut;
  Directions? _info;

  Location? center;
  Location? currentPosition;
  int? shiftId;
  int? locationId;
  var currentLocation;
  var myLocation;
  bool generatingLocation = false;

  // var distance = center!.distanceTo(currentPosition);
  // float distanceInMeters = center.distanceTo(test);
  // boolean isWithin10km = distanceInMeters < 10000;

  // final _geofenceList = <Geofence>[
  //   Geofence(
  //     id: 'Tembung',
  //     latitude: 3.5917493,
  //     longitude: 98.7511781,
  //     radius: [
  //       GeofenceRadius(id: 'radius_100m', length: 100),
  //       GeofenceRadius(id: 'radius_25m', length: 25),
  //       GeofenceRadius(id: 'radius_250m', length: 250),
  //       GeofenceRadius(id: 'radius_200m', length: 200),
  //     ],
  //   ),
  //   Geofence(
  //     id: 'Rumkit AU',
  //     latitude: 3.5717733,
  //     longitude: 98.6773202,
  //     radius: [
  //       GeofenceRadius(id: 'radius_25m', length: 25),
  //       GeofenceRadius(id: 'radius_100m', length: 100),
  //       GeofenceRadius(id: 'radius_200m', length: 200),
  //     ],
  //   ),
  //   Geofence(
  //     id: 'Kantor Camat Medan Timur',
  //     latitude: 3.6025199,
  //     longitude: 98.6826251,
  //     radius: [
  //       GeofenceRadius(id: 'radius_10m', length: 10),
  //       // GeofenceRadius(id: 'radius_100m', length: 100),
  //       // GeofenceRadius(id: 'radius_200m', length: 200),
  //     ],
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    // print(widget.user);
    // print(' ini jarak antara dua point <<<<<<<<<<==============');
    // var distanceBetweenPoints = SphericalUtil.computeDistanceBetween(
    //     LatLng(51.5073509, -0.1277583), LatLng(48.856614, 2.3522219));
    // print(distanceBetweenPoints);
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   _geofenceService
    //       .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    //   _geofenceService.addLocationChangeListener(_onLocationChanged);
    //   _geofenceService.addLocationServicesStatusChangeListener(
    //       _onLocationServicesStatusChanged);
    //   _geofenceService.addActivityChangeListener(_onActivityChanged);
    //   _geofenceService.addStreamErrorListener(_onError);
    //   // _geofenceService.start(_geofenceList).catchError(_onError);
    // });
    userString = jsonEncode(widget.user);
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   int? limit = widget.user.timeoutLogin * 60;
    //   // print('ini limit time logout nhya');
    //   // print(limit);
    //   if (count < limit) {
    //     // print(count);
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
    getDataAttendance();
    // _getLocation();
  }

  @override
  Widget build(BuildContext context) {
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
                currentIndex: 0,
              ),
            ),
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Attendance',
              style: TextStyle(fontFamily: "Calibre"),
            ),
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: Stack(
            children: [
              Container(
                color: SystemParam.colorCustom,
                height: 220,
                width: MediaQuery.of(context).size.width,
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        "Jam Kerja Hari Ini",
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: Reuseable.jarak3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          jamKerja(clockInTime, "Clock In", clockInDate),
                          jamKerja(clockOutTime, "Clock Out", clockOutDate),
                        ],
                      ),
                      SizedBox(height: Reuseable.jarak3),
                      Container(
                        height: 150,
                        // width: MediaQuery.of(context).size.width * 0.6,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ketShift("Shift Name", shiftName),
                            ketShift("Shift In", shiftIn),
                            ketShift("Shift Out", shiftOut),
                          ],
                        ),
                      ),
                      SizedBox(height: Reuseable.jarak3),
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(50)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  child: Text(
                                    "Clock In",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 16,
                                        color: SystemParam.colorCustom,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () async {
                                    print(widget.role);
                                    if (widget.role['isAdd'] == 0) {
                                      Warning.showWarning(
                                          "Kamu Tidak Diizin kan Untuk Melakukan Clock In");
                                      return;
                                    }
                                    // print(' ini chcek IN');
                                    // pilihan = 'check in';
                                    // _geofenceService
                                    //     .start(absenceLocationClockIn)
                                    //     .catchError(_onError);
                                    print(isExpired);
                                    print(absenceType);
                                    // return;
                                    if (isExpired == true &&
                                        // absenceType != 'berurutan' &&
                                        shiftType != 'Free Shift') {
                                      Warning.showWarning(
                                          "Jam Kerja Anda Sudah Lewat");
                                      return;
                                    }
                                    if (clockInTime != '-') {
                                      Warning.showWarning(
                                          "Anda Sudah Melakukan Clock In untuk hari ini");
                                      return;
                                    }
                                    if (shiftIn == 'Libur') {
                                      Warning.showWarning(
                                          "Hari ini tidak ada jadwal kerja");
                                      return;
                                    }
                                    if (clockInTime == '-') {
                                      cekAkses("Clock In");
                                      return;
                                    }
                                  },
                                ),
                                InkWell(
                                  child: Text(
                                    "Clock Out",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 16,
                                        color: Colors.orange[400],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    print(widget.role);
                                    if (widget.role['isAdd'] == 0) {
                                      Warning.showWarning(
                                          "Kamu Tidak Diizin kan Untuk Melakukan Clock Out");
                                      return;
                                    }
                                    // print(' ini chcek OUT');
                                    // pilihan = 'check out';
                                    // _geofenceService
                                    //     .start(absenceLocationClockOut)
                                    //     .catchError(_onError);
                                    if (clockInTime == '-' &&
                                        absenceType == 'berurutan') {
                                      Warning.showWarning(
                                          "Silahkan clock in terlebih dahulu");
                                      return;
                                    }
                                    if (clockOutTime != '-') {
                                      Warning.showWarning(
                                          "Anda Sudah Melakukan Clock Out untuk hari ini");
                                      return;
                                    }
                                    print(' ini check OUT');
                                    cekAkses("Clock Out");
                                  },
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  if (myLocation != null) {
                                    setState(() {
                                      myLocation = null;
                                    });
                                    return;
                                  }
                                  setState(() {
                                    generatingLocation = true;
                                  });
                                  var location =
                                      await gl.Geolocator.getCurrentPosition(
                                          desiredAccuracy:
                                              gl.LocationAccuracy.best);
                                  setState(() {
                                    myLocation = location;
                                    generatingLocation = false;
                                  });
                                  // print(
                                  //     "Ini Current Location nya <<<<<=========");
                                  // print(currentLocation);
                                  // destiny = LatLng(currentLocation.latitude,
                                  //     currentLocation.longitude);
                                },
                                child: ClipOval(
                                    child: Image.asset(
                                        "images/Attandance/Group 91.png")),
                              ),
                            ),
                          )
                        ],
                      ),
                      // untuk cek lat long curren location
                      SizedBox(height: Reuseable.jarak3),
                      if (generatingLocation)
                        Center(child: CircularProgressIndicator()),
                      if (myLocation != null) Text(myLocation.toString())
                      // Text(listRadiusCheckIn.toString()),
                      // Text(listJarakCheckIn.toString())
                      // const SizedBox(height: 20.0),
                      // Text('ini Activity monitor'),
                      // _buildActivityMonitor(),
                      // const SizedBox(height: 20.0),
                      // Text('ini Geofence monitor'),
                      // _buildGeofenceMonitor(),
                      // Divider(),
                      // Text('ini Location Change'),
                      // _buildLocationChange(),
                      // Divider(),
                      // Text('ini Geofence Status'),
                      // _buildGeofenceStatus()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _activityStreamController.close();
    // _geofenceStreamController.close();
    super.dispose();
  }

  // Widget _buildActivityMonitor() {
  //   return StreamBuilder<Activity>(
  //     stream: _activityStreamController.stream,
  //     builder: (context, snapshot) {
  //       final updatedDateTime = DateTime.now();
  //       final content = snapshot.data?.toJson().toString() ?? '';

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('•\t\tActivity (updated: $updatedDateTime)'),
  //           const SizedBox(height: 10.0),
  //           Text(content),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildGeofenceMonitor() {
  //   return StreamBuilder<Geofence>(
  //     stream: _geofenceStreamController.stream,
  //     builder: (context, snapshot) {
  //       final updatedDateTime = DateTime.now();
  //       final content = snapshot.data?.toJson().toString() ?? '';

  //       return Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('•\t\tGeofence (updated: $updatedDateTime)'),
  //           const SizedBox(height: 10.0),
  //           Text(content),
  //         ],
  //       );
  //     },
  //   );
  // }

  // _buildLocationChange() {
  //   return Text(loc.toString());
  // }

  // _buildGeofenceStatus() {
  //   return Text(geofanceStatus);
  // }

  cekAkses(String type) async {
    bool? timeAuto = await DatetimeSetting.timeIsAuto();
    bool? timezoneAuto = await DatetimeSetting.timeZoneIsAuto();
    try {
      Warning.loading(context);
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _getLocation().then((value) {
          print('ini value dari get device location <<<<<<========');
          print(value);
          next() {
            if (value!) {
              // print(
              //     'hasil cek auto datetime and atuo timezone <<<<<<<<<<=========');
              // print(timeAuto);
              // print(timezoneAuto);
              if (!timeAuto || !timezoneAuto) {
                Navigator.pop(context);
                Warning.showWarning(
                    "Aktifkan Auto DateTime dan Auto TimeZone Terlebih dahulu !!!");
                return;
              } else {
                // bool isAbsenceLocation;
                // if (type == "Clock In") {
                //   isAbsenceLocation = isAbsenceLocationCheckIn;
                // } else {
                //   isAbsenceLocation = isAbsenceLocationCheckOut;
                // }
                if (isWorkingOut == true) {
                  // timer!.cancel();
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    locationClockInClockOut,
                    arguments: {
                      "type": type,
                      "user": userString,
                      "jamMulaiKerja": shiftIn,
                      "jamSelesaiKerja": shiftOut,
                      "role": widget.role,
                      "locationId": locationId,
                      "shiftId": shiftId
                    },
                  );
                } else {
                  // timer!.cancel();
                  // Navigator.pop(context);
                  // Navigator.pushNamed(
                  //   context,
                  //   locationClockInClockOut,
                  //   arguments: {
                  //     "type": type,
                  //     "user": userString,
                  //   },
                  // );
                  cekRadius(type).then(
                    (value) {
                      print('Ini hasil dari cek radius <<<<<<<=======');
                      print(value);
                      List<num> result = value;
                      bool isInRadius = false;
                      var pebanding = type == "Clock In"
                          ? listRadiusCheckIn
                          : listRadiusCheckOut;
                      // value = [1,980 km, 1 m, 11.7 km, 8.6 km]
                      for (var i = 0; i < result.length; i++) {
                        print('cek radius <<<<<<<<<<===========');
                        print(result[i]);
                        var intVal = result[i];
                        if (intVal <= pebanding[i]['radius']) {
                          isInRadius = true;
                          locationId = pebanding[i]['id'];
                        }
                        // print(result[i].contains("km"));
                        // if (!result[i].contains("km")) {
                        //   var val = result[i].split(" ");
                        // }
                      }

                      // var regExp = new RegExp(r'[^0-9]');
                      // String clrStr = value.totalDistance.replaceAll(regExp, '');
                      // int jarak = int.parse(clrStr);
                      if (!isInRadius) {
                        Navigator.pop(context);
                        Warning.showWarning(
                            'Anda berada diluar radius yang telah di tetapkan');
                      } else {
                        if (isDeklarasi) {
                          List<String> deklarasiBelumIsi = [];
                          List<String> deklarasiTidakLulus = [];
                          for (var i = 0; i < listDeklarasi.length; i++) {
                            if (listDeklarasi[i]['is_passed'] == null) {
                              deklarasiBelumIsi.add(listDeklarasi[i]['title']);
                            }
                            if (listDeklarasi[i]['is_passed'] == false) {
                              deklarasiTidakLulus
                                  .add(listDeklarasi[i]['is_title']);
                            }
                          }
                          if (deklarasiBelumIsi.length > 0) {
                            String deklarasiString =
                                deklarasiBelumIsi.join(",");
                            Navigator.pop(context);
                            Warning.showWarning(
                                "Silahkan Isi Deklarasi $deklarasiString terlebih dahulu");
                            return;
                          }
                          if (deklarasiTidakLulus.length > 0) {
                            Navigator.pop(context);
                            Warning.showWarning(
                                "Kamu Tidak Diizinkan Untuk Absence Karena Hasil Deklarasi kamu 'GAGAL' ");
                            return;
                          }
                          timer!.cancel();
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            locationClockInClockOut,
                            arguments: {
                              "type": type,
                              "user": userString,
                              "jamMulaiKerja": shiftIn,
                              "jamSelesaiKerja": shiftOut,
                              "role": widget.role,
                              "locationId": locationId,
                              "shiftId": shiftId
                            },
                          );
                        } else {
                          // timer!.cancel();
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            locationClockInClockOut,
                            arguments: {
                              "type": type,
                              "user": userString,
                              "jamMulaiKerja": shiftIn,
                              "jamSelesaiKerja": shiftOut,
                              "role": widget.role,
                              "locationId": locationId,
                              "shiftId": shiftId
                            },
                          );
                        }
                      }
                      // print(jarak);
                      print(
                          type == "Clock In" ? radiusCheckIn : radiusCheckOut);
                    },
                  );
                }
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
    lp.PermissionStatus permission = await _getLocationPermission();
    if (permission == lp.PermissionStatus.granted) {
      print('disini permission status grand');
      try {
        currentLocation = await gl.Geolocator.getCurrentPosition(
            desiredAccuracy: gl.LocationAccuracy.best);
        print("Ini Current Location nya <<<<<=========");
        print(currentLocation);
        destiny = LatLng(currentLocation.latitude, currentLocation.longitude);
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

  jamKerja(String jam, String tipe, String tanggal) {
    return Column(
      children: [
        Text(jam, style: styleClock),
        Text(tipe, style: style),
        Text(tanggal, style: style)
      ],
    );
  }

  ketShift(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Text(key,
              style: TextStyle(
                  color: SystemParam.colorDivider,
                  fontFamily: "Calibre",
                  fontSize: 16)),
        ),
        Expanded(
          flex: 1,
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: SystemParam.colorCustom,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Calibre",
                  fontSize: 16)),
        ),
      ],
    );
  }

  void getDataAttendance() async {
    print("masuk ke get attendance <<<<<<<<<=======");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isCutoffExist = prefs.containsKey('cutoff');
    var response = await RestService().requestServiceGet(SystemParam.attendance,
        "${widget.user.id}", "company_id=${widget.user.userCompanyId}");
    var responseJson = json.decode(response.body);
    print('ini data attendance <<<<<<<<=======');
    var data = responseJson['data'];
    print(data['shift']['type']);
    print(data['shift']['name']);

    if (data['parameter']['declaration'].length > 0) {
      isDeklarasi = true;
      listDeklarasi = data['parameter']['declaration'];
    }
    if (data['parameter']["work_outside_schedule"] == false ||
        data['parameter']["work_outside_schedule"] == null) {
      isWorkingOut = false;
    }

    for (var item in data['absence_checkin_location']) {
      if (item['status'] == 1) {
        listRadiusCheckIn.add({"id": item['id'], "radius": item['radius']});
        listAbsenceLocationCheckIn.add(LatLng(
            double.parse(item["latitude"]), double.parse(item["longitude"])));
        isAbsenceLocationCheckIn = true;
      }
    }
    for (var item in data['absence_checkout_location']) {
      if (item['status'] == 1) {
        listRadiusCheckOut.add({"id": item['id'], "radius": item['radius']});
        listAbsenceLocationCheckOut.add(LatLng(
            double.parse(item["latitude"]), double.parse(item["longitude"])));
        isAbsenceLocationCheckOut = true;
      }
    }
    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   _geofenceService
    //       .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    //   _geofenceService.addLocationChangeListener(_onLocationChanged);
    //   _geofenceService.addLocationServicesStatusChangeListener(
    //       _onLocationServicesStatusChanged);
    //   _geofenceService.addActivityChangeListener(_onActivityChanged);
    //   _geofenceService.addStreamErrorListener(_onError);
    // });
    // for (var item in data['absence_checkin_location']) {
    //   if(item['status'] == 1)

    // }
    print(listRadiusCheckIn);
    print(listAbsenceLocationCheckIn);
    // radiusCheckIn = data['absence_checkin_location'][0]['radius'];

    // originCheckIn = LatLng(
    //     double.parse(data['absence_checkin_location'][0]["latitude"]),
    //     double.parse(data['absence_checkin_location'][0]["longitude"]));
    // }
    // if (data['absence_checkout_location'][0]['status'] == 1) {
    //   for (var item in data['absence_checkout_location']) {
    //     listRadiusCheckOut.add(item['radius']);
    //   }
    //   for (var item in data['absence_checkout_location']) {
    //     listAbsenceLocationCheckOut.add(LatLng(
    //         double.parse(item["latitude"]), double.parse(item["longitude"])));
    //   }

    //   isAbsenceLocationCheckOut = true;
    //   print(listRadiusCheckOut);
    //   print(listAbsenceLocationCheckOut);
    // }

    // DataAttendance dataAttendance = DataAttendance.fromJson(data);
    // prefs.remove('jadwalKerjaSebelumnya');
    // jadwalKerjaSebelumnya = prefs.containsKey('jadwalKerjaSebelumnya');
    // print('apakah jadwal kerja sebelumnya sudah ada ? $jadwalKerjaSebelumnya');
    // shiftInDt = DateTime.parse(data['shift']['detail']['clock_in']);
    // shiftOutDt = data['shift']['detail']['is_selected'] ? DateTime.parse(data['shift']['detail']['clock_out']);

    // var two =
    //     format.parse(data['shift']['detail']['clock_out'].substring(11, 16));
    // print("${two.difference(one)}");
    // Duration diff = two.difference(one);
    // final minutes = diff.inMinutes % 60; // prints 7:40
    // print(minutes);
    // cutoffTime =

    // jika clockout timenya lebih besar dari jam 12 maka cutoff timenya jam 24:00
    // jika clockout timenya lebih kecil dari jam 12 maka cutoff timenya jam 12:00
    if (data['clock_in'] == null) {
      clockInTime = "-";
      clockInDate = "-";
    } else {
      clockInTime =
          data['clock_in']['time'] + " " + data['clock_in']['timezone'];
      clockInDate = await changeFormat(data['clock_in']['date']);
    }

    if (data['clock_out'] == null) {
      clockOutTime = "-";
      clockOutDate = "-";
    } else {
      clockOutTime =
          data['clock_out']['time'] + " " + data['clock_out']['timezone'];
      clockOutDate = await changeFormat(data['clock_out']['date']);
    }
    if (data['shift']['name'] != null) {
      setState(() {
        shiftName = data['shift']['name'];
        shiftId = data['shift']['id'];
      });
    }

    if (data['shift']['type'] == 'Fixed Hour' ||
        data['shift']['type'] == 'Flexible Hour') {
      setState(() {
        if (data['shift']['detail']['is_selected']) {
          var format = DateFormat("HH:mm");
          var one = format.parse("12:00");
          var two = format
              .parse(data['shift']['detail']['clock_out'].substring(11, 16));
          bool jamTerakhirClockout = one.isAfter(two);
          if (jamTerakhirClockout) {
            print('cutoff time nya : 12:00 <<<=====');
            cutoffTime = "12:00";
          } else {
            print('cutoff time nya : 23:59 <<<=====');
            cutoffTime = "23:59";
          }
          var jamShiftOut = format
              .parse(data['shift']['detail']['clock_out'].substring(11, 16));
          var timeNow =
              format.parse(DateTime.now().toString().substring(11, 16));
          print('Ini jam Sekarang <<<<<=====');
          print(timeNow);
          print('Ini jam Shift Out <<<<<=====');
          print(jamShiftOut);
          isExpired = timeNow.isAfter(jamShiftOut);
          print(isExpired);
          // print("apakah jam sekarang sudah melewati jam shift out : $jamNow");
          // if (jadwalKerjaSebelumnya == false) {
          //   var jadwalKerja = {
          //     "shift_in": data['shift']['detail']['clock_in'],
          //     "shif_out": data['shift']['detail']['clock_out'],
          //     "cutoff": data['shift']['detail']['clock_out'].substring(0, 10) +
          //         ' ' +
          //         cutoffTime,
          //     "isClockOut": false
          //   };
          //   prefs.setString('jadwalKerjaSebelumnya', jsonEncode(jadwalKerja));
          // } else {
          //   print(
          //       'ini dari cek jadwal kerja sebelumnya hasilnya sudah ada<<<<<<=======');
          //   //     var jadwalKerja = {
          //   //   "shift_in": data['shift']['detail']['clock_in'],
          //   //   "shif_out": data['shift']['detail']['clock_out'],
          //   //   "cutoff": data['shift']['detail']['clock_out'].substring(0, 10) +
          //   //       ' ' +
          //   //       cutoffTime,
          //   //   "isClockOut": false
          //   // };
          //   // String jadwal = jadwalKerja.toString(); //prefs.getString('jadwalKerjaSebelumnya')!;
          //   // var jadwalKerjaSebelumnya = json.decode(jadwal);
          //   // print(jadwalKerjaSebelumnya);
          // }
          // print("waktu clock out <<<<<====");
          // String waktuClockout = "${data['shift']['detail']['clock_out']}";
          // print(waktuClockout);
          // cutoffTime = DateTime.parse(waktuClockout) as String;
          // print(DateFormat('EEEE').format(cutoffTime!));
          // print('ini cutoff time nya $cutoffTime <<<<<<=========');
          // print("ini setelah di convert <<<<<<<========");
          // isExpired = now.isAfter(cutoffTime);
          // print('ini clock out nya sudah lewat atau belum : $isExpired');
          // print(data['absence_type']);

          shiftIn = "${data['shift']['detail']['clock_in'].substring(11, 16)}";
          shiftOut =
              "${data['shift']['detail']['clock_out'].substring(11, 16)}";
        } else {
          if (data['shift']['name'] != null) {
            shiftName = data['shift']['name'];
          }
          shiftIn = 'Libur';
          shiftOut = 'Libur';
        }

        if (data['absence_type'] != null) {
          absenceType = data['absence_type'];
        }

        shiftType = data['shift']['type'];
      });
    } else if (data['shift']['type'] == 'Flexi Date') {
      print('masuk settingan Flexi Date <<<<<<<<========');
      if (data['shift']['detail'] == null) {
        shiftIn = 'Libur';
        return;
      }
      var format = DateFormat("HH:mm");
      var one = format.parse("12:00");
      var two = format.parse(data['shift']['detail']['thru_time']);
      bool jamTerakhirClockout = one.isAfter(two);
      if (jamTerakhirClockout) {
        print('cutoff time nya : 12:00 <<<=====');
        cutoffTime = "12:00";
      } else {
        print('cutoff time nya : 23:59 <<<=====');
        cutoffTime = "23:59";
      }
      // if (jadwalKerjaSebelumnya == false) {
      //   var jadwalKerja = {
      //     "shift_in": data['shift']['detail']['start_time'],
      //     "shif_out": data['shift']['detail']['thru_time'],
      //     "cutoff": data['shift']['detail']['date'] + ' ' + cutoffTime,
      //     "isClockOut": false
      //   };
      //   prefs.setString('jadwalKerjaSebelumnya', jsonEncode(jadwalKerja));
      // }
      var jamShiftOut = format.parse(data['shift']['detail']['thru_time']);
      var timeNow = format.parse(DateTime.now().toString().substring(11, 16));
      print('Ini jam Sekarang <<<<<=====');
      print(timeNow);
      print('Ini jam Shift Out <<<<<=====');
      print(jamShiftOut);
      isExpired = timeNow.isAfter(jamShiftOut);
      print(isExpired);
      setState(() {
        shiftIn = "${data['shift']['detail']['start_time']}";
        shiftOut = "${data['shift']['detail']['thru_time']}";
        print('ini data shift in shift out nya <<<<<<<+=========');
        print(shiftIn);
        print(shiftIn);
        if (data['shift']['name'] != null) {
          shiftName = data['shift']['name'];
        }
      });
    }
  }

  Future cekRadius(String type) async {
    print('Cek jarak antar point <<<<<=====');
    print(listAbsenceLocationCheckIn);
    print(listAbsenceLocationCheckOut);
    listJarakCheckIn = [];
    listJarakCheckOut = [];
    for (var item in type == "Clock In"
        ? listAbsenceLocationCheckIn
        : listAbsenceLocationCheckOut) {
      print('$item >< $destiny ');
      // var distanceBetweenPoints =
      //     SphericalUtil.computeDistanceBetween(destiny, item);
      var distanceBetweenPoints = Geolocator.distanceBetween(destiny.latitude, destiny.longitude, item.latitude, item.longitude);
      type == "Clock In"
          ? listJarakCheckIn.add(distanceBetweenPoints)
          : listJarakCheckOut.add(distanceBetweenPoints);
    }
    setState(() {});
    // final directions = await DirectionsRepository()
    //     .getDirections(origin: item, destination: destiny);
    // print('ini total jarak nya <<<====');
    // print(directions!.totalDistance);
    return type == "Clock In" ? listJarakCheckIn : listJarakCheckOut;
    // return directions;
    // setState(() {
    //   _info = directions;
    // });
  }

  changeFormat(String dateInput) {
    DateTime date = DateTime.parse(dateInput);
    final format = DateFormat('dd MMMM yyyy', 'id');
    String stringDate = format.format(date).toString();
    return stringDate;
  }
}
