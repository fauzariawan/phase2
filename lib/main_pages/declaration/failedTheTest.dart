import "package:flutter/material.dart";
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/declaration/declaration.dart';
import 'package:workplan_beta_test/model/user_model.dart';

class FailedTheTest extends StatefulWidget {
  const FailedTheTest({Key? key, required this.user, required this.role})
      : super(key: key);
  final User user;
  final dynamic role;

  @override
  State<FailedTheTest> createState() => _FailedTheTestState();
}

class _FailedTheTestState extends State<FailedTheTest> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          TimerCountDown().activityDetected();
        },
        child: Scaffold(
          body: Column(
            children: [
              Image.asset("images/declaration/failedTheTest.png"),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Declaration(
                          role: widget.role,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                  child: Text("Back To Home"))
            ],
          ),
        ),
      ),
    );
  }
}
