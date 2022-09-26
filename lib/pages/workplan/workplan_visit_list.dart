import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/session_timer.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/model/workplan_visit_model.dart';
import 'package:workplan_beta_test/pages/workplan/visit_add.dart';
import 'package:workplan_beta_test/pages/workplan/visit_process.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_view.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class WorkplanVisitList extends StatefulWidget {
  final WorkplanInboxData workplan;
  final User user;
  final bool isMaximumUmur;
  final dynamic role;

  const WorkplanVisitList(
      {Key? key,
      required this.workplan,
      required this.user,
      required this.isMaximumUmur,
      required this.role})
      : super(key: key);

  @override
  _WorkplanVisitListState createState() => _WorkplanVisitListState();
}

class _WorkplanVisitListState extends State<WorkplanVisitList> {
  get pageController => null;
  MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);
  // late WorkplanVisitModel workplanVisitModel;
  List<WorkplanVisit> workplanVisitList = <WorkplanVisit>[];
  bool loading = false;
  int counter = 0;
  bool isLastVisitNotFinish = false;
  bool isDoneOrReject = false;
  var db = new DatabaseHelper();
  int count = 0;
  Timer? timer;
  // SessionTimer sessionTimer = new SessionTimer();

  @override
  void initState() {
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

    if (widget.workplan.progresStatusCode == "PS005" ||
        widget.workplan.progresStatusCode == "PS004") {
      isDoneOrReject = true;
    }

    getWorkplanVisitList();
    // getWorkplanVisitListOnline();
    // getWorkplanVisitListDB();
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (PointerDownEvent event) {
          TimerCountDown().activityDetected();
        },
        child: WillPopScope(
            onWillPop: () async {
              //  sessionTimer.userActivityDetected(context, widget.user);
              // timer!.cancel();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkplanView(
                      role: widget.role,
                      user: widget.user,
                      workplan: widget.workplan,
                      isMaximumUmur: widget.isMaximumUmur,
                    ),
                  ));
              return false;
            },
            child: Scaffold(
              //drawer: NavigationDrawerWidget(),
              appBar: AppBar(
                title: Text('List Visit Activity'),
                centerTitle: true,
                backgroundColor: colorCustom,
                automaticallyImplyLeading: false,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  visitAdd();
                  // print("IS LAST VISIT NOT FINISH => $isLastVisitNotFinish");
                  // print("IS DONE OR REJECT => $isDoneOrReject");
                  // print("IS MAXIMUM UMUR => ${widget.isMaximumUmur}");
                  // isLastVisitNotFinish || isDoneOrReject || widget.isMaximumUmur
                  //     ? null
                  //     : visitAdd();
                },
                backgroundColor: Colors.white.withOpacity(0),
                tooltip: 'Add Visit',
                child: Image.asset(
                    "images/Menu_Task/List_Task/Add_List_Task2.png"),
              ),

              body: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
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
                                        widget
                                            .workplan.progresStatusDescription,
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
                      loading == true
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : new Container(
                              child: createListView(),
                            )
                    ],
                  ),
                ),
              ),
            )),
      );

  ListView createListView() {
    int nomor = counter + 1;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: counter,
      itemBuilder: (BuildContext context, int index) {
        nomor--;
        // ignore: unnecessary_null_comparison
        return customListItemTwo(workplanVisitList[index], nomor);
      },
    );
  }

  customListItemTwo(WorkplanVisit dt, int nomor) {
    // print(widget.isMaximumUmur.toString() +
    //     "-" +
    //     isDoneOrReject.toString() +
    //     "-" +
    //     dt.isCheckOut.toString());
    //true-false-0
    return GestureDetector(
      onTap: isDoneOrReject || dt.isCheckOut == "1" || widget.isMaximumUmur
          ? null
          : () {
              // timer!.cancel();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VisitProcess(
                          role: widget.role,
                          workplan: widget.workplan,
                          workplanVisit: dt,
                          user: widget.user,
                          nomor: nomor,
                          isMaximumUmur: widget.isMaximumUmur)));
            },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Divider(
                color: SystemParam.colorDivider,
              ),
              oneLineTextDate(
                  "Rencana Kunjungan Ke " + nomor.toString(), dt.visitDatePlan),
              SizedBox(height: Reuseable.jarak1),
              oneLineTextDate("Actual Kunjungan", dt.visitDateActual),
              SizedBox(height: Reuseable.jarak1),
              // oneLineText("Tujuan", dt.visitPurposeDescription),
              Text(
                "Keterangan 1",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                dt.checkInDesc1 ?? "-",
                style: TextStyle(fontSize: 11),
              ),
              SizedBox(height: Reuseable.jarak1),
              Text(
                "Keterangan 2",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                dt.checkInDesc2 ?? "-",
                style: TextStyle(fontSize: 11),
              ),
              SizedBox(height: Reuseable.jarak1),
              Text(
                "Tujuan",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                // ignore: unnecessary_null_comparison
                dt.visitPurposeDescription == null
                    ? ""
                    : dt.visitPurposeDescription,
                style: TextStyle(fontSize: 11),
              ),
              SizedBox(height: Reuseable.jarak1),
              Text(
                "Hasil",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                // ignore: unnecessary_null_comparison
                dt.visitResultDescription == null
                    ? ""
                    : dt.visitResultDescription,
                style: TextStyle(fontSize: 11),
              ),
              SizedBox(height: Reuseable.jarak1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Catatan Kunjungan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  isDoneOrReject || dt.isCheckOut == "1" || widget.isMaximumUmur
                      ? Container()
                      : Image.asset('images/Menu_Task/List_Task/edit.png'),
                ],
              ),
              Text(
                dt.note ?? "-",
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getWorkplanVisitListDB() async {
    db.getWorkplanVisitList(widget.workplan.id).then((value) {
      setState(() {
        loading = true;
        workplanVisitList = value;
        counter = value.length;

        for (var i = 0; i < counter; i++) {
          if ((workplanVisitList[i].isCheckIn == "1" &&
                  workplanVisitList[i].isCheckOut == "0") ||
              (workplanVisitList[i].isCheckIn == "0" &&
                  workplanVisitList[i].isCheckOut == "0")) {
            isLastVisitNotFinish = true;
          }
        }
        loading = false;
      });
    });
  }

  void getWorkplanVisitListOnline() async {
    var data = {
      "workplan_activity_id": widget.workplan.id,
    };

    print(
      widget.workplan.id,
    );

    var response = await RestService()
        .restRequestService(SystemParam.fWorkplanVisitList, data);
    print('ini data list visit activity<<<<<<<<<<=========');
    print(response.body);

    setState(() {
      WorkplanVisitModel workplanVisitModel =
          workplanVisitModelFromJson(response.body.toString());
      counter = workplanVisitModel.data.length;
      workplanVisitList = workplanVisitModel.data;

      for (var i = 0; i < counter; i++) {
        if ((workplanVisitModel.data[i].isCheckIn == "1" &&
                workplanVisitModel.data[i].isCheckOut == "0") ||
            (workplanVisitModel.data[i].isCheckIn == "0" &&
                workplanVisitModel.data[i].isCheckOut == "0")) {
          isLastVisitNotFinish = true;
        }
      }
      loading = false;
    });
  }

  void getWorkplanVisitList() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        getWorkplanVisitListOnline();
      }
    } on SocketException catch (_) {
      print('not connected');
      getWorkplanVisitListDB();
    }
  }

  visitAdd() async {
    print(widget.role);
    if (widget.role['isAdd'] == 0) {
      Warning.showWarning(SystemParam.addNotAllowed);
      return;
    }
    // onPressed: isLastVisitNotFinish || isDone || widget.isMaximumUmur
    //     ? null
    //     : () => {
    //  sessionTimer.userActivityDetected(context, widget.user);
    if (isLastVisitNotFinish || isDoneOrReject || widget.isMaximumUmur) {
      return;
    } else {
      try {
        final result = await InternetAddress.lookup('example.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // timer!.cancel();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VisitAdd(
                    role: widget.role,
                    workplan: widget.workplan,
                    user: widget.user,
                    isMaximumUmur: widget.isMaximumUmur,
                    kunjunganke: counter + 1),
              ));
        }
      } on SocketException catch (_) {
        print('not connected');
        Fluttertoast.showToast(
            msg: "No Internet Connection",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }
}

oneLineText(String s, String visitPurposeDescription) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        s,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      Text(
        // ignore: unnecessary_null_comparison
        visitPurposeDescription == null ? "" : visitPurposeDescription,
        style: TextStyle(fontSize: 11),
      )
    ],
  );
}

oneLineTextDate(String text, DateTime visitDatePlan) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      Text(
        visitDatePlan == null
            ? ""
            : SystemParam.formatDateDisplay.format(visitDatePlan),
        style: TextStyle(fontSize: 11),
      ),
    ],
  );
}
