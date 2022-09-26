import 'dart:convert';

import "package:flutter/material.dart";
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/declaration/failedTheTest.dart';
import 'package:workplan_beta_test/main_pages/declaration/passedTheTest.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/widget/internet_checking.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class DeclarationQuestionAnswer extends StatefulWidget {
  const DeclarationQuestionAnswer(
      {Key? key,
      required this.title,
      required this.user,
      required this.idQuestion,
      required this.isScoring,
      required this.isViewOnly,
      required this.role})
      : super(key: key);
  final String title;
  final int idQuestion;
  final User user;
  final bool isViewOnly;
  final bool isScoring;
  final dynamic role;

  @override
  State<DeclarationQuestionAnswer> createState() =>
      _DeclarationQuestionAnswerState();
}

enum Answer { yes, no }

class _DeclarationQuestionAnswerState extends State<DeclarationQuestionAnswer> {
  List<dynamic> listQuestion = [];
  var id;
  String txt = "ini text contoh";
  bool isLoading = false;
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    print('cek view only <<<<<<<<<<<<<<<<========');
    print(widget.isViewOnly);
    initQuestion();
  }

  Widget build(BuildContext context) {
    TextStyle style =
        TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold);
    var last = listQuestion.length + 1;
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : listQuestion.length == 0
                  ? Center(
                      child: Text("No Question"),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: ListView.builder(
                          itemCount: listQuestion.length + 1,
                          itemBuilder: (context, i) {
                            var id = 0;
                            if (last == i + 1) {
                              return widget.isViewOnly
                                  ? widget.isScoring
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Total Score : ",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey)),
                                                Text(totalScore.toString(),
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey))
                                              ],
                                            ),
                                          ],
                                        )
                                      : Container()
                                  : Column(
                                      children: [
                                        SizedBox(height: 10),
                                        SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.8,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              kirim();
                                            },
                                            child: Text("Submit", style: style),
                                          ),
                                        ),
                                      ],
                                    );
                            }
                            if (i == 0) {
                              return Container(
                                // padding: EdgeInsets.all(5),
                                // decoration: BoxDecoration(border: Border.all(color: SystemParam.colorbackgroud)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Text(listQuestion[i]["no"],
                                                  textAlign: TextAlign.center,
                                                  style: style)),
                                          Expanded(
                                              flex: 8,
                                              child: Text(
                                                  listQuestion[i]["question"],
                                                  style: style)),
                                          Expanded(
                                              flex: 1,
                                              child: Text(listQuestion[i]["yes"],
                                                  textAlign: TextAlign.center,
                                                  style: style)),
                                          Expanded(
                                              flex: 1,
                                              child: Text(listQuestion[i]["no"],
                                                  textAlign: TextAlign.center,
                                                  style: style)),
                                          if (widget.isViewOnly)
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    listQuestion[i]["score"],
                                                    textAlign: TextAlign.center,
                                                    style: style)),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      thickness: 2,
                                    )
                                  ],
                                ),
                              );
                            } else {
                              return Container(
                                // decoration: BoxDecoration(border: Border.all(color: SystemParam.colorbackgroud)),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Text(i.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: widget.isViewOnly
                                                          ? Colors.grey
                                                          : Colors.black))),
                                          Expanded(
                                              flex: widget.isViewOnly ? 5 : 6,
                                              child: Text(
                                                listQuestion[i]['question'],
                                                style: TextStyle(
                                                    color: widget.isViewOnly
                                                        ? Colors.grey
                                                        : Colors.black),
                                              )),
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              children: [
                                                Radio(
                                                  activeColor:
                                                      SystemParam.colorCustom,
                                                  value: 1,
                                                  groupValue: listQuestion[i]
                                                      ["answer"],
                                                  // visualDensity: VisualDensity.adaptivePlatformDensity,
                                                  onChanged: widget.isViewOnly
                                                      ? null
                                                      : (val) {
                                                          print(val);
                                                          // changeValue();
                                                          // print(listQuestion[i]["pertanyaan"]);
                                                          setState(() {
                                                            listQuestion[i]
                                                                    ["answer"] =
                                                                val as int;
                                                          });
                                                          print(listQuestion[i]);
                                                        },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Radio(
                                                activeColor:
                                                    SystemParam.colorCustom,
                                                value: 2,
                                                groupValue: listQuestion[i]
                                                    ["answer"],
                                                onChanged: widget.isViewOnly
                                                    ? null
                                                    : (val) {
                                                        print(val);
                                                        setState(() {
                                                          listQuestion[i]
                                                                  ["answer"] =
                                                              val as int;
                                                        });
                                                        print(listQuestion[i]);
                                                      },
                                              )),
                                          if (widget.isViewOnly)
                                            Expanded(
                                                flex: 1,
                                                child:
                                                    listQuestion[i]["answer"] == 1
                                                        ? Text(
                                                            listQuestion[i]
                                                                    ["score_yes"]
                                                                .toString(),
                                                            textAlign:
                                                                TextAlign.center,
                                                          )
                                                        : Text(
                                                            listQuestion[i]
                                                                    ["score_no"]
                                                                .toString(),
                                                            textAlign:
                                                                TextAlign.center,
                                                          ))
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      thickness: 2,
                                    )
                                  ],
                                ),
                              );
                            }
                          }),
                    )),
    );
  }

  void initQuestion() async {
    setState(() {
      isLoading = true;
    });
    var response = await RestService().requestServiceGet(
        SystemParam.declaration,
        widget.idQuestion.toString(),
        "user_id=${widget.user.id}&company_id=${widget.user.userCompanyId}");
    var responseJson = json.decode(response.body);
    print('Ini data Declaration <<<<<<=====');

    setState(() {
      listQuestion = responseJson['data'];
      if (widget.isViewOnly == true) {
        if (widget.isScoring) {
          print("menggunakan fungsi isSoring <<<<====");
          for (var item in listQuestion) {
            int score = 0;
            score = item["answer"] == 1 ? item["score_yes"] : item["score_no"];
            totalScore += score;
          }
        }
        listQuestion.insert(0, {
          "no": "No",
          "question": "Question",
          "yes": "Yes",
          "score": "Score"
        });
      } else {
        listQuestion.insert(0, {
          "no": "No",
          "question": "Question",
          "yes": "Yes",
        });
      }
      isLoading = false;
    });
    print('ini list questionnya <<<<<<========');
    print(listQuestion[0]);
  }

  void kirim() async {
    // print(listQuestion);
    listQuestion.removeAt(0); // menghapus data di index pertama (0)
    // print(listQuestion);
    var data = {
      "user_id": widget.user.id,
      "company_id": widget.user.userCompanyId,
      "parameter_declaration_id": widget.idQuestion,
      "date": DateTime.now().toString(),
      "data": listQuestion
    };
    bool hasInternetConnection = await InternetChecking.checkInternet();
    if (hasInternetConnection) {
      var response = await RestService().restRequestService(
        SystemParam.declaration,
        data,
      );
      var responseJson = json.decode(response.body);
      print(responseJson);
      if (responseJson['status'] == 1 && responseJson['is_passed'] == true) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PassedTheTest(
                  role: widget.role,
                  user: widget.user,
                )));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                FailedTheTest(user: widget.user, role: widget.role)));
      }
    } else {
      Warning.showWarning("No Internet Connection");
    }
  }
}

// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
//   child: Column(
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             flex: 1,
//             child: Container(
//               color: Colors.yellow,
//               child: Text("No", textAlign: TextAlign.center,))),
//           Expanded(
//             flex: 8,
//             child: Container(
//               color: Colors.blue,
//               child: Text("Question"))),
//           Expanded(
//             flex: 1,
//             child: Container(
//               color: Colors.red,
//               child: Text("Yes", textAlign: TextAlign.center,))),
//           Expanded(
//             flex: 1,
//             child: Container(
//               color: Colors.green,
//               child: Text("No", textAlign: TextAlign.center,))),
//           // Expanded(
//           //   child: Row(
//           //     children: [
//           //       Theme(
//           //         data: ThemeData(unselectedWidgetColor: Colors.yellow),
//           //         child: Radio(
//           //           activeColor: Colors.yellow,
//           //           value: 1,
//           //           groupValue: id,
//           //           onChanged: (val) {
//           //             print(val);
//           //             setState(() {
//           //               id = val;
//           //             });
//           //           },
//           //         ),
//           //       ),
//           //       Text(
//           //         'By Destiny',
//           //         style: new TextStyle(fontSize: 17.0),
//           //       ),
//           //       Theme(
//           //         data: ThemeData(
//           //             unselectedWidgetColor: Colors
//           //                 .yellow), // Changing radio button border color when unselected warping with Theme
//           //         child: Radio(
//           //           activeColor: Colors.yellow,
//           //           value: 2,
//           //           groupValue: id,
//           //           onChanged: (val) {
//           //             print(val);
//           //             setState(() {
//           //               id = val;
//           //             });
//           //           },
//           //         ),
//           //       ),
//           //       Text(
//           //         'By Date',
//           //         style: new TextStyle(
//           //           fontSize: 17.0,
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           // Icon(Icons.search, color: Colors.yellow, size: 30)
//         ],
//         // DataTable(
//         //   horizontalMargin: 12,
//         //   dataRowHeight: 80,
//         //   headingRowHeight: 30,
//         //   columnSpacing: 10, // jarak antar column
//         //   dataRowColor:
//         //       MaterialStateProperty.resolveWith((states) => Colors.white),
//         //   showBottomBorder: true,
//         //   // decoration:
//         //   //     BoxDecoration(border: Border.all(color: SystemParam.colorCustom)),
//         //   // dividerThickness: 2,
//         //   border: TableBorder(
//         //       left: BorderSide(
//         //           color: SystemParam.colorbackgroud2, width: 1),
//         //       right: BorderSide(
//         //           color: SystemParam.colorbackgroud2, width: 1),
//         //       horizontalInside: BorderSide(
//         //           width: 1,
//         //           color: SystemParam.colorbackgroud2,
//         //           style: BorderStyle.solid)),
//         //   columns: <DataColumn>[
//         //     DataColumn(
//         //       label: Text("No"),
//         //     ),
//         //     DataColumn(
//         //       label: Text("Question"),
//         //     ),
//         //     DataColumn(
//         //         label: Container(
//         //             width: MediaQuery.of(context).size.width * 0.1,
//         //             child: Center(child: Text("Yes")))),
//         //     DataColumn(
//         //         label: Container(
//         //             width: MediaQuery.of(context).size.width * 0.1,
//         //             child: Center(child: Text("No")))),
//         //   ],
//         //   rows: <DataRow>[
//         //     dataFill(
//         //         "1", "Khusus bagi karyawati, apakah Anda sedang hamil?"),
//         //     dataFill("2",
//         //         "Khusus bagi karyawati, apakah sedang menyusui anak Anda?"),
//         //     dataFill("3",
//         //         "Apakah ada faktor komorbiditas pada Anda, antara lain seperti: sakit jantung, tekanan darah tinggi, diabetes, asma, gangguan lever, gangguan ginjal, gangguan paru, penyakit autoimun."),
//         //     dataFill("4",
//         //         "Apakah pernah keluar rumah/tempat umum (pasar, fasyankes, kerumunan orang, dan lain-lain )?"),
//         //     dataFill("5", "Apakah pernah menggunakan transportasi umum?"),
//         //     dataFill("6",
//         //         "Apakah pernah melakukan perjalanan ke luar kota/internasional? (wilayah yang terjangkit/zona merah)?"),
//         //     dataFill("7",
//         //         "Apakah Anda mengikuti kegiatan berkumpul di suatu tempat yang melibatkan orang banyak?"),
//         //     dataFill("8",
//         //         "Apakah memiliki riwayat kontak erat dengan orang yang dinyatakan ODP, PDP atau konfirm COVID-19 (berjabat tangan, berbicara, berada dalam satu ruangan/satu rumah)?")
//         //   ],
//         // ),
//         // SizedBox(
//         //   height: 20,
//         // ),
//         // SizedBox(
//         //     width: MediaQuery.of(context).size.width,
//         //     height: 50,
//         //     child:
//         //         ElevatedButton(onPressed: () {}, child: Text("Submit"))),
//         // SizedBox(
//         //   height: 20,
//         // ),
//         // Row(
//         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         //   children: [
//         //     ElevatedButton(
//         //         onPressed: () {
//         //           Navigator.of(context).push(MaterialPageRoute(
//         //               builder: (context) => PassedTheTest()));
//         //         },
//         //         child: Text("Passed")),
//         //     ElevatedButton(
//         //         onPressed: () {
//         //           Navigator.of(context).push(MaterialPageRoute(
//         //               builder: (context) => FailedTheTest()));
//         //         },
//         //         child: Text("Failed"))
//         //   ],
//         // )
//       )
//     ],
//   ),
// ),

