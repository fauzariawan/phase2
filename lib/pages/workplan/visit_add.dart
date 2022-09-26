import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/session_timer.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_visit_list.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

class VisitAdd extends StatefulWidget {
  final WorkplanInboxData workplan;
  // final WorkplanVisit workplanVisit;
  final User user;
  final bool isMaximumUmur;
  final int kunjunganke;
  final dynamic role;

  const VisitAdd(
      {Key? key,
      required this.workplan,
      // required this.workplanVisit,
      required this.user,
      required this.isMaximumUmur,
      required this.kunjunganke,
      required this.role})
      : super(key: key);
  @override
  _VisitAddState createState() => _VisitAddState();
}

class _VisitAddState extends State<VisitAdd> {
  final _keyForm = GlobalKey<FormState>();
  MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);
  var _visitDate;
  int count = 0;
  Timer? timer;
  // SessionTimer sessionTimer = new SessionTimer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   int? limit = widget.user.timeoutLogin * 60;
    //   // print('ini limit time logout nhya');
    //   // print(limit);
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
    // SessionTimer().startTimer(widget.user.timeoutLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
      },
      child: WillPopScope(
          onWillPop: () async {
            //  Navigator.pop(context);
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
                title: Text('Visit Activity'),
                centerTitle: true,
                backgroundColor: colorCustom,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  //onPressed: () => Navigator.of(context).pop(),
                  onPressed: () {
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
                  },
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: _keyForm,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            children: <Widget>[
                              Card(
                                color: Colors.white,
                                elevation: 0.1,
                                child: ListTile(
                                  leading: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0.0, top: 8.0),
                                    child: Image.asset(
                                      "images/Menu_Task/List_Task/Icon_List_Task2.png",
                                    ),
                                  ),
                                  title: Text(widget.workplan.nomorWorkplan,
                                      style: TextStyle(fontSize: 12)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.workplan.fullName,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
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
                                          badgeColor: colorCustom,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          badgeContent: Text(
                                              widget.workplan
                                                  .progresStatusDescription,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white)),
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
                                      horizontal: 20, vertical: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Divider(
                                        color: SystemParam.colorDivider,
                                      ),
                                      Text(
                                          "Recana Kunjungan ke-${widget.kunjunganke}",
                                          style: TextStyle(
                                              color: SystemParam.colorCustom)),
                                      SizedBox(height: Reuseable.jarak1),
                                      DateTimeField(
                                        validator: (value) {
                                          if (value == null) {
                                            return "this field is required";
                                          }
                                          return null;
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        enabled: true,
                                        format: SystemParam.formatDateDisplay,
                                        // initialValue: widget.workplan.rencanaKunjungan!,

                                        onShowPicker:
                                            (context, currentValue) async {
                                          if (currentValue != null) {
                                            // DateFormat dateFormat = new DateFormat();
                                            String date = SystemParam
                                                .formatDateDisplay
                                                .format(currentValue);
                                            // currentValue = currentValue;

                                            currentValue = SystemParam
                                                .formatDateDisplay
                                                .parse(date);
                                          }
                                          final date = await showDatePicker(

                                              // initialDatePickerMode:Datepickermode
                                              // initialEntryMode: DatePickerEntryMode.calendar,
                                              // errorFormatText: DatePickerDateOrder.dmy,
                                              // confirmText: DatePickerDateOrder.dmy,
                                              // errorInvalidText: DatePickerDateOrder.dmy,
                                              // textDirection: ,
                                              //locale: const Locale(''),
                                              // helpText: ,
                                              // initialEntryMode: EntryMode,
                                              // routeSettings: ,
                                              context: context,
                                              locale: Locale('id'),
                                              firstDate: DateTime.now(),
                                                  // DateTime(SystemParam.yearNow),
                                              initialDate: currentValue ??
                                                  DateTime.now(),
                                              // initialDate:  currentValue!,
                                              // initialDate: widget.workplanVisit.visitDatePlan!,
                                              lastDate: DateTime(
                                                  SystemParam.lastDate),
                                              fieldHintText: SystemParam
                                                  .strFormatDateHint);

                                          return date;
                                        },
                                        onSaved: (valueDate) {
                                          setState(() {
                                            _visitDate = SystemParam
                                                .formatDateValue
                                                .format(valueDate!);
                                          });
                                        },
                                        onChanged: (valueDate) {
                                          setState(() {
                                            _visitDate = SystemParam
                                                .formatDateValue
                                                .format(valueDate!);
                                          });
                                        },
                                        decoration:
                                            Reuseable.inputDecorationDate,
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(8.0),
                                      //   child: DateTimeField(
                                      //     validator: (value) {
                                      //       if (value == null) {
                                      //         return "this field is required";
                                      //       }
                                      //       return null;
                                      //     },
                                      //     autovalidateMode:
                                      //         AutovalidateMode.onUserInteraction,
                                      //     enabled: true,
                                      //     format: SystemParam.formatDateDisplay,
                                      //     // initialValue: widget.workplan.rencanaKunjungan!,

                                      //     onShowPicker:
                                      //         (context, currentValue) async {
                                      //       if (currentValue != null) {
                                      //         // DateFormat dateFormat = new DateFormat();
                                      //         String date = SystemParam
                                      //             .formatDateDisplay
                                      //             .format(currentValue);
                                      //         // currentValue = currentValue;

                                      //         currentValue = SystemParam
                                      //             .formatDateDisplay
                                      //             .parse(date);
                                      //       }
                                      //       final date = await showDatePicker(

                                      //           // initialDatePickerMode:Datepickermode
                                      //           // initialEntryMode: DatePickerEntryMode.calendar,
                                      //           // errorFormatText: DatePickerDateOrder.dmy,
                                      //           // confirmText: DatePickerDateOrder.dmy,
                                      //           // errorInvalidText: DatePickerDateOrder.dmy,
                                      //           // textDirection: ,
                                      //           //locale: const Locale(''),
                                      //           // helpText: ,
                                      //           // initialEntryMode: EntryMode,
                                      //           // routeSettings: ,
                                      //           context: context,
                                      //           locale: Locale('id'),
                                      //           firstDate:
                                      //               DateTime(SystemParam.yearNow),
                                      //           initialDate: currentValue ??
                                      //               DateTime.now(),
                                      //           // initialDate:  currentValue!,
                                      //           // initialDate: widget.workplanVisit.visitDatePlan!,
                                      //           lastDate: DateTime(
                                      //               SystemParam.lastDate),
                                      //           fieldHintText: SystemParam
                                      //               .strFormatDateHint);

                                      //       return date;
                                      //     },
                                      //     onSaved: (valueDate) {
                                      //       _visitDate = SystemParam
                                      //           .formatDateValue
                                      //           .format(valueDate!);
                                      //     },
                                      //     onChanged: (valueDate) {
                                      //       _visitDate = SystemParam
                                      //           .formatDateValue
                                      //           .format(valueDate!);
                                      //     },
                                      //     decoration: InputDecoration(
                                      //       icon: new Icon(Icons.date_range),
                                      //       filled: true,
                                      //       fillColor: SystemParam.colorbackgroud,
                                      //       enabledBorder: OutlineInputBorder(
                                      //           borderSide: BorderSide(
                                      //               color: SystemParam
                                      //                   .colorbackgroud),
                                      //           borderRadius: BorderRadius.all(
                                      //               Radius.circular(10))),
                                      //       focusedBorder: OutlineInputBorder(
                                      //           borderSide: BorderSide(
                                      //               color: SystemParam
                                      //                   .colorbackgroud),
                                      //           borderRadius: BorderRadius.all(
                                      //               Radius.circular(10))),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    child: Text("SAVE"),
                                    style: ElevatedButton.styleFrom(
                                      primary: _visitDate == null
                                          ? Colors.grey
                                          : colorCustom,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    // onPressed: () {
                                    //   print(_visitDate);
                                    // },
                                    onPressed: _visitDate == null
                                        ? null
                                        : () {
                                            print(_visitDate);
                                            // //sessionTimer.userActivityDetected(context, widget.user);
                                            if (_keyForm.currentState!
                                                .validate()) {
                                              saveData();
                                            }
                                            // // Navigator.push(
                                            // //     context,
                                            // //     MaterialPageRoute(
                                            // //       builder: (context) => VisitCheckIn(workplan: widget.workplan, workplanVisit: widget.workplanVisit, user: widget.user),
                                            // //     ));
                                          },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  void saveData() async {
    var data = {
      "visit_date_plan": _visitDate,
      "workplan_activity_id": widget.workplan.id,
      "created_by": widget.user.id
    };

    var response =
        await RestService().restRequestService(SystemParam.fVisitInsert, data);

    print(response.body);
    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];

    if (code == "0") {
      // timer!.cancel();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkplanVisitList(
                role: widget.role,
                user: widget.user,
                workplan: widget.workplan,
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
}
