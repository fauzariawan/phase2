// import 'package:flutter/material.dart';
// import 'package:workplan_beta_test/base/system_param.dart';
// import 'package:workplan_beta_test/main_pages/live_tracking/viewGpsTracking.dart';
// import 'package:workplan_beta_test/widget/reuseable_widget.dart';

// class TabGpsTracking extends StatefulWidget {
//   const TabGpsTracking({Key? key}) : super(key: key);

//   @override
//   State<TabGpsTracking> createState() => _TabGpsTrackingState();
// }

// class _TabGpsTrackingState extends State<TabGpsTracking> {
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           body: Container(
//         margin: EdgeInsets.all(15),
//         padding: EdgeInsets.all(15),
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height * 0.6,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: SystemParam.colorbackgroud2),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Text("GPS Tracking",
//                 style: TextStyle(
//                     fontSize: 16,
//                     fontFamily: "roboto",
//                     color: SystemParam.colorCustom,
//                     fontWeight: FontWeight.bold)),
//             Column(
//               children: [
//                 input(
//                     "Employee Name",
//                     Icon(
//                       Icons.search,
//                       color: Colors.grey,
//                     )),
//                 SizedBox(
//                   height: Reuseable.jarak1,
//                 ),
//                 input(
//                     "Task Date",
//                     Icon(
//                       Icons.date_range_rounded,
//                       color: Colors.grey,
//                     )),
//                 SizedBox(
//                   height: Reuseable.jarak1,
//                 ),
//                 input(
//                     "Task Number Range Star From",
//                     Icon(
//                       Icons.search,
//                       color: Colors.grey,
//                     )),
//                 SizedBox(
//                   height: Reuseable.jarak1,
//                 ),
//                 input(
//                     "Task Number Range Until",
//                     Icon(
//                       Icons.search,
//                       color: Colors.grey,
//                     )),
//               ],
//             ),
//             SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 height: 50,
//                 child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => ViewGpsTracking(user: user)));
//                     },
//                     child: Text("Search")))
//           ],
//         ),
//       )),
//     );
//   }

//   TextFormField input(String hint, Widget icon) {
//     return TextFormField(
//       keyboardType: TextInputType.text,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         suffixIcon: icon,
//         fillColor: SystemParam.colorbackgroud,
//         hintStyle: TextStyle(fontStyle: FontStyle.italic),
//         enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: SystemParam.colorbackgroud),
//             borderRadius: BorderRadius.all(Radius.circular(10))),
//         focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: SystemParam.colorbackgroud),
//             borderRadius: BorderRadius.all(Radius.circular(10))),
//         contentPadding: EdgeInsets.all(10),
//       ),
//     );
//   }
// }
