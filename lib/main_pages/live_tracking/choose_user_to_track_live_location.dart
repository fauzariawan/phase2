import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:textfield_search/textfield_search.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/viewLiveTrackingLocation.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class ChooseUserToTrackLiveLocation extends StatefulWidget {
  final User user;
  const ChooseUserToTrackLiveLocation({Key? key, required this.user})
      : super(key: key);

  @override
  State<ChooseUserToTrackLiveLocation> createState() =>
      _ChooseUserToTrackLiveLocationState();
}

class _ChooseUserToTrackLiveLocationState
    extends State<ChooseUserToTrackLiveLocation> {
  TextEditingController name = new TextEditingController();
  List _listEmployee = <dynamic>[];
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
      },
      child: WillPopScope(
        onWillPop: () async {
          // timer!.cancel();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LandingPage(
                  user: widget.user,
                  currentIndex: 0,
                ),
              ),
            );
            return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Live Tracking Location'),
            centerTitle: true,
          ),
          body: Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.only(top: 30, left: 20, right: 20),
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Text('Live Tracking Location',
                    style: TextStyle(
                        fontFamily: "poppins",
                        color: SystemParam.colorCustom,
                        fontSize: 20)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Text('Employee Name'),
                    SizedBox(height: Reuseable.jarak1),
                    TextFieldSearch(
                        label: 'Employee Name',
                        controller: name,
                        future: () {
                          return fetchSimpleData();
                        },
                        decoration:
                            Reuseable.inputDecorationSearch("Employee Name")),
                  ],
                ),
                SizedBox(
                  height: Reuseable.jarak3,
                ),
                SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                        onPressed: () {
                          findUser();
                          print(name.text);
                        },
                        child: Text("Search")))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List> fetchSimpleData() async {
    Uri url = Uri.parse(
        "https://workplan-phase2-be.aplikasidev.com/api/employee?company_id=${widget.user.userCompanyId}&name=${name.text}");
    List _list = <dynamic>[];
    try {
      var response = await http.get(url);
      var responseJson = jsonDecode(response.body);
      var data = responseJson['data'];
      print(data);
      _listEmployee = data;
      for (var i = 0; i < data.length; i++) {
        _list.add(data[i]['full_name']);
      }
      return _list;
    } catch (e) {
      print('error konneksi http');
      print(e);
      Warning.showWarning('No Internet Connection');
      return _list;
    }
  }

  void findUser() async {
    Warning.loading(context);
    int id = getId();
    // print('ini id yang mau di cari');
    // print(id);
    // print(name.text);
    // print(id);
    // print(
    //     "url : https://workplan-phase2-be.aplikasidev.com/api/live-tracking/$id?company_id=${widget.user.userCompanyId}");
    // Uri url = Uri.parse(
    //     "https://workplan-phase2-be.aplikasidev.com/api/live-tracking/$id?company_id=${widget.user.userCompanyId}");
    Uri url = Uri.parse(
        "https://workplan-phase2-be.aplikasidev.com/api/live-tracking/$id?company_id=${widget.user.userCompanyId}");
    print(url);
    try {
      var response = await http.get(url);
      var responseJson = jsonDecode(response.body);
      print(responseJson['code']);
      print(responseJson['status']);
      if (responseJson['code'] == 0 && responseJson['status'] == "Success") {
        var data = responseJson['data'];
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ViewLiveTrackingLocation(data: data, user: widget.user,)));

      } else {
        Navigator.pop(context);
        Warning.showWarning('Data Tidak Ditemukan');
      }
    } catch (e) {
      print('error konneksi http');
      print(e);
      Warning.showWarning('No Internet Connection');
      // return _list;
    }
  }

  getId() {
    print(_listEmployee);
    for (var item in _listEmployee) {
      if (item['full_name'] == name.text) {
        print('nama cocok ');
        print(item['id']);
        return item['id'];
      }
    }
    return 9999;
  }
}
