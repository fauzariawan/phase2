import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/main_pages/attendance/attendance.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

class ClockOutDone extends StatefulWidget {
  final User user;
  final String keterangan1;
  final String keterangan2;
  final dynamic role;
  const ClockOutDone(
      {required this.keterangan2,
      required this.keterangan1,
      required this.user,
      Key? key,
      required this.role})
      : super(key: key);

  @override
  State<ClockOutDone> createState() => _ClockOutDoneState();
}

class _ClockOutDoneState extends State<ClockOutDone> {
  @override
  bool positifAktif = false;
  bool negatifAktif = true;
  String chipSelected = '';
  TextEditingController someNote = TextEditingController();
  int _selectedIndex = 0;
  List<String> feelPositif = [
    'Happy',
    'Enjoy',
    'Love',
    "Fantastic",
    "Magnificent",
    "Resolute",
    "Cheerful",
    "Satisfied"
  ];

  List<String> feelNegatif = [
    'Exhausted',
    'Ashamed',
    'Tired',
    'Demoralized',
    'Disgusted',
    'Jealous',
    'Sad',
    'Egocentric',
    'Anxious',
    'Frustated',
    'Disappointed',
    'Guilty',
    'Insacure',
    'Embarrassed',
    'Panicked'
  ];

  Widget _buildChips(List<String> feel) {
    List<Widget> chips = [];

    for (int i = 0; i < feel.length; i++) {
      ChoiceChip choiceChip = ChoiceChip(
        // padding: EdgeInsets.only(right: 5),
        selected: chipSelected == ''
            ? false
            : chipSelected != '' && _selectedIndex == i
                ? true
                : false,
        label: Text(feel[i], style: TextStyle(color: Colors.white)),
        elevation: 3,
        pressElevation: 5,
        backgroundColor: Colors.grey[400],
        selectedColor: Colors.lightGreen,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedIndex = i;
              chipSelected = feel[i];
            }
          });
        },
      );
      chips.add(Padding(
        padding: const EdgeInsets.only(right: 5),
        child: choiceChip,
      ));
    }
    return Wrap(
      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: chips,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('How your day ?'), centerTitle: true, elevation: 0),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container(
                //   padding: EdgeInsets.only(bottom: 20),
                //   color: SystemParam.colorCustom,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Image.asset("images/Attandance/emot1.png"),
                //       SizedBox(
                //         width: 10,
                //       ),
                //       Image.asset("images/Attandance/emot2.png"),
                //       SizedBox(
                //         width: 10,
                //       ),
                //       Image.asset("images/Attandance/emot3.png"),
                //       SizedBox(
                //         width: 10,
                //       ),
                //       Image.asset("images/Attandance/emot4.png"),
                //       SizedBox(
                //         width: 10,
                //       ),
                //       Image.asset("images/Attandance/emot5.png"),
                //     ],
                //   ),
                // ),
                SizedBox(height: 20),
                Text("I'm Feeling..."),
                SizedBox(height: 20),
                Container(
                  padding:
                      EdgeInsets.only(bottom: 10, top: 0, left: 10, right: 10),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset(2, 3),
                        spreadRadius: 2,
                        blurRadius: 10)
                  ]),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: negatifAktif
                                      ? Colors.amber
                                      : Colors.white,
                                  elevation: negatifAktif ? 10 : 0),
                              onPressed: () {
                                if (negatifAktif) {
                                  setState(() {
                                    negatifAktif = false;
                                    positifAktif = true;
                                  });
                                } else {
                                  setState(() {
                                    negatifAktif = true;
                                    positifAktif = false;
                                  });
                                }
                              },
                              child: Text(
                                'Negative',
                                style: TextStyle(
                                  color:
                                      negatifAktif ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: positifAktif
                                          ? Colors.amber
                                          : Colors.white,
                                      elevation: positifAktif ? 10 : 0),
                                  onPressed: () {
                                    if (positifAktif) {
                                      setState(() {
                                        positifAktif = false;
                                        negatifAktif = true;
                                      });
                                    } else {
                                      setState(() {
                                        positifAktif = true;
                                        negatifAktif = false;
                                      });
                                    }
                                  },
                                  child: Text(
                                    'Positive',
                                    style: TextStyle(
                                      color: positifAktif
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  )))
                        ],
                      ),
                      if (positifAktif) _buildChips(feelPositif),
                      if (negatifAktif) _buildChips(feelNegatif),
                    ],
                  ),
                ),
                SizedBox(height: Reuseable.jarak3),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextFormField(
                    controller: someNote,
                    onChanged: (someNote) {
                      print(someNote);
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          ("Add some note here to describe your feelings"),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
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
                ),
                // TextFormField(
                //   decoration: InputDecoration(
                //       hintText: "Add some note here to describe your feelings"),
                // ),
                SizedBox(height: Reuseable.jarak3),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (chipSelected == '') {
                          Warning.showWarning('Pilih Feel Terlebih Dahulu');
                          return;
                        }
                        print(chipSelected);
                        print(someNote.text);
                        var data = {
                          "company_id": widget.user.userCompanyId,
                          "description_1": widget.keterangan1,
                          "description_2": widget.keterangan2,
                          "feeling": positifAktif ? "Positive" : "Negative",
                          "detail_feeling": chipSelected,
                          "note_feeling": someNote.text
                        };
                        print(data);
                        var path = SystemParam.clockOutFeeling +
                            "/" +
                            widget.user.id.toString();
                        var response =
                            await RestService().restRequestService(path, data);

                        var convertDataToJson = json.decode(response.body);

                        if (convertDataToJson["code"] == "0" &&
                            convertDataToJson["status"] == "Success") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Attendance(
                                role: widget.role,
                                user: widget.user,
                              ),
                            ),
                          );
                        } else {
                          Warning.showWarning(convertDataToJson["status"]);
                        }
                      },
                      child: Text("Done")),
                )
              ],
            ),
          ),
        ));
  }

  emotion(
    String emotion1,
    String emotion2,
    String emotion3,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [Text(emotion1), Text(emotion2), Text(emotion3)],
    );
  }

  // Widget feel(String feel, Function selected) {

  //   return GestureDetector(
  //       onTap: (){

  //       },
  //       child: Chip(
  //         backgroundColor: selected ? SystemParam.colorCustom : ,
  //         label: Text(feel)));
  // }

}
