import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:geocoding/geocoding.dart' as gc;
import 'package:geolocator/geolocator.dart' as gl;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart' as lp;
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/helper/utility_image.dart';
import 'package:workplan_beta_test/main_pages/session_timer.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/visit_checkin_log_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/model/workplan_visit_model.dart';
import 'package:workplan_beta_test/pages/workplan/visit_process.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data.dart';
// import 'package:workplan_beta_test/pages/workplan/visit_checkout.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_view.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

import 'visit_checkin_take_picture.dart';

class VisitCheckIn extends StatefulWidget {
  final WorkplanInboxData workplan;
  final WorkplanVisit workplanVisit;
  final User user;
  final String lblCheckInOut;
  final bool isMaximumUmur;
  final int nomor;
  final bool isPhotoFromCam;
                  final dynamic role;


  const VisitCheckIn(
      {Key? key,
      required this.workplan,
      required this.workplanVisit,
      required this.user,
      required this.lblCheckInOut,
      required this.isMaximumUmur,
      required this.nomor,
      required this.isPhotoFromCam, required this.role})
      : super(key: key);
  @override
  _VisitCheckInState createState() => _VisitCheckInState();
}

class _VisitCheckInState extends State<VisitCheckIn> {
  final _keyForm = GlobalKey<FormState>();
  MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);
  bool loading = false;
  late gl.Position userLocation;
  late String _currentAddress = "";
  TextEditingController _addressCtr = new TextEditingController();
  TextEditingController checkOutCtr = new TextEditingController();
