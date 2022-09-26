import 'package:flutter/material.dart';
import 'package:flutter_app_name/context.dart';
import 'package:http/http.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'dart:async';

import 'package:workplan_beta_test/widget/warning.dart';

class TimerCountDown {
  static int count = 0;
  late Timer timer;
  
  startCountDown(int limit, User user, BuildContext context) {
    int? limit = user.timeoutLogin * 60;

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      print(count);
      // print(limit);
      if (count < limit) {
        count++;
      } else {
        timer.cancel();
        Helper.updateIsLogin(user, 0);
        Navigator.of(context).pushNamedAndRemoveUntil(
            loginScreen, (Route<dynamic> route) => false);
      }
    });
  }

  activityDetected() {
    count = 0;
  }

  timerCancel() {
    timer.cancel();
  }

  valueCounter() {
    return count;
  }
}
