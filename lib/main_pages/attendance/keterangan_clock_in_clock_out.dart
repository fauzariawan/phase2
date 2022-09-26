import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/main_pages/attendance/clock_in_done.dart';
import 'package:workplan_beta_test/main_pages/attendance/clock_out_done.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class KeteranganCICO extends StatefulWidget {
  final String title;
  final String clockTime;
  final String timezone;
  final User user;
  final dynamic role;
  const KeteranganCICO(
      {required this.user,
      required this.clockTime,
      required this.title,
      Key? key,
      required this.timezone, required this.role})
      : super(key: key);

  @override
  State<KeteranganCICO> createState() => _KeteranganCICOState();
}

class _KeteranganCICOState extends State<KeteranganCICO> {
  TextEditingController ket1 = TextEditingController();
  TextEditingController ket2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Keterangan 1"),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: ket1,
                    onChanged: (ket1) {
                      print(ket1);
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SystemParam.colorbackgroud,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: SystemParam.colorbackgroud),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: SystemParam.colorbackgroud),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Keterangan 2"),
                SizedBox(height: 5),
                TextFormField(
                  controller: ket2,
                  onChanged: (ket2) {
                    print(ket2);
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: SystemParam.colorbackgroud,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SystemParam.colorbackgroud),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SystemParam.colorbackgroud),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    print(widget.title);
                    if (widget.title == 'Clock In') {
                      var data = {
                        "company_id": widget.user.userCompanyId,
                        "description_1": ket1.text,
                        "description_2": ket2.text
                      };
                      print(data);
                      var path = SystemParam.clockInDescription +
                          "/" +
                          widget.user.id.toString();
                      var response =
                          await RestService().restRequestService(path, data);

                      var convertDataToJson = json.decode(response.body);

                      if (convertDataToJson['code'] == "0" &&
                          convertDataToJson['status'] == "Success") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClockInDone(
                                    role: widget.role,
                                    timezone: widget.timezone,
                                    clockInTime: widget.clockTime,
                                    user: widget.user)));
                      } else {
                        Warning.showWarning(convertDataToJson['status']);
                      }
                    } else {
                      print("clock out");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClockOutDone(
                                role: widget.role,
                                  user: widget.user,
                                  keterangan1: ket1.text,
                                  keterangan2: ket2.text)));
                    }
                    // widget.title == 'Clock In'
                    //     ? ClockInDone(
                    //         clockInTime: widget.clockTime,
                    //       )
                    //     : print('go to clock out done');
                  },
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        'Next',
                        textAlign: TextAlign.center,
                      )))
            ],
          ),
        ),
      ),
    );
  }
}
