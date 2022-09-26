import "package:flutter/material.dart";
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/declaration/declaration.dart';
import 'package:workplan_beta_test/model/user_model.dart';

class PassedTheTest extends StatefulWidget {
  const PassedTheTest({Key? key, required this.user, required this.role})
      : super(key: key);
  final User user;
  final dynamic role;

  @override
  State<PassedTheTest> createState() => _PassedTheTestState();
}

class _PassedTheTestState extends State<PassedTheTest> {
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
              Image.asset("images/declaration/passedTheTest.png"),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Declaration(user: widget.user, role: widget.role),
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
