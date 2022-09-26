import 'dart:async';
import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';
import 'package:http/http.dart' as http;
import 'package:art_sweetalert/art_sweetalert.dart';

class AdjustAttendance extends StatefulWidget {
  final User user;
  final dynamic role;
  const AdjustAttendance({Key? key, required this.user, required this.role})
      : super(key: key);

  @override
  State<AdjustAttendance> createState() => _AdjustAttendanceState();
}

class _AdjustAttendanceState extends State<AdjustAttendance> {
  DateTime now = DateTime.now();
  String tanggalClockIn = "";
  dynamic data;
  TextEditingController alasan = new TextEditingController();
  TimeOfDay? timeClockIn;
  TimeOfDay? timeClockOut;
  TimeOfDay timeNow = TimeOfDay.now();
  DateTime? date;
  int count = 0;
  Timer? timer;
  bool isSearching = false;
  bool isDataNotFound = false;
  String? adjustClockIn;
  String? adjustClockOut;

  @override
  void initState() {
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
    super.initState();
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
            title: Text('Request Adjust Attendance'),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal Clock In",
                  ),
                  SizedBox(height: Reuseable.jarak1),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () async {
                        print('masuk sini');
                        final initialDate = DateTime.now();
                        final newDate = await showDatePicker(
                            context: context,
                            initialDate:
                                initialDate.subtract(Duration(days: 1)),
                            firstDate: initialDate.subtract(Duration(days: 14)),
                            lastDate: initialDate.subtract(Duration(days: 1)));
                        if (newDate == null) return;
                        String dateString =
                            SystemParam.formatDateValue.format(newDate);
                        setState(() {
                          date = newDate;
                        });
                        findData(dateString);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [getTextDate(), Icon(Icons.date_range)],
                      ),
                    ),
                  ),
                  // DateTimeField(
                  //   initialValue: now.subtract(
                  //       Duration(days: 1)), //hours: 3, minutes: 43, seconds: 56
                  //   // enabled: enabled,
                  //   autovalidateMode: AutovalidateMode.onUserInteraction,
                  //   onSaved: (valueDate) {
                  //     tanggalClockIn =
                  //         SystemParam.formatDateValue.format(valueDate!);
                  //   },
                  //   onChanged: (valueDate) {
                  //     tanggalClockIn =
                  //         SystemParam.formatDateValue.format(valueDate!);
                  //   },
                  //   format: SystemParam.formatDateDisplay,
                  //   onShowPicker: (context, currentValue) {
                  //     return showDatePicker(
                  //         context: context,
                  //         locale: Locale('id'),
                  //         firstDate: now.subtract(Duration(days: 14)),
                  //         initialDate: currentValue ?? DateTime.now(),
                  //         lastDate: now.subtract(Duration(days: 1)),
                  //         fieldHintText: SystemParam.strFormatDateHint);
                  //   },
                  //   style: TextStyle(color: Colors.grey),
                  //   decoration:
                  //       Reuseable.inputDecorationDateDynamic("Tanggal Clock In"),
                  // ),
                  data == null
                      ? Container()
                      : Column(
                          children: [
                            SizedBox(height: Reuseable.jarak3),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ]),
                              child: Column(
                                children: [
                                  dataRow("Nama Shift", data["shift_name"]),
                                  SizedBox(height: Reuseable.jarak1),
                                  dataRow("Jenis Shift", data["shift_type"]),
                                  SizedBox(height: Reuseable.jarak1),
                                  dataRow("Shift In", data["shift_in_hour"]),
                                  SizedBox(height: Reuseable.jarak1),
                                  dataRow("Shift Out", data["shift_out_hour"]),
                                  SizedBox(height: Reuseable.jarak1),
                                  dataRow(
                                      "Jam Terakhir Toleransi Absence Masuk",
                                      data["shift_in_hour_tolerance"] ?? "-"),
                                  SizedBox(height: Reuseable.jarak3),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      dataClockInClockOut(
                                          data["clock_in_hour"] == ""
                                              ? "-- : --"
                                              : data["clock_in_hour"],
                                          "Clock In",
                                          data["clock_in_date"] == ""
                                              ? "-- : --"
                                              : data["clock_in_date"]),
                                      dataClockInClockOut(
                                          data["clock_out_hour"] == ""
                                              ? "-- : --"
                                              : data["clock_out_hour"],
                                          "Clock Out",
                                          data["clock_out_date"] == ""
                                              ? "-- : --"
                                              : data["clock_out_date"])
                                    ],
                                  ),
                                  SizedBox(height: Reuseable.jarak3),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(children: [
                                          Text("Adjust Clock In"),
                                          ElevatedButton(
                                            onPressed: () =>
                                                pickedTime(context, 'Clock In'),
                                            child: getText('Clock In'),
                                          )
                                        ]),
                                        Column(children: [
                                          Text("Adjust Clock Out"),
                                          ElevatedButton(
                                            onPressed: () => pickedTime(
                                                context, 'Clock Out'),
                                            child: getText('Clock Out'),
                                          )
                                        ])
                                      ]),
                                  SizedBox(height: Reuseable.jarak3),
                                  Text("Alasan Pengajuan Adjusment"),
                                  SizedBox(height: Reuseable.jarak1),
                                  TextFormField(
                                    controller: alasan,
                                    onChanged: (alasan) {
                                      print(alasan);
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: SystemParam.colorbackgroud,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  SystemParam.colorbackgroud),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                                  SystemParam.colorbackgroud),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                    ),
                                  ),
                                  SizedBox(height: Reuseable.jarak3),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (widget.role['isEdit'] == 0) {
                                              Warning.showWarning(
                                                  'Kamu tidak diizinkan untuk melakukan Adjust Attendance');
                                              return;
                                            }
                                            if (adjustClockIn == null) {
                                              Warning.showWarning(
                                                  'Adjust Clock In Harus diisi');
                                              return;
                                            }
                                            if (adjustClockOut == null) {
                                              Warning.showWarning(
                                                  'Adjust Clock Out Harus diisi');
                                              return;
                                            }
                                            if (alasan.text == "") {
                                              Warning.showWarning(
                                                  'Alasan Pengajuan Adjustment Harus diisi');
                                              return;
                                            }
                                            sendRequest();
                                          },
                                          child: Text("Submit")))
                                ],
                              ),
                            ),
                          ],
                        ),
                  if (data == null)
                    if (isSearching == true)
                      Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  if (isDataNotFound == true)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Text('Data Not Found'),
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

  dataRow(String leftSide, String rightSide) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(leftSide), Text(rightSide)],
    );
  }

  dataClockInClockOut(String jam, String title, String tanggal) {
    return Column(
      children: [Text(jam), Text(title), Text(tanggal)],
    );
  }

  Future pickedTime(BuildContext context, String type) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    final newTime =
        await showTimePicker(context: context, initialTime: timeNow);
    if (newTime == null) return;
    setState(() {
      if (type == 'Clock In') {
        timeClockIn = newTime;
      } else {
        timeClockOut = newTime;
      }
    });
  }

  getText(String type) {
    if (type == 'Clock In') {
      if (timeClockIn == null) {
        return Text('Select Time');
      } else {
        final hours = timeClockIn!.hour.toString().padLeft(2, '0');
        final minute = timeClockIn!.minute.toString().padLeft(2, '0');
        adjustClockIn = '$hours:$minute';
        return Text('$hours : $minute');
      }
    } else {
      if (timeClockOut == null) {
        return Text('Select Time');
      } else {
        final hours = timeClockOut!.hour.toString().padLeft(2, '0');
        final minute = timeClockOut!.minute.toString().padLeft(2, '0');
        adjustClockOut = '$hours:$minute';
        return Text('$hours : $minute');
      }
    }
  }

  getTextDate() {
    if (date == null) {
      return Text("Pilih Tanggal");
    } else {
      final day = date!.day.toString().padLeft(2, '0');
      final month = date!.month.toString().padLeft(2, '0');
      return Text("$day / $month / ${date!.year}");
    }
  }

  void findData(String date) async {
    print('find data <<<<<<<<<<<<<<<<<<=========');
    print(widget.user.id);
    print(widget.user.userCompanyId);
    print(date);
    setState(() {
      isSearching = true;
    });
    Uri url = Uri.parse(
        "https://workplan-phase2-be.aplikasidev.com/api/clock-in?user_id=${widget.user.id}&company_id=${widget.user.userCompanyId}&clock_in_date=$date");
    // List _list = <dynamic>[];
    try {
      var response = await http.get(url);
      var responseJson = jsonDecode(response.body);
      print(responseJson);

      if (responseJson['code'] == 1) {
        ArtSweetAlert.show(
            context: context,
            artDialogArgs: ArtDialogArgs(
                type: ArtSweetAlertType.danger,
                confirmButtonColor: SystemParam.colorCustom,
                title: "Oops...",
                text: responseJson['status']));
        setState(() {
          isSearching = false;
          // isDataNotFound = true;
        });
        return;
      }

      if (responseJson['code'] == 0 && responseJson['status'] == "Success") {
        var dataClockIn = responseJson['data'];

        // masukkan data
        setState(() {
          isSearching = false;
          data = dataClockIn;
        });
        return;
      }
    } catch (e) {
      print('error konneksi http');
      print(e);
      setState(() {
        isSearching = false;
      });
      Warning.showWarning('No Internet Connection');
    }
  }

  void sendRequest() async {
    bool hasInternetConnection = await Helper.internetCek();
    if (!hasInternetConnection) {
      Warning.showWarning(SystemParam.noInternet);
    } else {
      var body = {
        "user_id": widget.user.id.toString(),
        "company_id": widget.user.userCompanyId.toString(),
        "shift_id": data['shift_id'].toString(),
        "shift_in_hour": data['shift_in_hour'],
        "shift_out_hour": data["shift_out_hour"],
        "clock_in_date": data["clock_in_date"],
        "clock_in_hour": data["clock_in_hour"],
        "clock_out_hour": data["clock_out_hour"],
        "adjust_clock_in_hour": adjustClockIn,
        "adjust_clock_out_hour": adjustClockOut,
        "timezone": SystemParam.now.timeZoneName,
        "adjust_attendance_note": alasan.text
      };
      print(body);
      var bodySend = jsonEncode(body);
      try {
        var respon = await post(
          Uri.parse(SystemParam.baseUrl + SystemParam.adjustAttendance),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            // "Content-Type": "application/json",
          },
          body: body,
        );
        var result = jsonDecode(respon.body);
        if (result['code'] == 0 && result['status'] == 'Success') {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.success,
                  confirmButtonColor: SystemParam.colorCustom,
                  title: "Information",
                  text: 'Permintaan kamu berhasil di kirim'));
          setState(() {
            isSearching = false;
            data = null;
          });
        } else {
          ArtSweetAlert.show(
              context: context,
              artDialogArgs: ArtDialogArgs(
                  type: ArtSweetAlertType.warning,
                  confirmButtonColor: SystemParam.colorCustom,
                  title: "Information",
                  text: result['status']));
          setState(() {
            isSearching = false;
            data = null;
          });
        }
        print(respon.body);
      } catch (e) {
        print(e);
        return null;
      }
      // var response = await RestService()
      //     .restRequestServicePost(SystemParam.adjustAttendance, bodySend);
      // print(response!.body);
    }
  }
}
