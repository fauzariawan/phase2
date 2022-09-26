import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/model/workplan_messages.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);

class WorkplanDataDecision extends StatefulWidget {
  final WorkplanInboxData workplan;
  final User user;
  final bool isMaximumUmur;
  final dynamic role;

  const WorkplanDataDecision(
      {Key? key,
      required this.workplan,
      required this.user,
      required this.isMaximumUmur, required this.role})
      : super(key: key);

  @override
  _WorkplanDataDecisionState createState() => _WorkplanDataDecisionState();
}

class _WorkplanDataDecisionState extends State<WorkplanDataDecision> {
  final _keyForm = GlobalKey<FormState>();
  bool loading = false;
  int counter = 0;
  // late WorkplanMessagesModel workplanMessages;
  List<WorkplanMessages> wmList = <WorkplanMessages>[];
  TextEditingController _keputusanCtr = new TextEditingController();
  TextEditingController _alasanCtr = new TextEditingController();
  var keputusan = "";
  var db = new DatabaseHelper();
  String alasanDitolak = "";
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
    // getWorkplanMessagesDB();
    getWorkplanMessages();

    if (widget.workplan.keputusan != null) {
      if (widget.workplan.keputusan == "1") {
        keputusan = "Disetujui";
      } else {
        keputusan = "Ditolak";
      }
      _keputusanCtr.text = keputusan;
    }

