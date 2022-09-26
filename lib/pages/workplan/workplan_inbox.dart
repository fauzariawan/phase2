import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/main_pages/session_timer.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/main_pages/task_menu.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/bottom_navigation_bar.dart';
import 'package:workplan_beta_test/widget/warning.dart';

import 'workplan_receive.dart';

class WorkplanInboxPage extends StatefulWidget {
  final User user;
  final dynamic role;
  const WorkplanInboxPage({Key? key, required this.user, required this.role})
      : super(key: key);

  @override
  _WorkplanInboxPageState createState() => _WorkplanInboxPageState();
}

class _WorkplanInboxPageState extends State<WorkplanInboxPage> {
  MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);
  late List<WorkplanInboxData> widList = <WorkplanInboxData>[];
  bool loading = false;
  int counter = 0;
  var progresStatusId = 0;
  var db = new DatabaseHelper();
  int count = 0;
  Timer? timer;

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

    getWorkplanInbox();
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
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskMenu(
                  user: widget.user,
                ),
              ));
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Inbox Task'),
              centerTitle: true,
              backgroundColor: colorCustom,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  loading == true
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: createListView(),
                        ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {},
              child: ClipOval(
                child: Image.asset('images/Profile_Menu/Tombol_Utama.png'),
              ),
              tooltip: 'Scan QR',
              backgroundColor: Colors.white,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterDocked,
            bottomNavigationBar:
                NavigasiBawah.navigasiBawah(context, widget.user)),
      ),
    );
  }

  ListView createListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widList.length,
      itemBuilder: (BuildContext context, int index) {
        return customListItem(widList[index]);
      },
    );
  }

  Future getWorkplanInboxOnline() async {
    loading = true;
    // var userId = widget.user.id;
    var data = {
      "user_id": widget.user.id,
      "company_id": widget.user.userCompanyId
    };

    var response = await RestService()
        .restRequestService(SystemParam.fWorkplanInboxByUserCompanyId, data);

    setState(() {
      // print("response.body.toString():" + response.body.toString());
      WorkplanInboxModel wi = workplanInboxFromJson(response.body.toString());
      widList = wi.data;
      counter = wi.data.length;
      // // count = ;
      // for (var i = 0; i < wi.data.length; i++) {
      //   // print(wi.data[i].toString());
      //   db.deleteWorkplanActivityById(wi.data[i].id);
      //   db.insertWorkplanActivity(wi.data[i]);
      // }

      loading = false;
    });
  }

  customListItem(WorkplanInboxData dt) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      //elevation: 2.0,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration:
              BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
          child: Image.asset(
            "images/Menu_Task/List_Task/Businessman.png",
          ),
        ),
        title: Text(
          dt.fullName,
          style: TextStyle(fontSize: 16),
        ),
        subtitle: Text(dt.activityDescription),
        trailing: Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          print(widget.role['isAdd']);
          // sessionTimer.userActivityDetected(context, widget.user);
          if (widget.role['isAdd'] == 0) {
            Warning.showWarning(SystemParam.addNotAllowed);
            return;
          }
          // timer!.cancel();
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkplanInboxReceive(
                  role: widget.role,
                  workplanInboxData: dt,
                  user: widget.user,
                ),
              ));
        },
      ),
    );
  }

  void getWorkplanInboxDB() async {
    loading = true;
    Future<List<WorkplanInboxData>> wiDF = db.getWorkplanActivityInbox();
    wiDF.then((value) {
      setState(() {
        widList = value;
        counter = value.length;
      });
    });

    loading = false;
  }

  Future<void> getWorkplanInbox() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        getWorkplanInboxOnline();
      }
    } on SocketException catch (_) {
      print('not connected');
      getWorkplanInboxDB();
    }
  }
}
