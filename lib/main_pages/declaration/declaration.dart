import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class Declaration extends StatefulWidget {
  final User user;
  final dynamic role;
  const Declaration({Key? key, required this.user, required this.role})
      : super(key: key);

  @override
  State<Declaration> createState() => _DeclarationState();
}

class _DeclarationState extends State<Declaration> {
  int count = 0;
  Timer? timer;
  String? userString;
  List<dynamic> declarationMenu = [];
  DateTime now = DateTime.now();
  DateFormat dateFormat = DateFormat("dd MMMM yyyy");
  String stringDate = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    stringDate = dateFormat.format(DateTime.now());
    print(widget.user);
    userString = jsonEncode(widget.user);
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   int? limit = widget.user.timeoutLogin * 60;
    //   print('ini limit time logout nhya');
    //   print(limit);
    //   if (count < limit) {
    //     print(count);
    //     setState(() {
    //       count++;
    //     });
    //   } else {
    //     timer.cancel();
    //     Helper.updateIsLogin(widget.user, 0);
    //     Navigator.of(context).pushNamedAndRemoveUntil(
    //         loginScreen, (Route<dynamic> route) => false);
    //   }
    // });
    initMenuDeclaration();
  }

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
              title: Text("Declaration"),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : declarationMenu.length != 0
                      ? createListViewOnline()
                      : Center(
                          child: Text("Tidak Ada Menu Deklarasi"),
                        ),
            )),
      ),
    );
  }

  GridView createListViewOnline() {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 5,
            crossAxisSpacing: 10,
            mainAxisExtent: 250, // jarak atas bawah antara card
            mainAxisSpacing: 0),
        itemCount: declarationMenu.length,
        itemBuilder: (BuildContext context, i) {
          return GestureDetector(
            onTap: () {
              if (widget.role['isEdit'] == 0) {
                Warning.showWarning("Kamu tidak diizinkan utnuk mengisi form deklarasi");
                return;
              }
              print(declarationMenu[i]['is_passed']);
              print(declarationMenu[i]['is_filled']);
              String hasil = "";
              if (declarationMenu[i]['is_passed'] != null ||
                  declarationMenu[i]['is_filled']) {
                print('masuk sini');

                // timer!.cancel();
                Navigator.pushNamed(context, declarationQuestionAnswer,
                    arguments: {
                      "title": declarationMenu[i]['title'],
                      "user": widget.user,
                      "idQuestion": declarationMenu[i]["id"],
                      "isViewOnly": true,
                      "isScoring": declarationMenu[i]["is_scoring"],
                      "role": widget.role
                    });

                return;
              }
              // timer!.cancel();
              Navigator.pushNamed(context, declarationQuestionAnswer,
                  arguments: {
                    "title": declarationMenu[i]['title'],
                    "user": widget.user,
                    "idQuestion": declarationMenu[i]["id"],
                    "isViewOnly": false,
                    "isScoring": declarationMenu[i]["is_scoring"],
                    "role": widget.role
                  });
            },
            child: SingleChildScrollView(
              child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          width: double.infinity,
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: SystemParam.colorbackgroud2,
                          ),
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.topRight,
                                  child: declarationMenu[i]['is_priority'] ==
                                          true
                                      ? Image.asset(
                                          "images/Menu_Task/Data Task/High Priority Message.png")
                                      : Container()),
                              Center(
                                child: Container(
                                    width: 70,
                                    height: 80,
                                    // color: Colors.black,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "images/Menu_Task/List_Task/Icon_List_Task2.png"),
                                        fit: BoxFit.fill,
                                      ),
                                    )),
                              )
                              // Image.asset("images/Menu_Task/List_Task/Icon_List_Task2.png", width: 100),
                            ],
                          ),
                        ),
                        Text(declarationMenu[i]['title'],
                            style: Reuseable.titleStyle2),
                        SizedBox(height: 5),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                              color: declarationMenu[i]['is_filled'] == true
                                  ? SystemParam.colorCustom
                                  : Colors.amberAccent,
                              borderRadius: BorderRadius.circular(10)),
                          child: declarationMenu[i]['is_filled'] == true
                              ? Text("Filled", style: Reuseable.titleStyle3)
                              : Text("UnFilled", style: Reuseable.titleStyle3),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20),
                            SizedBox(
                              width: 6,
                            ),
                            Text(
                              // declarationMenu[i]['date'],
                              stringDate,
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        )
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Row(
                        //       children: [
                        //         Container(
                        //           padding: EdgeInsets.symmetric(
                        //               horizontal: 5, vertical: 2),
                        //           decoration: BoxDecoration(
                        //               color: SystemParam.colorCustom,
                        //               borderRadius: BorderRadius.circular(10)),
                        //           child: Text(
                        //               parameterDokumenWorkplanList[i].mandatory
                        //                   ? 'Mandatory'
                        //                   : 'Terserah',
                        //               style: Reuseable.titleStyle3),
                        //         ),
                        //         SizedBox(
                        //           width: 5,
                        //         ),
                        //         Image.asset(
                        //             "images/Menu_Task/Data Task/High Priority Message.png")
                        //       ],
                        //     ),
                        //     Text(
                        //       '${parameterDokumenWorkplanList[i].countDokumen}/${parameterDokumenWorkplanList[i].maxphoto}',
                        //       style: TextStyle(
                        //           color: Colors.grey[400], fontFamily: 'Poppins'),
                        //     )
                        //   ],
                        // )
                      ],
                    ),
                  )),
            ),
          );
        });
  }

  void initMenuDeclaration() async {
    setState(() {
      isLoading = true;
    });
    var response = await RestService().requestServiceGet(
        SystemParam.declaration,
        null,
        "user_id=${widget.user.id}&company_id=${widget.user.userCompanyId}");
    var responseJson = json.decode(response.body);
    print('Ini data Declaration <<<<<<=====');
    declarationMenu = responseJson['data'];
    setState(() {
      isLoading = false;
    });
  }
}
