import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/choose_user_to_track.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/viewGpsTracking.dart';

import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_inbox.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_list.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/bottom_navigation_bar.dart';

class TaskMenu extends StatefulWidget {
  final User user;
  const TaskMenu({Key? key, required this.user}) : super(key: key);

  @override
  State<TaskMenu> createState() => _TaskMenuState();
}

class _TaskMenuState extends State<TaskMenu> {
  List<dynamic> menu = [
    // {
    //   "title": "Inbox Task",
    //   "picture": "images/Menu_Task/List_Task/Inbox_Task.png",
    //   // "routing": listOperator,
    //   // "data": {"kode": "9", "nama": "Roaming", "routing": produkPromo}
    // },
    // {
    //   "title": "List Task",
    //   "picture": "images/Menu_Task/List_Task/List_Task.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
    // {
    //   "title": "GPS Tracking",
    //   "picture": "images/Menu_Task/List_Task/Gps_Tracking.png",
    //   // "routing": finance,
    //   // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
    // },
  ];
  int count = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    getsubMenuTask();
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
              ));
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Task'),
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    color: SystemParam.colorCustom,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            // color: Colors.yellow,
                            width: MediaQuery.of(context).size.width * 0.8,
                            padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                            child: GridView.builder(
                              padding: EdgeInsets.all(0),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 10,
                                // mainAxisExtent: 100,
                              ),
                              itemCount: menu.length,
                              itemBuilder: (BuildContext context, i) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (menu[i]['title'] == 'Inbox Task') {
                                        // timer!.cancel();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  WorkplanInboxPage(
                                                role: menu[i],
                                                user: widget.user,
                                              ),
                                            ));
                                      } else if (menu[i]['title'] ==
                                          'List Task') {
                                        // timer!.cancel();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  WorkplanList(
                                                      user: widget.user,
                                                      role: menu[i]),
                                            ));
                                      } else if (menu[i]['title'] ==
                                          'GPS Tracking') {
                                        // timer!.cancel();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChooseUserToTrack(
                                                        user: widget.user)));
                                      } else {
                                        print('menuju halaman yang lain');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 5),
                                      primary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            20), // <-- Radius
                                      ),
                                    ),
                                    child: Column(
                                      // mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Image.asset(
                                          menu[i]['picture'],
                                          fit: BoxFit.fill,
                                          width: 50,
                                        ),
                                        Text(
                                          menu[i]['title'],
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontFamily: "Calibre"),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(color: SystemParam.colorDivider)
                      ],
                    ),
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

  void getsubMenuTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      menu = jsonDecode(prefs.getString('subMenuTask')!);
    });
  }
}

// import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
// import 'package:workplan_beta_test/base/system_param.dart';
// import 'package:workplan_beta_test/main_pages/constans.dart';
// import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
// import 'package:workplan_beta_test/main_pages/session_timer.dart';
// import 'package:workplan_beta_test/model/home_model.dart';
// import 'package:workplan_beta_test/model/user_model.dart';
// import 'package:workplan_beta_test/pages/workplan/workplan_inbox.dart';
// import 'package:workplan_beta_test/pages/workplan/workplan_list.dart';

// class TaskMenu extends StatefulWidget {
//   final User user;
//   const TaskMenu({Key? key, required this.user}) : super(key: key);
  

//   @override
//   _TaskMenuState createState() => _TaskMenuState();
// }

// class _TaskMenuState extends State<TaskMenu> {
//   List<WorkplanMenu2> _workplanServiceList = [];
//   List<dynamic> menu = [
//     {
//       "title": "Inbox Task",
//       "picture": "images/Menu/Ok.png",
//       // "routing": listOperator,
//       // "data": {"kode": "9", "nama": "Roaming", "routing": produkPromo}
//     },
//     {
//       "title": "List Task",
//       "picture": "images/Menu/chat 1.png",
//       // "routing": finance,
//       // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
//     },
//     {
//       "title": "GPS Tracking",
//       "picture": "images/Menu/Padlock.png",
//       // "routing": finance,
//       // "data": {"kode": "inet", "nama": "Internet", "kriteria": "cek"}
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();

