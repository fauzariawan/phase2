import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
// import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/viewGpsTracking.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:textfield_search/textfield_search.dart'; // can use Tagging
import 'package:http/http.dart' as http;
import 'package:workplan_beta_test/widget/warning.dart';

class ChooseUserToTrack extends StatefulWidget {
  final User user;

  const ChooseUserToTrack({Key? key, required this.user}) : super(key: key);

  @override
  State<ChooseUserToTrack> createState() => _ChooseUserToTrackState();
}

class _ChooseUserToTrackState extends State<ChooseUserToTrack> {
  TextEditingController name = TextEditingController();
  TextEditingController taskNumberFrom = TextEditingController();
  TextEditingController taskNumberUntil = TextEditingController();
  TextEditingController tes = TextEditingController();
  // TextEditingController taskDate = TextEditingController();
  String taskDate = "";
  DateTime now = DateTime.now();
  String initialValueDate = "Task Date";
  List _listEmployee = <dynamic>[];
  var tanggalTask = "";

  @override
  void initState() {
    taskDate = now.toString().substring(0, 10);
    getEmployeeList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('GPS Tracking'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
            // height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text('GPS Tracking',
                    style: TextStyle(
                        fontFamily: "poppins",
                        color: SystemParam.colorCustom,
                        fontSize: 20)),
                SizedBox(
                  height: 25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Employee Name'),
                    SizedBox(height: Reuseable.jarak1),
                    TextFieldSearch(
                      label: 'Employee Name',
                      controller: name,
                      future: () {
                        return fetchSimpleData();
                      },
                      decoration: Reuseable.inputDecorationSearch(""),
                    ),

                    // TextFieldSearch(
                    //     label: 'Employee Name',
                    //     controller: name,
                    //     future: () {
                    //       // return fetchListName();
                    //     },
                    //     getSelectedValue: (item) {
                    //       print(item);
                    //     },
                    //     minStringLength: 2,
                    //     // textStyle: TextStyle(color: Colors.red),
                    //     decoration: Reuseable.inputDecorationSearch("Employee Name")
                    //     // InputDecoration(
                    //     //   suffixIcon: Icon(Icons.search),

                    //     //   hintText: 'Employee Name'),
                    //     ),
                    SizedBox(
                      height: Reuseable.jarak2,
                    ),
                    Text('Date Task'),
                    SizedBox(height: Reuseable.jarak1),
                    DateTimeField(
                        validator: (value) {
                          if (value == null) {
                            return "this field is required";
                          }
                          return null;
                        },
                        onSaved: (valueDate) {
                          taskDate =
                              SystemParam.formatDateValue.format(valueDate!);
                        },
                        onChanged: (valueDate) {
                          taskDate =
                              SystemParam.formatDateValue.format(valueDate!);
                        },
                        format: SystemParam.formatDateDisplay,
                        onShowPicker: (context, currentValue) {
                          return showDatePicker(
                              context: context,
                              locale: Locale('id'),
                              firstDate: now.subtract(Duration(days: 360)),
                              initialDate: currentValue ?? DateTime.now(),
                              lastDate: now,
                              fieldHintText: SystemParam.strFormatDateHint);
                        },
                        decoration: Reuseable.inputDecorationDate),
                    // DateTimeField(
                    //     // initialValue: now, //hours: 3, minutes: 43, seconds: 56
                    //     // enabled: enabled,
                    //     autovalidateMode: AutovalidateMode.onUserInteraction,
                    //     onSaved: (valueDate) {
                    //       taskDate =
                    //           SystemParam.formatDateValue.format(valueDate!);
                    //     },
                    //     onChanged: (valueDate) {
                    //       taskDate =
                    //           SystemParam.formatDateValue.format(valueDate!);
                    //     },
                    //     format: SystemParam.formatDateDisplay,
                    //     onShowPicker: (context, currentValue) {
                    //       return showDatePicker(
                    //           context: context,
                    //           locale: Locale('id'),
                    //           firstDate: now.subtract(Duration(days: 360)),
                    //           initialDate: currentValue ?? DateTime.now(),
                    //           lastDate: now,
                    //           fieldHintText: SystemParam.strFormatDateHint);
                    //     },
                    //     style: TextStyle(color: Colors.grey),
                    //     decoration:
                    //         Reuseable.inputDecorationDateDynamic("Task Date")),

                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     minimumSize: Size.fromHeight(40),
                    //     primary: SystemParam.colorbackgroud,
                    //     alignment: Alignment.centerLeft
                    //   ),
                    //   child: FittedBox(
                    //     child: Text('Task Date', textAlign: TextAlign.left, style: TextStyle(color: Colors.grey, fontSize: 16),)
                    //   ),
                    //   onPressed: (){},
                    // ),
                    // TextFieldSearch(
                    //   label: 'Task Date',
                    //   controller: taskDate,
                    //   future: () {
                    //     return fetchListName();
                    //   },
                    //   getSelectedValue: (item) {
                    //     print(item);
                    //   },
                    //   minStringLength: 5,
                    //   // textStyle: TextStyle(color: Colors.red),
                    //   decoration: Reuseable.inputDecorationSearch("Task Date")
                    //   // InputDecoration(
                    //   //   suffixIcon: Icon(Icons.search),

                    //   //   hintText: 'Employee Name'),
                    // ),
                    SizedBox(
                      height: Reuseable.jarak2,
                    ),
                    // Builder(
                    //   builder: (context) {
                    //     return InputHistoryTextField(
                    //       // inputHistoryController: tes,
                    //       textEditingController: tes,
                    //       historyKey: "01",
                    //       // listStyle: ListStyle.Badge,
                    //       // lockBackgroundColor: Colors.brown.withAlpha(90),
                    //       lockTextColor: Colors.black,
                    //       lockItems: ['Semua'],
                    //       showHistoryIcon: false,
                    //       deleteIconColor: Colors.white,
                    //       textColor: Colors.white,
                    //       // backgroundColor: Colors.pinkAccent,
                    //       onEditingComplete: () {
                    //         print(tes.text);
                    //       },
                    //     );
                    //   }
                    // ),
                    // SizedBox(
                    //   height: Reuseable.jarak2,
                    // ),
                    // Text('Task Number Range Start From'),
                    // SizedBox(height: Reuseable.jarak1),
                    // TextFieldSearch(
                    //     label: 'Task Number Range Start From',
                    //     controller: taskNumberFrom,
                    //     future: () {
                    //       // return fetchListName();
                    //     },
                    //     getSelectedValue: (item) {
                    //       print(item);
                    //     },
                    //     minStringLength: 5,
                    //     // textStyle: TextStyle(color: Colors.red),
                    //     decoration: Reuseable.inputDecorationSearch("")
                    //     // InputDecoration(
                    //     //   suffixIcon: Icon(Icons.search),

                    //     //   hintText: 'Employee Name'),
                    //     ),
                    // SizedBox(
                    //   height: Reuseable.jarak2,
                    // ),
                    // Text('Task Number Range Until'),
                    // SizedBox(height: Reuseable.jarak1),
                    // TextFormField(
                    //   controller: taskNumberUntil,
                    //   decoration: Reuseable.inputDecoration,
                    // )
                    // TextFieldSearch(
                    //     label: 'Task Number Range Until',
                    //     controller: taskNumberUntil,
                    //     future: () {
                    //       // return fetchListName();
                    //     },
                    //     getSelectedValue: (item) {
                    //       print(item);
                    //     },
                    //     // minStringLength: 5,
                    //     // textStyle: TextStyle(color: Colors.red),
                    //     decoration: Reuseable.inputDecorationSearch("")
                    //     // InputDecoration(
                    //     //   suffixIcon: Icon(Icons.search),

                    //     //   hintText: 'Employee Name'),
                    //     ),
                  ],
                ),
                SizedBox(
                  height: Reuseable.jarak3,
                ),
                SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                        onPressed: () {
                          visitTracking();
                        },
                        child: Text("Search")))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List> fetchSimpleData() async {
    // await Future.delayed(Duration(milliseconds: 2000));

    Uri url = Uri.parse(
        "https://workplan-phase2-be.aplikasidev.com/api/employee?company_id=${widget.user.userCompanyId}&name=${name.text}");
    List _list = <dynamic>[];
    try {
      var response = await http.get(url);
      var responseJson = jsonDecode(response.body);
      var data = responseJson['data'];
      print(data);
      _listEmployee = data;
      for (var i = 0; i < data.length; i++) {
        _list.add(data[i]['full_name']);
      }
      return _list;
    } catch (e) {
      print('error konneksi http');
      print(e);
      Warning.showWarning('No Internet Connection');
      return _list;
    }
    // create a list from the text input of three items
    // to mock a list of items from an http call
    // _list.add('Fauza');
    // _list.add('Riawan');
    // _list.add('Dastan');
    // return _list;
  }

  visitTracking() async {
    Warning.loading(context);
    print(taskNumberFrom);
    print(taskNumberUntil);
    int id = getId();
    print(id);
    Uri url = Uri.parse(
        "https://workplan-phase2-be.aplikasidev.com/api/visit-tracking?user_id=$id&company_id=${widget.user.userCompanyId}&task_date=$taskDate");
    print(url);
    try {
      var response = await http.get(url);
      var responseJson = jsonDecode(response.body);
      if (responseJson['code'] == "0" && responseJson['status'] == "Success") {
        if (responseJson['data'].length == 0) {
          Navigator.pop(context);
          Warning.showWarning("Data Tidak Ditemukan");
          return;
        }
        var data = responseJson['data'];
        List<dynamic> dataLatLng = [];
        for (var item in data) {
          dynamic input = {
            "nama": item['visit_full_name'],
            "latitude": item['check_in_latitude'],
            "longtitude": item['check_in_longitude'],
          };
          dataLatLng.add(input);
        }
        print(dataLatLng);
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewGpsTracking(
                    user: widget.user,
                    data: dataLatLng,
                    employeeName: name.text,
                    taskDate: taskDate)));
      }
    } catch (e) {
      print('error konneksi http');
      print(e);
      Warning.showWarning('No Internet Connection');
      // return _list;
    }
  }

  getId() {
    for (var item in _listEmployee) {
      if (item['full_name'] == name.text) {
        return item['id'];
      }
    }
    return 9999;
  }

  // Future<List> fetchListName() async {
  //   print('ini mau ambil data atas nama :');
  //   print(name.text);
  //   Uri url = Uri.parse(
  //       "https://workplan-phase2-be.aplikasidev.com/api/employee?company_id=${widget.user.userCompanyId}&name=${name.text}");
  //   debugPrint(url.toString());
  // try {
  //   var response = await http.get(url);
  //   var responseJson = jsonDecode(response.body);
  //   var data = responseJson['data'];
  //   List _list = <dynamic>[];
  //   _list.add('fauza riawan');
  //   _list.add('muhammad umar');
  //   // print(data);
  //   // for (var i = 0; i < data.length; i++) {
  //   //   _list.add(data[i]['full_name']);
  //   // }
  //   return _list;
  // } catch (e) {
  //   print('error konneksi http');
  //   print(e);
  //   Warning.showWarning('No Internet Connection');
  //   return employeeList;
  // }

  //   // // create a list from the text input of three items
  //   // // to mock a list of items from an http call
  //   // _list.add('Test' + ' Item 1');
  //   // _list.add('Test' + ' Item 2');
  //   // _list.add('Test' + ' Item 3');
  //   // print(responseJson['data']);
  // }

  void getEmployeeList() async {}
}
