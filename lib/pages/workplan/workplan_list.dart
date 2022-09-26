// import 'dart:io';
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
import 'package:workplan_beta_test/pages/workplan/workplan_input.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/bottom_navigation_bar.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

import '../../main_pages/task_menu.dart';
import 'workplan_view.dart';

class WorkplanList extends StatefulWidget {
  final User user;
  final dynamic role;
  const WorkplanList({Key? key, required this.user, required this.role})
      : super(key: key);
  @override
  _WorkplanListState createState() => _WorkplanListState();
}

class _WorkplanListState extends State<WorkplanList> {
  MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);
  get pageController => null;
  // late WorkplanInboxModel wokplanInbox;
  List<WorkplanInboxData> _wiData = <WorkplanInboxData>[];
  bool loading = false;
  int counter = 0;
  var progresStatusId = 1;
  DatabaseHelper db = new DatabaseHelper();
  int count = 0;
  Timer? timer;

  //  SessionTimer sessionTimer = new SessionTimer();

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
    // getWorkplanListOnline();
    // getWorkplanListDB();

    getWorkplanList();
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (PointerDownEvent event) {
          TimerCountDown().activityDetected();
          // count = 0;
        },
        child: WillPopScope(
          onWillPop: () async {
            //sessionTimer.userActivityDetected(context, widget.user);
            // timer!.cancel();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskMenu(user: widget.user),
                ));
            return false;
          },
          child: Scaffold(
              //drawer: NavigationDrawerWidget(),
              appBar: AppBar(
                title: Text('List Task'),
                centerTitle: true,
                backgroundColor: colorCustom,
                automaticallyImplyLeading: false,
                // leading: IconButton(
                //   icon: Icon(Icons.arrow_back, color: Colors.black),
                //   //onPressed: () => Navigator.of(context).pop(),
                //   onPressed: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => TaskMenu(
                //             user: widget.user,
                //           ),
                //         ));
                //   },
                // ),
              ),
              body: SingleChildScrollView(
                child: new Container(
                  child: loading == true
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: createListView(),
                        ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    widget.role['isAdd'] == 0
                        ? Warning.showWarning(SystemParam.addNotAllowed)
                        : addTask();
                  },
                  backgroundColor: Colors.white,
                  tooltip: 'Input Task',
                  child: Image.asset(
                      "images/Menu_Task/List_Task/Add_List_Task2.png")),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniCenterDocked,
              bottomNavigationBar:
                  NavigasiBawah.navigasiBawah(context, widget.user)),
        ),
      );

  ListView createListView() {
    // TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: counter,
      itemBuilder: (BuildContext context, int index) {
        return customListItem(_wiData[index]);
      },
    );
  }

  customListItem(WorkplanInboxData dt) {
    var distribusi = "Input";
    // ignore: unnecessary_null_comparison
    if (dt.distribusiWorkplanId != null) {
      distribusi = "Distribusi";
    }

    // ignore: unnecessary_null_comparison
    var progressStatus =
        dt.progresStatusDescription == null ? "" : dt.progresStatusDescription;

    bool isMaximumUmur = false;
    DateTime dtNow = DateTime.now();

    if (dt.maximumDate != null) {
      if (dt.progresStatusIdAlter == 3) {
        isMaximumUmur = true;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: Image.asset(
                "images/Menu_Task/List_Task/Icon_List_Task2.png",
              ),
            ),
            // Container(
            //   color: Colors.grey[350],
            //   child: Image.asset('images/Menu_Task/List_Task/Icon_List_Task.png')),
            title: Text(
                // ignore: unnecessary_null_comparison
                dt.nomorWorkplan == null ? "" : dt.nomorWorkplan,
                style: TextStyle(
                    fontFamily: "Poppins",
                    color: SystemParam.colorCustom,
                    fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Reuseable.jarak1),
                Text(
                  dt.fullName,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: Reuseable.jarak1),
                Text(
                  dt.activityDescription == null ? "" : dt.activityDescription,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: Reuseable.jarak1),
                Text(
                  distribusi,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Badge(
                  toAnimate: false,
                  shape: BadgeShape.square,
                  badgeColor: SystemParam.colorCustom,
                  borderRadius: BorderRadius.circular(20),
                  badgeContent: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(progressStatus,
                        style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
                Icon(Icons.more_vert)
              ],
            ),
            onTap: () {
              // timer!.cancel();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkplanView(
                        role: widget.role,
                        user: widget.user,
                        workplan: dt,
                        isMaximumUmur: isMaximumUmur),
                  ));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Divider(
              color: SystemParam.colorDivider,
            ),
          )
        ],
      ),
    );
    // GestureDetector(
    //     onTap: () {
    //       //sessionTimer.userActivityDetected(context, widget.user);
    //       Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => WorkplanView(
    //                 user: widget.user,
    //                 workplan: dt,
    //                 isMaximumUmur: isMaximumUmur),
    //           ));
    //     },
    //     child: Card(
    //       child: Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: <Widget>[
    //                 Card(
    //                   color: Colors.white,
    //                   elevation: 0.1,
    //                   child: ListTile(
    //                     // leading: CircleAvatar(
    //                     //   backgroundColor: Colors.white,
    //                     //   child: Icon(Icons.book),
    //                     // ),
    //                     leading: Padding(
    //                       padding: const EdgeInsets.only(left: 0.0, top: 8.0),
    //                       child: Icon(
    //                         Icons.card_travel,
    //                         color: colorCustom,
    //                         size: 50,
    //                       ),
    //                     ),
    //                     title: Text(
    //                         // ignore: unnecessary_null_comparison
    //                         dt.nomorWorkplan == null ? "" : dt.nomorWorkplan,
    //                         style: TextStyle(fontSize: 12)),
    //                     subtitle: Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Text(
    //                           dt.fullName,
    //                           style: TextStyle(
    //                               fontSize: 11, fontWeight: FontWeight.bold),
    //                         ),
    //                         Padding(
    //                           padding: const EdgeInsets.only(top: 8.0),
    //                           child: Text(
    //                             dt.activityDescription == null
    //                                 ? ""
    //                                 : dt.activityDescription,
    //                             style: TextStyle(
    //                                 fontSize: 11, fontWeight: FontWeight.bold),
    //                           ),
    //                         ),
    //                         Padding(
    //                           padding: const EdgeInsets.only(top: 8.0),
    //                           child: Text(
    //                             distribusi,
    //                             style: TextStyle(
    //                                 fontSize: 11, fontWeight: FontWeight.bold),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     // trailing: GestureDetector(
    //                     //   child: Icon(Icons.more_vert),
    //                     // ),
    //                     trailing: Row(
    //                       mainAxisSize: MainAxisSize.min,
    //                       children: [
    //                         Padding(
    //                           padding: const EdgeInsets.all(8.0),
    //                           child: Badge(
    //                             toAnimate: false,
    //                             shape: BadgeShape.square,
    //                             badgeColor: colorCustom,
    //                             borderRadius: BorderRadius.circular(8),
    //                             badgeContent: Text(progressStatus,
    //                                 style: TextStyle(
    //                                     fontSize: 14, color: Colors.white)),
    //                           ),
    //                         ),
    //                         Icon(Icons.more_vert)
    //                       ],
    //                     ),
    //                     onTap: () {},
    //                   ),
    //                 ),
    //                 Padding(
    //                   padding: const EdgeInsets.only(left: 15.0, top: 0),
    //                   child: new Container(
    //                     height: 1,
    //                     color: Colors.grey,
    //                   ),
    //                 ),
    //                 Padding(
    //                   padding: const EdgeInsets.only(left: 15.0, top: 8.0),
    //                   child: Text(
    //                     "Rencana Kunjungan 1",
    //                     style: TextStyle(
    //                         fontSize: 14, fontWeight: FontWeight.bold),
    //                   ),
    //                 ),
    //                 Padding(
    //                   padding: const EdgeInsets.only(left: 15.0, top: 0),
    //                   child: dt.rencanaKunjungan == null
    //                       ? null
    //                       : Text(
    //                           SystemParam.formatDateDisplay
    //                               .format(dt.rencanaKunjungan),
    //                           style: TextStyle(fontSize: 11),
    //                         ),
    //                 ),
    //                 Padding(
    //                   padding: const EdgeInsets.only(left: 15.0, top: 8.0),
    //                   child: Text(
    //                     "No. HP",
    //                     style: TextStyle(
    //                         fontSize: 14, fontWeight: FontWeight.bold),
    //                   ),
    //                 ),
    //                 Padding(
    //                   padding: const EdgeInsets.only(left: 15.0, top: 0),
    //                   child: Text(
    //                     dt.phone,
    //                     style: TextStyle(fontSize: 11),
    //                   ),
    //                 ),
    //               ])),
    //     ));
  }

  void getWorkplanListDB() async {
    loading = true;
    Future<List<WorkplanInboxData>> wiDF = db.getWorkplanActivityList();
    wiDF.then((value) {
      setState(() {
        _wiData = value;
        counter = value.length;
      });
    });

    loading = false;
  }

  void getWorkplanListOnline() async {
    var data = {
      "user_id": widget.user.id,
      "progres_status_id": progresStatusId,
      "company_id": widget.user.userCompanyId
    };

    var response = await RestService()
        .restRequestService(SystemParam.fWorkplanListByUserCompanyId, data);
    // var response =await RestService().restRequestService(SystemParam.fWorkplanListByUserCompanyIdNew, data);

    setState(() {
      // print("response.body.toString():" + response.body.toString());
      WorkplanInboxModel wokplanInboxModel =
          workplanInboxFromJson(response.body.toString());
      _wiData = wokplanInboxModel.data;
      counter = wokplanInboxModel.data.length;
      loading = false;
    });
  }

  getWorkplanList() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        getWorkplanListOnline();
      }
    } on SocketException catch (_) {
      print('not connected');
      getWorkplanListDB();
    }
  }

  addTask() async {
    print('sudah di clik tambah task');
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //sessionTimer.userActivityDetected(context, widget.user);
        // timer!.cancel();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkplanInput(user: widget.user, role: widget.role),
            ));
      }
    } on SocketException catch (_) {
      Warning.showWarning("No Internet Connection");
    }
  }
}
