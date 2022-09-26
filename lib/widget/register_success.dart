import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/loginscreen.dart';
import 'package:workplan_beta_test/pages/profile/setting/profile_setting.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

class RegisterSuccess extends StatefulWidget {
  final User user;
  final String fromPage;
  // final Timer timer;
  const RegisterSuccess(
      {Key? key,
      required this.user,
      required this.fromPage,
      // required this.timer,
      })
      : super(key: key);

  @override
  State<RegisterSuccess> createState() => _RegisterSuccessState();
}

class _RegisterSuccessState extends State<RegisterSuccess> {
  Timer? timer;
  int count = 0;
  @override
  void initState() {
    super.initState();
    // widget.timer.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      int? limit = widget.user.timeoutLogin * 60;
      print('ini limit time logout nhya');
      print(limit);
      if (count < limit) {
        print(count);
        setState(() {
          count++;
        });
      } else {
        timer.cancel();
        Helper.updateIsLogin(widget.user, 0);
        Navigator.of(context).pushNamedAndRemoveUntil(
            loginScreen, (Route<dynamic> route) => false);
      }
    });
    // ignore: unnecessary_null_comparison
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.fromPage),
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset("images/Attandance/Frame 13.png",
                      width: MediaQuery.of(context).size.width * 0.8),
                  SizedBox(
                    height: Reuseable.jarak3,
                  ),
                  Text(
                    """Your face registration request
has been sent for approval, 
check on your whatsapp for 
the decision""",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: "poppins", fontSize: 18),
                  ),
                  SizedBox(
                    height: Reuseable.jarak3,
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            if (widget.fromPage == 'LOGIN') {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileSetting(
                                          user: widget.user, /*timer: timer!*/)));
                            }
                          },
                          child: Text('Next')))
                ],
              ),
            )));
  }
}
// class RegisterSuccess extends StatelessWidget {
  // final User user;
  // final String fromPage;
//   Timer? timer;
//   int count = 0;
//   const RegisterSuccess({Key? key, required this.user, required this.fromPage, required this.timer})
//       : super(key: key);

//   @override
//   void initState() {
//     super.initState();
//     widget.timer.cancel();
//     isChecked = user.isFaceRecognitionRegistered == 1 ? true : false;
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
//     // ignore: unnecessary_null_comparison
//   }
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//             appBar: AppBar(
//               title: Text(fromPage),
//             ),
//             body: SizedBox(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Image.asset("images/Attandance/Frame 13.png",
//                       width: MediaQuery.of(context).size.width * 0.8),
//                   SizedBox(
//                     height: Reuseable.jarak3,
//                   ),
//                   Text(
//                     """Your face registration request
// has been sent for approval, 
// check on your whatsapp for 
// the decision""",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontFamily: "poppins", fontSize: 18),
//                   ),
//                   SizedBox(
//                     height: Reuseable.jarak3,
//                   ),
//                   SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       height: 50,
//                       child: ElevatedButton(
//                           onPressed: () {
//                             if (fromPage == 'LOGIN') {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                   builder: (context) => LoginScreen()));
//                             } else {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => ProfileSetting(
//                                           user: user, timer: timer)));
//                             }
//                           },
//                           child: Text('Next')))
//                 ],
//               ),
//             )));
//   }
// }
