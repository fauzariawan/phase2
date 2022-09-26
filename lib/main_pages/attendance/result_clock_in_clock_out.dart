import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/main_pages/attendance/clock_in_done.dart';
import 'package:workplan_beta_test/main_pages/attendance/clock_out_done.dart';
import 'dart:math' as math;

import 'package:workplan_beta_test/main_pages/attendance/keterangan_clock_in_clock_out.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

final double mirror = math.pi;

class ResultCICO extends StatefulWidget {
  final String fullName;
  final String? imagePath;
  final String clockTime;
  final String title;
  final User user;
  final String timezone;
  final dynamic role;
  
  const ResultCICO(this.role, this.user, this.title, this.fullName, this.imagePath,
      this.clockTime, this.timezone,
      {Key? key})
      : super(key: key);

  @override
  State<ResultCICO> createState() => _ResultCICOState();
}

class _ResultCICOState extends State<ResultCICO> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: SystemParam.colorCustom,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              children: [
                widget.imagePath == null
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 9, vertical: 9),
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: MediaQuery.of(context).size.width * 0.9,
                            child: Text('No Picture')),
                      )
                    : Align(
                        alignment: Alignment.topCenter,
                        child: Transform(
                          alignment: Alignment.topCenter,
                          transform: Matrix4.rotationY(
                              mirror), // untuk mengatasi posisi gambar yang flip sendiri
                          child: Center(
                            child: Image.file(File(widget.imagePath!),
                                width: MediaQuery.of(context).size.width * 0.65,
                                height:
                                    MediaQuery.of(context).size.width * 0.91),
                          ),
                        ),
                      ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset("images/Attandance/picture frame3.png",
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.91),
                )
              ],
            ),
            Column(
              children: [
                Text(
                    widget.title == 'Clock In'
                        ? 'Hello ${widget.fullName} !'
                        : 'See You ${widget.fullName} !',
                    style: TextStyle(
                        fontFamily: "roboto",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow)),
                SizedBox(
                  height: Reuseable.jarak1,
                ),
                Text(
                    widget.title == 'Clock In'
                        ? 'Clock In Successful'
                        : 'Clock Out Successful',
                    style: TextStyle(
                        fontFamily: "roboto",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(
                  height: Reuseable.jarak2,
                ),
                Text('${widget.clockTime} ${widget.timezone}',
                    style: TextStyle(
                        fontFamily: "roboto",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KeteranganCICO(
                                  role: widget.role,
                                      user: widget.user,
                                      title: widget.title,
                                      clockTime: widget.clockTime,
                                      timezone: widget.timezone,
                                    )));
                      },
                      child: Text(
                        "Next",
                        style: TextStyle(color: SystemParam.colorCustom),
                      )),
                ),
                TextButton(
                    onPressed: () {
                      widget.title == 'Clock In'
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClockInDone(
                                        role: widget.role,
                                        clockInTime: widget.clockTime,
                                        user: widget.user,
                                        timezone: widget.timezone,
                                      )))
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ClockOutDone(
                                      role: widget.role,
                                      user: widget.user,
                                      keterangan1: "",
                                      keterangan2: "")));
                    },
                    child: Text(
                      "Back",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ) // Ini larinya kemana??
          ],
        ),
      ),
    );
  }
}