    // ignore: unnecessary_null_comparison
    if (widget.workplan.alasanTolakDescription != null) {
      alasanDitolak = widget.workplan.alasanTolakDescription;
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
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
                    builder: (context) => WorkplanData(
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
                  title: Text('Keputusan'),
                  centerTitle: true,
                  backgroundColor: colorCustom,
                  automaticallyImplyLeading: false,
                ),
                body: Column(
                  children: [
                    Form(
                      key: _keyForm,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              loading == true
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : wmList.length != 0
                                      ? createListView()
                                      : Center(
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade700,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'No Message',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: "Poppins"),
                                              ),
                                            ),
                                          ),
                                      ),
                              SizedBox(height: Reuseable.jarak3),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: widget.workplan.keputusan == "1"
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          widget.workplan.keputusan == "1"
                                              ? Image.asset(
                                                  "images/Menu_Task/Data Task/Ok.png")
                                              : Image.asset(
                                                  "images/Menu_Task/Data Task/Cancel.png"),
                                          Text(
                                            widget.workplan.keputusan == "1"
                                                ? "Di Setujui"
                                                : "Di Tolak",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Poppins"),
                                          )
                                        ],
                                      )),
                                  // SizedBox(width: 10,),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade400,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: ListView(
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Alasan Ditolak : ',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Poppins"),
                                          ),
                                          SizedBox(height: Reuseable.jarak1),
                                          Text(alasanDitolak)
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                              // RichText(
                              //   text: TextSpan(
                              //     children: <TextSpan>[
                              //       TextSpan(
                              //           text: 'Keputusan',
                              //           style: TextStyle(
                              //               backgroundColor: Theme.of(context)
                              //                   .scaffoldBackgroundColor,
                              //               color: colorCustom,
                              //               fontWeight: FontWeight.w400,
                              //               fontSize: 16)),
                              //       TextSpan(
                              //           text: '',
                              //           style: TextStyle(
                              //               fontWeight: FontWeight.w500,
                              //               fontSize: 16,
                              //               backgroundColor: Theme.of(context)
                              //                   .scaffoldBackgroundColor,
                              //               color: Colors.red)),
                              //     ],
                              //   ),
                              // ),
                              // TextFormField(
                              //   // validator: requiredValidator,
                              //   controller: _keputusanCtr,
                              //   maxLines: 1,
                              //   enabled: false,
                              //   textInputAction: TextInputAction.next,
                              //   keyboardType: TextInputType.text,
                              //   style: new TextStyle(color: Colors.black),
                              //   readOnly: false,
                              //   onSaved: (em) {
                              //     if (em != null) {}
                              //   },
                              //   decoration: InputDecoration(
                              //     //icon: new Icon(Ionicons.person),
                              //     fillColor: colorCustom,
                              //     floatingLabelBehavior:
                              //         FloatingLabelBehavior.always,

                              //     labelStyle: TextStyle(
                              //         color: colorCustom,
                              //         fontStyle: FontStyle.normal),
                              //     enabledBorder: OutlineInputBorder(
                              //         borderSide:
                              //             BorderSide(color: colorCustom),
                              //         borderRadius: BorderRadius.all(
                              //             Radius.circular(10))),
                              //     focusedBorder: OutlineInputBorder(
                              //         borderSide:
                              //             BorderSide(color: colorCustom),
                              //         borderRadius: BorderRadius.all(
                              //             Radius.circular(10))),
                              //     contentPadding: EdgeInsets.all(10),
                              //   ),
                              // ),
                              // RichText(
                              //   text: TextSpan(
                              //     children: <TextSpan>[
                              //       TextSpan(
                              //           text: 'Alasan(  ditolak)',
                              //           style: TextStyle(
                              //               backgroundColor: Theme.of(context)
                              //                   .scaffoldBackgroundColor,
                              //               color: colorCustom,
                              //               fontWeight: FontWeight.w400,
                              //               fontSize: 16)),
                              //       TextSpan(
                              //           text: '',
                              //           style: TextStyle(
                              //               fontWeight: FontWeight.w500,
                              //               fontSize: 16,
                              //               backgroundColor: Theme.of(context)
                              //                   .scaffoldBackgroundColor,
                              //               color: Colors.red)),
                              //     ],
                              //   ),
                              // ),
                              // TextFormField(
                              //   // validator: requiredValidator,
                              //   controller: _alasanCtr,
                              //   maxLines: 5,
                              //   enabled: false,
                              //   textInputAction: TextInputAction.next,
                              //   keyboardType: TextInputType.text,
                              //   style: new TextStyle(color: Colors.black),
                              //   readOnly: false,
                              //   onSaved: (em) {
                              //     if (em != null) {}
                              //   },
                              //   decoration: InputDecoration(
                              //     //icon: new Icon(Ionicons.person),
                              //     fillColor: colorCustom,
                              //     floatingLabelBehavior:
                              //         FloatingLabelBehavior.always,

                              //     labelStyle: TextStyle(
                              //         color: colorCustom,
                              //         fontStyle: FontStyle.normal),
                              //     enabledBorder: OutlineInputBorder(
                              //         borderSide:
                              //             BorderSide(color: colorCustom),
                              //         borderRadius: BorderRadius.all(
                              //             Radius.circular(10))),
                              //     focusedBorder: OutlineInputBorder(
                              //         borderSide:
                              //             BorderSide(color: colorCustom),
                              //         borderRadius: BorderRadius.all(
                              //             Radius.circular(10))),
                              //     contentPadding: EdgeInsets.all(10),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ))),
      );

  void getWorkplanMessages() async {
    // var userId = widget.user.data.id;
    var data = {
      "workplan_activity_id": widget.workplan.id
      // ,"progres_status_id": progresStatusId
    };

    var response = await RestService()
        .restRequestService(SystemParam.fWorkplanMessagesByWorkplanId, data);

    setState(() {
      WorkplanMessagesModel workplanMessagesModel =
          workplanMessagesFromJson(response.body.toString());
      counter = workplanMessagesModel.data.length;
      wmList = <WorkplanMessages>[];
      wmList = workplanMessagesModel.data;
      loading = false;
    });
  }

  void getWorkplanMessagesDB() async {
    db
        .getWorkplanMessagesByWorkplanActivityId(widget.workplan.id.toString())
        .then((value) {
      setState(() {
        // workplanMessages = workplanMessagesFromJson(response.body.toString());
        wmList = <WorkplanMessages>[];
        wmList = value;
        counter = wmList.length;
        loading = false;
      });
    });
  }

  ListView createListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: counter,
      itemBuilder: (BuildContext context, int index) {
        return customListItem(wmList[index]);
      },
    );
  }

  customListItem(WorkplanMessages wmData) {
    return Card(
      color: Colors.white,
      //elevation: 2.0,
      child: ListTile(
        // leading: Image.asset(
        //   "images/man.png",
        // ),
        // title: Text(
        //   SystemParam.formatDateDisplay.format(wmData.createdAt),
        //   style: TextStyle(fontSize: 16),
        // ),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            wmData.body,
            style: TextStyle(fontSize: 14),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Dari: " +
                wmData.fullName +
                " (" +
                SystemParam.formatDateDisplay.format(wmData.createdAt) +
                ")",
            style: TextStyle(fontSize: 12),
          ),
        ),
        //+"tgl: "+SystemParam.formatDateDisplay.format(wmData.createdAt)
        //trailing: Icon(Icons.arrow_forward),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