//  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  late LatLng _initialcameraposition = LatLng(-6.2293867, 106.6894316);
  bool isInitialCamera = false;
  Location _location = Location();
  // late GoogleMapController _controllerGmaps;
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
  DateTime now = DateTime.now();
  //  SessionTimer sessionTimer = new SessionTimer();
  // late LatLng _initialcameraposition;

  // bool isPhotoFromCam = false;
  // WorkplanInboxData _workplan;

  Uint8List? markerIcon;
  Marker? marker;
  int count = 0;
  Timer? timer;
  Set<Marker> _markers = {};
  BitmapDescriptor? mapMarker;
  bool isProdukEkist = false;
  int parameterTujuanKunjunganValue = SystemParam.defaultValueOptionId;
  List<DropdownMenuItem<int>> itemsParameterTujuanKunjungan =
      <DropdownMenuItem<int>>[];

  int parameterHasilKunjunganValue = SystemParam.defaultValueOptionId;
  List<DropdownMenuItem<int>> itemsParameterHasilKunjungan =
      <DropdownMenuItem<int>>[];
  TextEditingController _catatanKunjunganCtrl = new TextEditingController();

  final requiredValidator =
      RequiredValidator(errorText: 'this field is required');

  TextEditingController ket1 = TextEditingController();
  TextEditingController ket2 = TextEditingController();

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

    getDeviceLocation();
    _wid = widget.workplan;
    _widVisit = widget.workplanVisit;
    getWorkplanById();

    setState(() {
      if (_widVisit.photoCheckIn != null && widget.isPhotoFromCam) {
        isPhotoCheckIn = true;
        loadImageFromPreferences(_widVisit.photoCheckIn);
        photoCheckIn = _widVisit.photoCheckIn;
      } else {
        photoCheckIn = "";
      }

      // if (_wid.jenisProdukId != null) {
      //   isProdukEkist = true;
      // }

      time = SystemParam.formatTime.format(DateTime.now());
    });

    // getMapDot();
    //print("isPhotoCheckIn:" + isPhotoCheckIn.toString());
  }

  @override
  Widget build(BuildContext context) {
    //final photos = <File>[];

    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
        // count = 0;
      },
      child: WillPopScope(
          onWillPop: () async {
            // timer!.cancel();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VisitProcess(
                    role: widget.role,
                    workplan: widget.workplan,
                    user: widget.user,
                    isMaximumUmur: widget.isMaximumUmur,
                    nomor: widget.nomor,
                    workplanVisit: widget.workplanVisit,
                  ),
                ));
            return false;
          },
          child: Scaffold(
              appBar: AppBar(
                title: Text(widget.lblCheckInOut),
                centerTitle: true,
                backgroundColor: colorCustom,
                automaticallyImplyLeading: false,
              ),
              body: loading == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Form(
                      key: _keyForm,
                      child: SingleChildScrollView(
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
                                          width:
                                              500, // or use fixed size like 200
                                          height: 300,
                                          child: GoogleMap(
                                            markers: _markers,
                                            initialCameraPosition:
                                                CameraPosition(
                                                    target:
                                                        _initialcameraposition,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: widget.lblCheckInOut +
                                                    ' Time: ',
                                                style: TextStyle(
                                                    backgroundColor: Theme.of(
                                                            context)
                                                        .scaffoldBackgroundColor,
                                                    color: colorCustom,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                            TextSpan(
                                                text: '$time ${now.timeZoneName}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    backgroundColor: Theme.of(
                                                            context)
                                                        .scaffoldBackgroundColor,
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: SystemParam.colorDivider,
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Alamat",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: SystemParam.colorCustom),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _addressCtr,
                                          keyboardType: TextInputType.multiline,
                                          minLines:
                                              10, //Normal textInputField will be displayed
                                          maxLines: 20,
                                          style: new TextStyle(
                                              color: Colors.black,
                                              fontSize: 11),
                                          // initialValue:_currentAddress,
                                          readOnly: true,
                                          enabled: true,
                                          decoration: InputDecoration(
                                            //con: new Icon(Ionicons.document_outline),
                                            fillColor: colorCustom,
                                            //labelText: "Alamat Check In",
                                            labelStyle: TextStyle(
                                                color: colorCustom,
                                                fontStyle: FontStyle.italic),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: colorCustom
                                                        .withOpacity(0)),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: colorCustom
                                                        .withOpacity(0)),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            contentPadding: EdgeInsets.all(0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: Reuseable.jarak2),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Live Photo",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: SystemParam.colorCustom),
                                        ),
                                      ),
                                      if (!isPhotoCheckIn)
                                        SizedBox(height: Reuseable.jarak2),
                                      if (!isPhotoCheckIn)
                                        Center(
                                          child: Container(
                                            child: Text(
                                                "silakan ambil photo lokasi"),
                                          ),
                                        ),

                                      SizedBox(height: Reuseable.jarak3),
                                      !isPhotoCheckIn
                                          ? GestureDetector(
                                              onTap: () {
                                                //  sessionTimer.userActivityDetected(context, widget.user);
                                                doCapture(_widVisit);
                                              },
                                              child: Image.asset(
                                                  "images/Menu_Task/List_Task/Camera.png"),
                                            )
                                          : Center(
                                              child: _imageFromPreferences,
                                            ),
                                      // ),
                                      // ignore: unnecessary_null_comparison
                                      // imageFromPreferences==null?Container():
                                      if (isPhotoCheckIn &&
                                          widget.lblCheckInOut == 'CHECK IN')
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("Keterangan 1"),
                                            SizedBox(height: 5),
                                            TextFormField(
                                              controller: ket1,
                                              onChanged: (ket1) {
                                                print(ket1);
                                              },
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    SystemParam.colorbackgroud,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: SystemParam
                                                                .colorbackgroud),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: SystemParam
                                                                .colorbackgroud),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("Keterangan 2"),
                                            SizedBox(height: 5),
                                            TextFormField(
                                              controller: ket2,
                                              onChanged: (ket2) {
                                                print(ket2);
                                              },
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    SystemParam.colorbackgroud,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: SystemParam
                                                                .colorbackgroud),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: SystemParam
                                                                .colorbackgroud),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      // if ((isPhotoCheckIn || !isPhotoCheckIn) &&
                                      //     widget.lblCheckInOut == 'CHECK IN')
                                      //   Column(
                                      //     children: [
                                      //       Padding(
                                      //         padding:
                                      //             const EdgeInsets.all(8.0),
                                      //         child: DateTimeField(
                                      //           enabled: false,
                                      //           format: SystemParam
                                      //               .formatDateDisplay,
                                      //           initialValue: widget
                                      //               .workplanVisit
                                      //               .visitDatePlan!,
                                      //           onShowPicker: (context,
                                      //               currentValue) async {
                                      //             final date =
                                      //                 await showDatePicker(
                                      //                     context: context,
                                      //                     firstDate:
                                      //                         DateTime(SystemParam
                                      //                             .firstDate),
                                      //                     initialDate: widget
                                      //                         .workplanVisit
                                      //                         .visitDatePlan!,
                                      //                     lastDate: DateTime(
                                      //                         SystemParam
                                      //                             .lastDate));

                                      //             return date;
                                      //           },
                                      //           decoration: InputDecoration(
                                      //             suffixIcon: new Icon(
                                      //                 Icons.date_range),
                                      //             fillColor:
                                      //                 SystemParam.colorCustom,
                                      //             labelText:
                                      //                 "Tanggal Rencana Kunjungan ",
                                      //             labelStyle: TextStyle(
                                      //                 color: SystemParam
                                      //                     .colorCustom,
                                      //                 fontStyle:
                                      //                     FontStyle.italic),
                                      //             enabledBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             focusedBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             contentPadding:
                                      //                 EdgeInsets.all(10),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding:
                                      //             const EdgeInsets.all(8.0),
                                      //         child: DateTimeField(
                                      //           enabled: false,
                                      //           format: SystemParam
                                      //               .formatDateDisplay,
                                      //           initialValue: widget
                                      //               .workplanVisit
                                      //               .visitDateActual!,
                                      //           onShowPicker: (context,
                                      //               currentValue) async {
                                      //             final date =
                                      //                 await showDatePicker(
                                      //                     context: context,
                                      //                     firstDate:
                                      //                         DateTime(SystemParam
                                      //                             .firstDate),
                                      //                     initialDate: widget
                                      //                         .workplanVisit
                                      //                         .visitDateActual!,
                                      //                     lastDate: DateTime(
                                      //                         SystemParam
                                      //                             .lastDate));

                                      //             return date;
                                      //           },
                                      //           decoration: InputDecoration(
                                      //             suffixIcon: new Icon(
                                      //                 Icons.date_range),
                                      //             fillColor:
                                      //                 SystemParam.colorCustom,
                                      //             labelText:
                                      //                 "Tanggal Aktual Kunjungan ",
                                      //             labelStyle: TextStyle(
                                      //                 color: SystemParam
                                      //                     .colorCustom,
                                      //                 fontStyle:
                                      //                     FontStyle.italic),
                                      //             enabledBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             focusedBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             contentPadding:
                                      //                 EdgeInsets.all(10),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding:
                                      //             const EdgeInsets.all(8.0),
                                      //         child: TextFormField(
                                      //           textInputAction:
                                      //               TextInputAction.next,
                                      //           keyboardType:
                                      //               TextInputType.text,
                                      //           style: new TextStyle(
                                      //               color: Colors.black),
                                      //           enabled: false,
                                      //           initialValue: SystemParam
                                      //               .formatTime
                                      //               .format(widget
                                      //                   .workplanVisit.checkIn),
                                      //           decoration: InputDecoration(
                                      //             suffixIcon: new Icon(
                                      //                 Icons.access_time),
                                      //             fillColor: Colors.green,
                                      //             labelText: "Check In Time",
                                      //             labelStyle: TextStyle(
                                      //                 color: Colors.green,
                                      //                 fontStyle:
                                      //                     FontStyle.normal),
                                      //             enabledBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide:
                                      //                         BorderSide(
                                      //                             color: Colors
                                      //                                 .green),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             focusedBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide:
                                      //                         BorderSide(
                                      //                             color: Colors
                                      //                                 .green),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             contentPadding:
                                      //                 EdgeInsets.all(10),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding:
                                      //             const EdgeInsets.all(8.0),
                                      //         child: TextFormField(
                                      //           controller: checkOutCtr,
                                      //           textInputAction:
                                      //               TextInputAction.next,
                                      //           keyboardType:
                                      //               TextInputType.text,
                                      //           style: new TextStyle(
                                      //               color: Colors.black),
                                      //           enabled: false,
                                      //           //initialValue:  SystemParam.formatTime.format(wV.checkOut),
                                      //           decoration: InputDecoration(
                                      //             suffixIcon: new Icon(
                                      //                 Icons.access_time),
                                      //             fillColor: Colors.green,
                                      //             labelText: "Check Out Time",
                                      //             labelStyle: TextStyle(
                                      //                 color: Colors.green,
                                      //                 fontStyle:
                                      //                     FontStyle.normal),
                                      //             enabledBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide:
                                      //                         BorderSide(
                                      //                             color: Colors
                                      //                                 .green),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             focusedBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide:
                                      //                         BorderSide(
                                      //                             color: Colors
                                      //                                 .green),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             contentPadding:
                                      //                 EdgeInsets.all(10),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding: const EdgeInsets.only(
                                      //           left: 8.0,
                                      //         ),
                                      //         child: RichText(
                                      //           text: TextSpan(
                                      //             children: <TextSpan>[
                                      //               TextSpan(
                                      //                   text:
                                      //                       'Tujuan Kunjungan',
                                      //                   style: TextStyle(
                                      //                       //backgroundColor: Theme.of(context)
                                      //                       //                                            .scaffoldBackgroundColor,
                                      //                       color: SystemParam
                                      //                           .colorCustom,
                                      //                       fontWeight:
                                      //                           FontWeight.w400,
                                      //                       fontSize: 14)),
                                      //               TextSpan(
                                      //                   text: '  ',
                                      //                   style: TextStyle(
                                      //                       fontWeight:
                                      //                           FontWeight.w500,
                                      //                       fontSize: 14,
                                      //                       //backgroundColor: Theme.of(context)
                                      //                       //                                            .scaffoldBackgroundColor,
                                      //                       color: Colors.red)),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding:
                                      //             const EdgeInsets.all(8.0),
                                      //         child:
                                      //             DropdownButtonFormField<int>(
                                      //           decoration: InputDecoration(
                                      //             fillColor:
                                      //                 SystemParam.colorCustom,
                                      //             labelStyle: TextStyle(
                                      //                 color: SystemParam
                                      //                     .colorCustom,
                                      //                 fontStyle:
                                      //                     FontStyle.italic),
                                      //             enabledBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             focusedBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             contentPadding:
                                      //                 EdgeInsets.all(10),
                                      //           ),
                                      //           validator: isProdukEkist
                                      //               ? (value) {
                                      //                   // ignore: unrelated_type_equality_checks
                                      //                   if (value == 0) {
                                      //                     return "this field is required";
                                      //                   }
                                      //                   return null;
                                      //                 }
                                      //               : null,
                                      //           value:
                                      //               parameterTujuanKunjunganValue,
                                      //           items:
                                      //               itemsParameterTujuanKunjungan,
                                      //           onChanged: !isProdukEkist
                                      //               ? null
                                      //               : (object) {
                                      //                   setState(() {
                                      //                     parameterTujuanKunjunganValue =
                                      //                         object!;
                                      //                   });
                                      //                 },
                                      //         ),
                                      //         // )),
                                      //       ),
                                      //       Padding(
                                      //         padding: const EdgeInsets.only(
                                      //           left: 8.0,
                                      //         ),
                                      //         child: RichText(
                                      //           text: TextSpan(
                                      //             children: <TextSpan>[
                                      //               TextSpan(
                                      //                   text: 'Hasil Kunjungan',
                                      //                   style: TextStyle(
                                      //                       //backgroundColor: Theme.of(context)
                                      //                       //                                            .scaffoldBackgroundColor,
                                      //                       color: SystemParam
                                      //                           .colorCustom,
                                      //                       fontWeight:
                                      //                           FontWeight.w400,
                                      //                       fontSize: 14)),
                                      //               TextSpan(
                                      //                   text: '  ',
                                      //                   style: TextStyle(
                                      //                       fontWeight:
                                      //                           FontWeight.w500,
                                      //                       fontSize: 14,
                                      //                       //backgroundColor: Theme.of(context)
                                      //                       //                                            .scaffoldBackgroundColor,
                                      //                       color: Colors.red)),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding:
                                      //             const EdgeInsets.all(8.0),
                                      //         child:
                                      //             DropdownButtonFormField<int>(
                                      //           decoration: InputDecoration(
                                      //             fillColor:
                                      //                 SystemParam.colorCustom,
                                      //             labelStyle: TextStyle(
                                      //                 color: SystemParam
                                      //                     .colorCustom,
                                      //                 fontStyle:
                                      //                     FontStyle.italic),
                                      //             enabledBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             focusedBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             contentPadding:
                                      //                 EdgeInsets.all(10),
                                      //           ),
                                      //           validator: isProdukEkist
                                      //               ? (value) {
                                      //                   print(
                                      //                       "validaor select:" +
                                      //                           value
                                      //                               .toString());
                                      //                   // ignore: unrelated_type_equality_checks
                                      //                   if (value == 0) {
                                      //                     return "this field is required";
                                      //                   }
                                      //                   return null;
                                      //                 }
                                      //               : null,
                                      //           value:
                                      //               parameterHasilKunjunganValue,
                                      //           items:
                                      //               itemsParameterHasilKunjungan,
                                      //           onChanged: !isProdukEkist
                                      //               ? null
                                      //               : (object) {
                                      //                   setState(() {
                                      //                     parameterHasilKunjunganValue =
                                      //                         object!;
                                      //                   });
                                      //                 },
                                      //         ),
                                      //         // )),
                                      //       ),
                                      //       Padding(
                                      //         padding: const EdgeInsets.only(
                                      //           left: 8.0,
                                      //         ),
                                      //         child: RichText(
                                      //           text: TextSpan(
                                      //             children: <TextSpan>[
                                      //               TextSpan(
                                      //                   text:
                                      //                       'Catatan Kunjungan',
                                      //                   style: TextStyle(
                                      //                       //backgroundColor: Theme.of(context)
                                      //                       //                                            .scaffoldBackgroundColor,
                                      //                       color: SystemParam
                                      //                           .colorCustom,
                                      //                       fontWeight:
                                      //                           FontWeight.w400,
                                      //                       fontSize: 14)),
                                      //               TextSpan(
                                      //                   text: '  ',
                                      //                   style: TextStyle(
                                      //                       fontWeight:
                                      //                           FontWeight.w500,
                                      //                       fontSize: 14,
                                      //                       //backgroundColor: Theme.of(context)
                                      //                       //                                            .scaffoldBackgroundColor,
                                      //                       color: Colors.red)),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       Padding(
                                      //         padding:
                                      //             const EdgeInsets.all(8.0),
                                      //         child: TextFormField(
                                      //           controller:
                                      //               _catatanKunjunganCtrl,
                                      //           textInputAction:
                                      //               TextInputAction.next,
                                      //           keyboardType:
                                      //               TextInputType.text,
                                      //           style: new TextStyle(
                                      //               color: Colors.blue[900]),
                                      //           readOnly: false,
                                      //           maxLines: 3,
                                      //           //validator: requiredValidator,
                                      //           onSaved: (em) {
                                      //             if (em != null) {}
                                      //           },
                                      //           decoration: InputDecoration(
                                      //             // icon: new Icon(Ionicons.phone_portrait),
                                      //             fillColor: Colors.black,
                                      //             // labelText: "Nomor HP",
                                      //             labelStyle: TextStyle(
                                      //                 color: SystemParam
                                      //                     .colorCustom,
                                      //                 fontStyle:
                                      //                     FontStyle.normal),
                                      //             enabledBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             focusedBorder:
                                      //                 OutlineInputBorder(
                                      //                     borderSide: BorderSide(
                                      //                         color: SystemParam
                                      //                             .colorCustom),
                                      //                     borderRadius:
                                      //                         BorderRadius.all(
                                      //                             Radius
                                      //                                 .circular(
                                      //                                     10))),
                                      //             contentPadding:
                                      //                 EdgeInsets.all(10),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      SizedBox(height: Reuseable.jarak3),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            child: Text("SUBMIT"),
                                            style: ElevatedButton.styleFrom(
                                              primary: colorCustom,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                            onPressed: () {
                                              //prosesSave(empUpd);
                                              //  sessionTimer.userActivityDetected(context, widget.user);
                                              submit();
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ))),
    );
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

  void _onMapCreated(GoogleMapController _cntlr) {
    // _controllerGmaps = _cntlr;
    _location.onLocationChanged.listen((l) {});
  }

  Future<String> getAddress(gl.Position userLocation) async {
    loading = true;
    String address = "";
    List<gc.Placemark> placemark = await gc.placemarkFromCoordinates(
        userLocation.latitude, userLocation.longitude);
    print('ini placemark dari get address <<<<<<======= ');
    print(placemark[1]);
    print(placemark[2]);

    setState(() {
      try {
        // ignore: unnecessary_null_comparison
        if (placemark[0] != null) {
          String fulladdress = placemark[0].toString();
          _currentAddress = fulladdress;
          _addressCtr.text = fulladdress;

          // String name = placemark[0].street != null
          //     ? placemark[0].street.toString()
          //     : "";
          // String subThoroughfare = placemark[0].subThoroughfare != null
          //     ? placemark[0].subThoroughfare.toString()
          //     : "";

          // String thoroughfare = placemark[0].thoroughfare != null
          //     ? placemark[0].thoroughfare.toString()
          //     : "";
          // String subLocality = placemark[0].subLocality != null
          //     ? placemark[0].subLocality.toString()
          //     : "";
          // String locality = placemark[0].locality != null
          //     ? placemark[0].locality.toString()
          //     : "";
          // String administrativeArea = placemark[0].administrativeArea != null
          //     ? placemark[0].administrativeArea.toString()
          //     : "";
          // String postalCode = placemark[0].postalCode != null
          //     ? placemark[0].postalCode.toString()
          //     : "";
          // String country = placemark[0].country != null
          //     ? placemark[0].country.toString()
          //     : "";

          // address = thoroughfare +
          //     ", " +
          //     subThoroughfare +
          //     ", " +
          //     subLocality +
          //     ", " +
          //     locality +
          //     ", " +
          //     administrativeArea +
          //     ", " +
          //     postalCode +
          //     ", " +
          //     country;

          // address = fulladdress;

        }
      } catch (e) {
        address = "";
      }
    });
    return address;
  }

  void submit() async {
    if (photoCheckIn == "") {
      Fluttertoast.showToast(
          msg: "silakan ambil photo lokasi!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        submitOnline();
      }
    } on SocketException catch (_) {
      print('not connected');
      submitOffline();
    }
  }

  void getWorkplanVisitById() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        loading = true;
        var data = {
          "visit_id": widget.workplanVisit.id,
        };

        var response = await RestService()
            .restRequestService(SystemParam.fWorkplanVisitById, data);

        setState(() {
          // print("response.body.toString():" + response.body.toString());
          WorkplanVisitModel workplanVisitModel =
              workplanVisitModelFromJson(response.body.toString());
          WorkplanVisit wV = workplanVisitModel.data[0];

          //INSERT LOG CHECK IN
          var db = new DatabaseHelper();
          VisitChecInLog vcIL = new VisitChecInLog(
              visitId: wV.id,
              checkInBatas: wV.checkInBatas.toString(),
              batasWaktu: wV.batasWaktu,
              checkIn: wV.checkIn.toString(),
              nomorWorkplan: widget.workplan.nomorWorkplan);
          db.insertVisitCheckInLog(vcIL);

          loading = false;
        });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  void doCapture(WorkplanVisit workplanVisit) async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    // timer!.cancel();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisitCheckinTakePicture(
            role: widget.role,
            camera: firstCamera,
            wv: workplanVisit,
            user: widget.user,
            workplan: widget.workplan,
            lblCheckInOut: widget.lblCheckInOut,
            isMaximumUmur: widget.isMaximumUmur,
            nomor: widget.nomor,
          ),
        ));
  }

  loadImageFromPreferences(String photo) {
    // loading = true;
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
        _imageFromPreferences = Utility.imageFromBase64String(img);
        // loading = false;
      });
    });
  }

  downloadImageToPreference(String photo) async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "filename": photo,
        };

        print(data);
        var response = await RestService()
            .restRequestService(SystemParam.fImageDownload, data);

        print("response" + response.toString());
        // ImageProvider imageRes = Image.memory(response.bodyBytes).image;

        setState(() {
          _imageFromPreferences = Image.memory(response.bodyBytes);
        });
      }
    } on SocketException catch (_) {
      //print('not connected');
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
          _wid = wi.data[0];
          loading = false;
        });
      }
    } on SocketException catch (_) {
      //print('not connected');
    }
  }

  void submitOnline() async {
    var data = {
      "id": _widVisit.id,
      "check_in_latitude": _latitude,
      "check_in_longitude": _longitude,
      "address_check_in": _currentAddress,
      "workplan_activity_id": widget.workplan.id,
      "progres_status_id": progressStatusId,
      "label": widget.lblCheckInOut,
      "check_in_desc_1": ket1.text,
      "check_in_desc_2": ket2.text,
      "time": time,
      "timezone": now.timeZoneName
    };

    print(data);

    var response =
        await RestService().restRequestService(SystemParam.fVisitCheckIn, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];

    if (code == "0") {
      getWorkplanVisitById();

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkplanView(
              role: widget.role,
                user: widget.user,
                workplan: _wid,
                isMaximumUmur: widget.isMaximumUmur),
          ));
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

  // void submitOnline() async {
  //   var data = {
  //     "id": _widVisit.id,
  //     // "check_in_latitude": _initialcameraposition.latitude,
  //     // "check_in_longitude": _initialcameraposition.longitude,
  //     "check_in_latitude": _latitude,
  //     "check_in_longitude": _longitude,
  //     "address_check_in": _currentAddress,
  //     // "photo_check_in": "",
  //     "workplan_activity_id": widget.workplan.id,
  //     "progres_status_id": progressStatusId,
  //     "label": widget.lblCheckInOut
  //   };

  //   var response =
  //       await RestService().restRequestService(SystemParam.fVisitCheckIn, data);

  //   var convertDataToJson = json.decode(response.body);
  //   var code = convertDataToJson['code'];
  //   var status = convertDataToJson['status'];

  //   if (code == "0") {
  //     getWorkplanVisitById();

  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => WorkplanView(
  //               user: widget.user,
  //               workplan: _wid,
  //               isMaximumUmur: widget.isMaximumUmur),
  //         ));
  //   } else {
  //     Fluttertoast.showToast(
  //         msg: status,
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //   }
  // }

  void submitOffline() async {
    // "check_in_latitude": _initialcameraposition.latitude,
    //   "check_in_longitude": _initialcameraposition.longitude,
    //   "address_check_in": _currentAddress,
    //   "photo_check_in": "",
    //   "workplan_activity_id": widget.workplan.id,
    //   "progres_status_id": progressStatusId,
    //   "label": widget.lblCheckInOut

    //UPDATE WORKPLAN VISIT
    //String dateVisit = SystemParam.formatDateValue.format(DateTime.now());
    _widVisit.checkInLatitude = _latitude;
    _widVisit.checkInLongitude = _longitude;
    _widVisit.addressCheckIn = _currentAddress;
    _widVisit.isCheckIn = "1";
    _widVisit.visitDateActual = DateTime.now();
    _widVisit.checkIn = DateTime.now();
    _widVisit.flagUpdate = 1;
    _widVisit.updatedBy = widget.user.id;

    // _widVisit.photoCheckIn = "";
    // _widVisit.progressStatusId = progressStatusId;

    db.updateWorkplanVisitCheckIn(_widVisit);

    //UPDATE WORKPLAN
    _wid.isCheckIn = "1";
    _wid.progresStatusIdAlter = 2;
    _wid.progresStatusId = 2;

    db.getParameterProgresStatusById("2").then((value) {
      _wid.progresStatusDescription = value.description;
      _wid.progresStatusIdAlterDescription = value.description;
    });

    db.updateWorkplanActivity(_wid);

    Fluttertoast.showToast(
        msg: "Data tersimpan secara offline",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkplanView(
            role: widget.role,
              user: widget.user,
              workplan: _wid,
              isMaximumUmur: widget.isMaximumUmur),
        ));
  }

  getDeviceLocation() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final Uint8List markerIcon =
            await getBytesFromAsset("images/Menu_Task/List_Task/Frame.png", 70);
        mapMarker = BitmapDescriptor.fromBytes(markerIcon);
        _getLocation().then((value) {
          setState(() {
            print(value.latitude.toString() +
                "lt:lg" +
                value.longitude.toString());
            loading = true;
            userLocation = value;
            getAddress(userLocation).then((value) => {_currentAddress = value});
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
      //print('not connected');
      db.getDeviceLocation().then((value) {
        setState(() {
          loading = true;
          _currentAddress = value.address;
          _addressCtr.text = value.address;
          _latitude = value.latitude;
          _longitude = value.longitude;
          double latitude = double.parse(value.latitude);
          double longitude = double.parse(value.longitude);
          _initialcameraposition = LatLng(latitude, longitude);
          isInitialCamera = true;
          loading = false;
        });
      });
    }
  }

  // void getMapDot() async {
  //   var markerIdVal = "WrkPln";
  //   final MarkerId markerId = MarkerId(markerIdVal);
  //   markerIcon =
  //       await getBytesFromAsset('images/Menu_Task/List_Task/Frame.png', 100);
  //   _markers = Marker(
  //       icon: BitmapDescriptor.fromBytes(markerIcon!), markerId: markerId);
  // }

  getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
