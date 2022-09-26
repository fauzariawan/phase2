import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class InternetChecking {
  static Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
        // Warning.showWarning("Has Internet Connection");
      } else {
        return false;
      }
    } catch (e) {
      return false;
      // Warning.showWarning("No Internet Connection");
    }
  }
}

// SocketException catch (_)