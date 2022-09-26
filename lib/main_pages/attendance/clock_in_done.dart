import 'package:flutter/material.dart';
import 'package:workplan_beta_test/main_pages/attendance/attendance.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/user_model.dart';

class ClockInDone extends StatefulWidget {
  final User user;
  final String clockInTime;
  final String timezone;
  final dynamic role;
  const ClockInDone(
      {required this.user,
      required this.clockInTime,
      Key? key,
      required this.timezone, required this.role})
      : super(key: key);

  @override
  State<ClockInDone> createState() => _ClockInDoneState();
}

class _ClockInDoneState extends State<ClockInDone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset("images/Attandance/Frame 13.png"),
          Column(
            children: [
              Text("${widget.clockInTime} ${widget.timezone}",
                  style: TextStyle(
                      fontFamily: "roboto",
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              Text('Clock In Time',
                  style: TextStyle(
                    fontFamily: "roboto",
                    fontSize: 18,
                  )),
            ],
          ),
          Column(
            children: [
              Text("Happy Working : )",
                  style: TextStyle(
                    fontFamily: "roboto",
                    fontSize: 18,
                  )),
              Text('Have a nice day !!!',
                  style: TextStyle(
                      fontFamily: "roboto",
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Attendance(
                          role: widget.role,
                          user: widget.user,
                        ),
                      ),
                    );
                  },
                  child: Text('Done'),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LandingPage(user: widget.user, currentIndex: 0),
                        ));
                  },
                  child: Text('Back to Home'))
            ],
          )
        ],
      ),
    ));
  }
}