//     // SessionTimer().startTimer(widget.user.timeoutLogin);
//     // initMenu();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new GestureDetector(
//         // behavior:HitTestBehavior.translucent,
//         // onTap: SessionTimer().userActivityDetected(context, widget.user),
//         // onTapDown: SessionTimer().userActivityDetected(context, widget.user),
//         // onTapUp: SessionTimer().userActivityDetected(context, widget.user),
//         child: WillPopScope(
//             onWillPop: () async {
//               //  Navigator.pop(context);
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => LandingPage(user: widget.user, currentIndex: 0,)));
//               return false;
//             },
//             child: Scaffold(
//                 //drawer: NavigationDrawerWidget(),
//                 appBar: AppBar(
//                   title: Text('Task Menu'),
//                   centerTitle: true,
//                   backgroundColor: SystemParam.colorCustom,
//                   leading: IconButton(
//                     icon: Icon(Icons.arrow_back, color: Colors.black),
//                     //onPressed: () => Navigator.of(context).pop(),
//                     onPressed: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   LandingPage(user: widget.user, currentIndex: 0)));
//                     },
//                   ),
//                 ),
//                 body: new Container(
//                     child: new ListView(
//                         physics: ClampingScrollPhysics(),
//                         children: <Widget>[
//                       new Container(
//                           padding:
//                               EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0),
//                           // color: Colors.white,
//                           child: new Column(
//                             children: <Widget>[_buildMenu()],
//                           )),
//                     ])))));
//   }

//   Widget _buildMenu() {
//     return new SizedBox(
//         width: double.infinity,
//         height: 200.0,
//         child: new Container(
//             margin: EdgeInsets.only(top: 2.0, bottom: 2.0),
//             child: GridView.builder(
//                 physics: ClampingScrollPhysics(),
//                 itemCount: 2,
//                 gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2),
//                 itemBuilder: (context, position) {
//                   return _rowMenuService(_workplanServiceList[position]);
//                 })));
//   }

//   Widget _rowMenuService(WorkplanMenu2 menu) {
//     return new Container(
//       child: new Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           new GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: () {
//               if (menu.title == "LIST TASK") {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => WorkplanList(
//                         user: widget.user,
//                       ),
//                     ));
//               } else if (menu.title == "INBOX") {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           WorkplanInboxPage(user: widget.user),
//                     ));
//               } else if (menu.title == "OTHER") {}
//             },
//             child: new Container(
//               decoration: new BoxDecoration(
//                   border:
//                       Border.all(color: WorkplanPallete.grey200, width: 1.0),
//                   borderRadius:
//                       new BorderRadius.all(new Radius.circular(10.0))),
//               padding: EdgeInsets.all(12.0),
//               child: new Icon(
//                 menu.image,
//                 color: menu.color,
//                 size: 74.0,
//               ),
//               // child: menu.image,
//             ),
//           ),
//           new Padding(
//             padding: EdgeInsets.only(top: 6.0),
//           ),
//           new Text(menu.title, style: new TextStyle(fontSize: 10.0))
//         ],
//       ),
//     );
//   }

//   // initMenu() {
//   //   setState(() {
//   //     _workplanServiceList.add(
//   //       new WorkplanMenu2(
//   //           image: Ionicons.cube_outline,
//   //           color: WorkplanPallete.menuCar,
//   //           title: "INBOX"),
//   //     );

//   //     _workplanServiceList.add(
//   //       new WorkplanMenu2(
//   //           image: Ionicons.checkmark_circle,
//   //           color: WorkplanPallete.menuPulsa,
//   //           title: "LIST TASK"),
//   //     );
//   //   });
//   // }
// }
