// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:workplan_beta_test/base/system_param.dart';
// import 'package:workplan_beta_test/helper/helper.dart';
// import 'package:workplan_beta_test/main_pages/live_tracking/tabGpsTracking.dart';
// import 'package:workplan_beta_test/main_pages/live_tracking/tabLiveTracking.dart';
// import 'package:workplan_beta_test/model/user_model.dart';
// import 'package:workplan_beta_test/routerName.dart';

// class LiveTracking extends StatefulWidget {
//   final User user;

//   const LiveTracking({Key? key, required this.user}) : super(key: key);

//   @override
//   State<LiveTracking> createState() => _LiveTrackingState();
// }

// class _LiveTrackingState extends State<LiveTracking>
//     with SingleTickerProviderStateMixin {
//   TabController? controller;
//   int count = 0;
//   Timer? timer;
//   String? userString;
  
//   @override
//   void initState() {
//     super.initState();
//     controller = new TabController(vsync: this, length: 2);
//     print(widget.user);
//     userString = jsonEncode(widget.user);
//     timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
//       int? limit = widget.user.timeoutLogin * 60;
//       print('ini limit time logout nhya');
//       print(limit);
//       if (count < limit) {
//         print(count);
//         setState(() {
//           count++;
//         });
//       } else {
//         timer.cancel();
//         Helper.updateIsLogin(widget.user, 0);
//         Navigator.of(context).pushNamedAndRemoveUntil(
//             loginScreen, (Route<dynamic> route) => false);
//       }
//     });
//   }

//   void dispose() {
//     super.dispose();
//     controller!.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: TabBar(controller: controller, tabs: <Widget>[
//           Tab(
//               icon: Icon(Icons.person, color: SystemParam.colorCustom),
//               child: Text('GPS Tracking', style: TextStyle(color: SystemParam.colorCustom))),
//           Tab(
//               icon: Icon(Icons.drive_eta, color: SystemParam.colorCustom),
//               child:
//                   Text('Live Tracking', style: TextStyle(color: SystemParam.colorCustom))),
//         ]),
//         body: TabBarView(
//           controller: controller,
//           children: [
//             // TabGpsTracking(),
//             TabLiveTracking(),
//           ],
//         ),
//       ),
//     );
//   }
// }