// DataRow dataFill(
//   String column1,
//   String column2,
// ) {
//   return DataRow(
//     cells: <DataCell>[
//       DataCell(Text(column1)),
//       DataCell(Container(
//           width: MediaQuery.of(context).size.width * 0.6,
//           child: Text(
//             column2,
//             style: TextStyle(fontSize: 12),
//           ))),
//       DataCell(
//         Container(
//           width: MediaQuery.of(context).size.width * 0.1,
//           child: Radio(
//             activeColor: SystemParam.colorCustom,
//             splashRadius: 50,
//             value: Answer.yes,
//             groupValue: column1 == '1'
//                 ? _answer1
//                 : column1 == '2'
//                     ? _answer2
//                     : column1 == '3'
//                         ? _answer3
//                         : column1 == '4'
//                             ? _answer4
//                             : column1 == '5'
//                                 ? _answer5
//                                 : column1 == '6'
//                                     ? _answer6
//                                     : column1 == '7'
//                                         ? _answer7
//                                         : column1 == '8'
//                                             ? _answer8
//                                             : _answer1,
//             onChanged: (Answer? value) {
//               setState(() {
//                 switch (column1) {
//                   case "1":
//                     _answer1 = value!;
//                     break;
//                   case "2":
//                     _answer2 = value!;
//                     break;
//                   case "3":
//                     _answer3 = value!;
//                     break;
//                   case "4":
//                     _answer4 = value!;
//                     break;
//                   case "5":
//                     _answer5 = value!;
//                     break;
//                   case "6":
//                     _answer6 = value!;
//                     break;
//                   case "7":
//                     _answer7 = value!;
//                     break;
//                   case "8":
//                     _answer8 = value!;
//                     break;
//                   default:
//                 }
//               });
//             },
//           ),
//         ),
//       ),
//       DataCell(
//         Container(
//           width: MediaQuery.of(context).size.width * 0.1,
//           child: Radio<Answer>(
//             activeColor: SystemParam.colorCustom,
//             splashRadius: 50,
//             value: Answer.no,
//             groupValue: column1 == '1'
//                 ? _answer1
//                 : column1 == '2'
//                     ? _answer2
//                     : column1 == '3'
//                         ? _answer3
//                         : column1 == '4'
//                             ? _answer4
//                             : column1 == '5'
//                                 ? _answer5
//                                 : column1 == '6'
//                                     ? _answer6
//                                     : column1 == '7'
//                                         ? _answer7
//                                         : column1 == '8'
//                                             ? _answer8
//                                             : _answer1,
//             onChanged: (Answer? value) {
//               setState(() {
//                 switch (column1) {
//                   case "1":
//                     _answer1 = value!;
//                     break;
//                   case "2":
//                     _answer2 = value!;
//                     break;
//                   case "3":
//                     _answer3 = value!;
//                     break;
//                   case "4":
//                     _answer4 = value!;
//                     break;
//                   case "5":
//                     _answer5 = value!;
//                     break;
//                   case "6":
//                     _answer6 = value!;
//                     break;
//                   case "7":
//                     _answer7 = value!;
//                     break;
//                   case "8":
//                     _answer8 = value!;
//                     break;
//                   default:
//                 }
//               });
//             },
//           ),
//         ),
//       ),
//     ],
//   );
// }
// Radio(
//   activeColor: Colors.yellow,
//   value: 1,
//   groupValue: id,
//   // visualDensity: VisualDensity.adaptivePlatformDensity,
//   onChanged: (val) {
//     print(val);
//     // changeValue();
//     print(listQuestion[0]);
//     // setState(() {
//     //   id = val as int;
//     // });
//   },
// ),
// Row(
//   children: [
//     Theme(
//       data: ThemeData(unselectedWidgetColor: Colors.yellow),
//       child: Radio(
//         activeColor: Colors.yellow,
//         value: 1,
//         groupValue: id,
//         onChanged: (val) {
//           print(val);
//           setState(() {
//             id = val;
//           });
//         },
//       ),
//     ),
//     Text(
//       'By Destiny',
//       style: new TextStyle(fontSize: 17.0),
//     ),
//     Theme(
//       data: ThemeData(
//           unselectedWidgetColor: Colors
//               .yellow), // Changing radio button border color when unselected warping with Theme
//       child: Radio(
//         activeColor: Colors.yellow,
//         value: 2,
//         groupValue: id,
//         onChanged: (val) {
//           print(val);
//           setState(() {
//             id = val;
//           });
//         },
//       ),
//     ),
//     Text(
//       'By Date',
//       style: new TextStyle(
//         fontSize: 17.0,
//       ),
//     ),
//   ],
