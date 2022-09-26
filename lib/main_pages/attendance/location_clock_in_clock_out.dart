import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/attendance/attendance.dart';
import 'package:workplan_beta_test/main_pages/attendance/result_clock_in_clock_out.dart';
import 'package:workplan_beta_test/main_pages/attendance/service_location.dart';
// import 'package:workplan_beta_test/main_pages/attendance/services/service_location.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_visit_model.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:location_permissions/location_permissions.dart' as lp;
import 'package:geocoding/geocoding.dart' as gc;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';

import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';

import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:datetime_setting/datetime_setting.dart';
// import 'package:geocoding/geocoding.dart';

class LocationClockInClockOut extends StatefulWidget {
  final String type;
  final User user;
  final String jamMulaiKerja;
  final String jamSelesaiKerja;
  final dynamic role;
  final int locationId;
  final int shiftId;

  const LocationClockInClockOut(
      {Key? key,
      required this.type,
      required this.user,
      required this.jamMulaiKerja,
      required this.jamSelesaiKerja,
      required this.role,
      required this.locationId,
      required this.shiftId})
      : super(key: key);

  @override
  State<LocationClockInClockOut> createState() =>
      _LocationClockInClockOutState();
}

class _LocationClockInClockOutState extends State<LocationClockInClockOut> {
  MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);
  bool loading = false;
  late gl.Position userLocation;
  late String _currentAddress = "";
  TextEditingController _addressCtr = new TextEditingController();
  late LatLng _initialcameraposition = LatLng(-6.2293867, 106.6894316);
  bool isInitialCamera = false;
  Location _location = Location();
  var progressStatusId = 2;
  late var time = SystemParam.formatTime.format(DateTime.now());
  late Image _imageFromPreferences;
  late WorkplanVisit _widVisit;
  bool isPhotoCheckIn = false;
  late WorkplanInboxData _wid;
  var photoCheckIn = "";
  var db = new DatabaseHelper();
  String _latitude = "";
  String _longitude = "";
  //  SessionTimer sessionTimer = new SessionTimer();
  // late LatLng _initialcameraposition;

  // bool isPhotoFromCam = false;
  // WorkplanInboxData _workplan;
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  Uint8List? markerIcon;
  Marker? marker;
  Set<Marker> _markers = {};
  BitmapDescriptor? mapMarker;
  int count = 0;
  Timer? timer;
  String alamat = "";
  List listAlamat = [];
  String namePlace = '';
  String addressPlace = '';
  String userString = '';
  String indoZone = '';
  int validationFaceType = 1;
  String login_via = "-";
  late CameraDescription cameraDescription;
  bool authenticated = false;

  // untuk timezone
  final methodChannel = const MethodChannel('sample_time_zone_flutter_channel');

  var eventTimeInMillis = 0;
  var strEventTime = 'No Event';
  var timezone = '';
  var strGmtOffset = '';
  late tz.Location timezoneLocation;
  DateTime dateTime = DateTime.now();
  var now;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    validationFaceType = widget.user.validationFaceType;

    now = DateFormat.Hm().format(dateTime);
    // var inputFormat = DateFormat('HH:mm');
    // now = inputFormat.parse('$dateTime');
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
    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    //   var timezoneNative =
    //       await methodChannel.invokeMethod('get_native_time_zone');
    //   timezone = timezoneNative['timezone'] as String;
    //   timezoneLocation = tz.getLocation(timezone);
    //   var gmtOffset = timezoneNative['gmt_offset'] as int;
    //   var symbol = gmtOffset >= 0 ? '+' : '-';
    //   var hourGmtOffset = gmtOffset ~/ 3600;
    //   var minuteGmtOffset = (gmtOffset % 3600) ~/ 60;
    //   var strHourGmtOffset = hourGmtOffset.abs().toString().padLeft(2, '0');
    //   var strMinuteGmtOffset = minuteGmtOffset.abs().toString().padLeft(2, '0');
    //   strGmtOffset = 'GMT$symbol$strHourGmtOffset:$strMinuteGmtOffset';
    //   switch (strGmtOffset) {
    //     case 'GMT+08:00':
    //       indoZone = 'WITA';
    //       break;
    //     case 'GMT+09:00':
    //       indoZone = 'WIT';
    //       break;
    //     default:
    //       indoZone = 'WIB';
    //       break;
    //   }
    //   setState(() {});
    // });
    // cekAutoDateAndTimezone();
    infoLogin();
    startCamera();
    getDeviceLocation();
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
              builder: (context) => Attendance(
                role: widget.role,
                user: widget.user,
              ),
            ),
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Location " + widget.type),
            centerTitle: true,
          ),
          body: loading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            isInitialCamera == false
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : SizedBox(
                                    width: 500, // or use fixed size like 200
                                    height: 300,
                                    child:
                                        // GoogleMap(
                                        //   mapType: MapType.normal,
                                        //   initialCameraPosition: _kGooglePlex,
                                        //   onMapCreated:
                                        //       (GoogleMapController controller) {
                                        //     _controller.complete(controller);
                                        //   },
                                        // ),
                                        GoogleMap(
                                      markers: _markers,
                                      initialCameraPosition: CameraPosition(
                                          target: _initialcameraposition,
                                          zoom: 15),
                                      mapType: MapType.normal,
                                      onMapCreated: _onMapCreated,
                                      zoomControlsEnabled: false,
                                      // myLocationEnabled: true, // untuk menampilkan titik biru bawaan google map
                                    ),
                                  )
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ClipOval(
                                      child: Image.asset(
                                          "images/Menu_Task/List_Task/Frame.png")),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: Text(
                                          namePlace,
                                          style: TextStyle(
                                              fontFamily: "roboto",
                                              fontSize: 16,
                                              color: SystemParam.colorCustom,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(height: Reuseable.jarak1),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: Text(addressPlace,
                                            style: TextStyle(
                                              fontFamily: "roboto",
                                            )),
                                      ),
                                      SizedBox(height: Reuseable.jarak1),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time),
                                          SizedBox(
                                            width: Reuseable.jarak1,
                                          ),
                                          Text(' $now ${dateTime.timeZoneName}',
                                              style: TextStyle(
                                                  fontFamily: 'roboto',
                                                  fontSize: 18))
                                        ],
                                      ),
                                      // Text("${dateTime.timeZoneName}"),
                                      // Text("${dateTime.timeZoneOffset}")
                                    ],
                                  ),
                                ],
                              ),
                              Divider(
                                color: SystemParam.colorDivider,
                              ),
                              SizedBox(height: Reuseable.jarak2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  jamKerja(
                                      "Jam Mulai Kerja", widget.jamMulaiKerja),
                                  jamKerja("Jam Selesai Kerja",
                                      widget.jamSelesaiKerja)
                                ],
                              ),
                              SizedBox(height: Reuseable.jarak3),
                              IconButton(
                                iconSize: 100,
                                onPressed: () async {
                                  print(login_via);
                                  print(validationFaceType);
                                  print(widget.type);
                                  print(widget.role);
                                  // timer!.cancel();
                                  if (login_via == 'fingerprint' ||
                                      login_via == 'manual') {
                                    Navigator.pushNamed(context, takePicture,
                                        arguments: {
                                          "type": widget.type,
                                          "user": widget.user,
                                          "camera": cameraDescription,
                                          "locationId": widget.locationId,
                                          "shiftId": widget.shiftId,
                                          "role": widget.role
                                        });
                                  } else {
                                    Warning.showWarning(
                                        "Menggunakan face recognition");
                                    authenticated =
                                        await _localAuthentication.authenticate(
                                      localizedReason: "Please Authenticate",
                                      stickyAuth: true,
                                      biometricOnly: true,
                                    );
                                    print(
                                        "ini hasil dari authenticated <<<<<<<<<<<<========");
                                    print(authenticated);
                                    var splitType = widget.type.split(" ");
                                    var path = splitType.join("-");
                                    if (authenticated) {
                                      // Navigator.pop(context);
                                      var url = path +
                                          "/" +
                                          widget.user.id.toString();
                                      var data = {
                                        "timezone": dateTime.timeZoneName,
                                        "company_id": widget.user.id.toString(),
                                        "locationId": widget.locationId,
                                        "shifId": widget.shiftId
                                      };

                                      var response = await RestService()
                                          .restRequestService(url, data);

                                      var convertDataToJson =
                                          json.decode(response.body);
                                      print(convertDataToJson);
                                      if (convertDataToJson['code'] == '0' &&
                                          convertDataToJson['status'] ==
                                              'Success') {}
                                      // var code = convertDataToJson['code'];
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ResultCICO(
                                                widget.role,
                                                  widget.user,
                                                  widget.type,
                                                  widget.user.fullName,
                                                  null,
                                                  convertDataToJson['data']
                                                      ['clocktime'],
                                                  convertDataToJson['data']
                                                      ['timezone'])));
                                    } else {
                                      Warning.showWarning(
                                          "Authentication Failed");
                                    }
                                  }
                                  //<<<<<<<<======>>>>>>>>>>>>>
                                  // ini untuk logic face recognition
                                  // if (login_via == 'face recognition' &&
                                  //     validationFaceType == 2) {
                                  //   Warning.showWarning('langsung absen');
                                  // } else {
                                  //   Navigator.pushNamed(context, takePicture,
                                  //       arguments: {
                                  //         "type": widget.type,
                                  //         "user": widget.user,
                                  //         "camera": cameraDescription
                                  //       });
                                  // }
                                  // ServiceLocation().getPlacesId(addressPlace);
                                },
                                // isInitialCamera == false
                                //     ? null
                                //     : () async {
                                //         timer!.cancel();
                                //         Navigator.pushNamed(
                                //             context, takePicture,
                                //             arguments: {
                                //               "title": widget.type,
                                //               "type": widget.type,
                                //               "user": userString,
                                //               "camera": cameraDescription
                                //             });
                                //       },
                                icon: Image.asset(
                                  "images/Attandance/Group 90 (1).png",
                                ),
                              ),
                            ],
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  jamKerja(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontFamily: "Roboto", fontSize: 18)),
        SizedBox(height: Reuseable.jarak1),
        Text(value, style: TextStyle(fontFamily: "Roboto", fontSize: 40))
      ],
    );
  }

  getDeviceLocation() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final Uint8List markerIcon =
            await getBytesFromAsset("images/Menu_Task/List_Task/Frame.png", 70);
        mapMarker = BitmapDescriptor.fromBytes(markerIcon);
        _getLocation().then((value) {
          setState(() async {
            print(value.latitude.toString() +
                "lt:lg" +
                value.longitude.toString());
            loading = true;
            userLocation = value;
            // getAddress(userLocation).then((value) => {_currentAddress = value});
            _currentAddress = await getAddress(userLocation);
            print('ini alamat yang di dapat <<<<<=======');
            print(_currentAddress);
            listAlamat = _currentAddress.split(',');
            List listName = listAlamat[0].split(':');
            namePlace = listName[1].substring(1, listName[1].length);
            print('ini name place <<<<<=======');
            print(namePlace);
            List listAddressPlace = listAlamat[1].split(':');
            addressPlace =
                listAddressPlace[1].substring(1, listAddressPlace[1].length);
            print('ini alamat  <<<<<=======');
            print(addressPlace);
            _addressCtr.text = _currentAddress;
            _initialcameraposition = LatLng(value.latitude, value.longitude);
            isInitialCamera = true;
            _latitude = value.latitude.toString();
            _longitude = value.longitude.toString();
            _markers.add(
              Marker(
                  markerId: MarkerId("wrkpln-1"),
                  position: LatLng(value.latitude, value.longitude),
                  icon: mapMarker!),
            );
            loading = false;
          });
        });
      }
    } on SocketException catch (_) {
      Warning.showWarning("No Internet Connection");
      // //print('not connected');
      // db.getDeviceLocation().then((value) {
      //   setState(() {
      //     loading = true;
      //     _currentAddress = value.address;
      //     _addressCtr.text = value.address;
      //     _latitude = value.latitude;
      //     _longitude = value.longitude;
      //     double latitude = double.parse(value.latitude);
      //     double longitude = double.parse(value.longitude);
      //     _initialcameraposition = LatLng(latitude, longitude);
      //     isInitialCamera = true;
      //     loading = false;
      //   });
      // });
    }
  }

  getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
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
    loading = true;
    String address = "";
    List<gc.Placemark> placemark = await gc.placemarkFromCoordinates(
        userLocation.latitude, userLocation.longitude);
    print('ini placemark dari get address <<<<<<======= ');
    print(placemark[0]);

    setState(() {
      try {
        if (placemark[0] != null) {
          String fulladdress = placemark[0].toString();
          _currentAddress = fulladdress;
          _addressCtr.text = fulladdress;
          address = fulladdress;
        }
      } catch (e) {
        address = "";
      }
    });
    return address;
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    // _controllerGmaps = _cntlr;
    _location.onLocationChanged.listen((l) {});
  }

  void startCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    print(cameras);
    cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
  }

  void infoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    login_via = prefs.getString("login_via")!;
    print('ini login nya via = $login_via <<<<<<=======');
    print('ini type validation face nya = ${widget.user.validationFaceType}');
  }
}
