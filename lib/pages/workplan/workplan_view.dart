import 'dart:async';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/dropdown_item.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/session_timer.dart';
import 'package:workplan_beta_test/model/parameter_udf_model.dart';
import 'package:workplan_beta_test/model/parameter_udf_option_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/visit_checkin_log_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_list.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_visit_list.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

class WorkplanView extends StatefulWidget {
  final WorkplanInboxData workplan;
  final User user;
  final bool isMaximumUmur;
  final dynamic role;

  const WorkplanView(
      {Key? key,
      required this.workplan,
      required this.user,
      required this.isMaximumUmur,
      required this.role})
      : super(key: key);
  @override
  _WorkplanViewState createState() => _WorkplanViewState();
}

class _WorkplanViewState extends State<WorkplanView> {
  MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);
  final _keyForm = GlobalKey<FormState>();
  DatabaseHelper db = new DatabaseHelper();
  bool loading = false;
  var _udfDateValue = "";

  TextEditingController _udfTextA1Ctr = TextEditingController();
  //  TextEditingController _udfTextA1Ctr = TextEditingController();
  TextEditingController _udfText2Ctr = TextEditingController();
  TextEditingController _udfNum1Ctr = TextEditingController();
  String labelUdfTextA1 = "UDF Text A1";
  String labelUdfTextA2 = "UDF Text A2";
  String labelUdfNumA1 = "UDF Num A1";
  String labelUdfDateA1 = "UDF Date A1";
  String labelUdfDdlA1 = "UDF DDL A1";
  int udfDDLA1 = 0;
  final bool withAsterisk = true;

  late List<ParameterUdfOption> parameterUdfOption1List;
  List<DropdownMenuItem<int>> itemsParameterUdfOption1 =
      <DropdownMenuItem<int>>[];
  int parameterUdfOption1Value = SystemParam.defaultValueOptionId;
  int count = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
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

    getLableUdf();
    checkInTimeOutNotification();

    _udfTextA1Ctr.text = widget.workplan.udfText1;
    _udfText2Ctr.text = widget.workplan.udfText2;
    if (widget.workplan.udfNum1 != null) {
      _udfNum1Ctr.text = widget.workplan.udfNum1.toString();
    }
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WorkplanList(user: widget.user, role: widget.role)));
            return false;
          },
          child: Scaffold(
              //drawer: NavigationDrawerWidget(),
              appBar: AppBar(
                title: Text('View Task'),
                centerTitle: true,
                backgroundColor: colorCustom,
                automaticallyImplyLeading: false,
              ),
              body: Form(
                key: _keyForm,
                // autovalidate: false,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: Reuseable.jarak3),
                        Reuseable.mainTitle("View Master Task"),
                        SizedBox(height: Reuseable.jarak3),
                        Text("No Task", style: Reuseable.titleStyle),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          style: new TextStyle(color: Colors.black),
                          initialValue: widget.workplan.nomorWorkplan,
                          readOnly: true,
                          enabled: false,
                          // validator: validasiUsername,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: InputDecoration(
                            //icon: new Icon(Ionicons.document_outline),
                            fillColor: colorCustom,
                            //labelText: "No Workplan",
                            labelStyle: TextStyle(
                                color: colorCustom,
                                fontStyle: FontStyle.italic),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colorCustom),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colorCustom),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Progress", style: Reuseable.titleStyle),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          style: new TextStyle(color: Colors.black),
                          initialValue:
                              widget.workplan.progresStatusDescription,
                          readOnly: true,
                          enabled: false,
                          // validator: validasiUsername,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: InputDecoration(
                            //icon: new Icon(Ionicons.create_outline),
                            fillColor: colorCustom,
                            //labelText: "Progress",
                            labelStyle: TextStyle(
                                color: colorCustom,
                                fontStyle: FontStyle.normal),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colorCustom),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: colorCustom),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Jenis Aktifitas", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.activityDescription,
                            readOnly: true,
                            enabled: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Nama", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.fullName,
                            readOnly: false,
                            enabled: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text("No HP", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            keyboardType: TextInputType.number,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.phone,
                            readOnly: false,
                            enabled: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak3),
                        Reuseable.mainTitle("Alamat Usaha"),
                        SizedBox(height: Reuseable.jarak3),
                        Text("Nama Lokasi", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.location,
                            readOnly: false,
                            enabled: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Alamat", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.alamat,
                            readOnly: false,
                            enabled: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Kelurahan", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.kelurahan,
                            readOnly: false,
                            enabled: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Kecamatan", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.kecamatan,
                            readOnly: false,
                            enabled: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Kodya/Kabupaten", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            enabled: false,
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.kabupaten,
                            readOnly: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Kode Pos", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            initialValue: widget.workplan.kodepos,
                            readOnly: false,
                            enabled: false,
                            // validator: validasiUsername,
                            onSaved: (em) {
                              if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text("Rencana Kunjungan", style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        DateTimeField(
                            enabled: false,
                            format: SystemParam.formatDateDisplay,
                            initialValue:
                                widget.workplan.rencanaKunjungan == null
                                    ? null
                                    : widget.workplan.rencanaKunjungan,
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate:
                                      widget.workplan.rencanaKunjungan == null
                                          ? null
                                          : widget.workplan.rencanaKunjungan!,
                                  lastDate: DateTime(2100));
                              return date;
                            },
                            decoration: Reuseable.inputDecorationDate),
                        SizedBox(height: Reuseable.jarak2),
                        Text(labelUdfTextA1, style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            enabled: false,
                            controller: _udfTextA1Ctr,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            //initialValue: widget.workplanInboxData.kodepos,
                            readOnly: false,
                            //validator: requiredValidator,
                            onSaved: (em) {
                              //if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text(labelUdfTextA2, style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            enabled: false,
                            controller: _udfText2Ctr,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            style: new TextStyle(color: Colors.black),
                            //initialValue: widget.workplanInboxData.kodepos,
                            readOnly: false,
                            //validator: requiredValidator,
                            onSaved: (em) {
                              //if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text(labelUdfNumA1, style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                            enabled: false,
                            controller: _udfNum1Ctr,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            style: new TextStyle(color: Colors.black),
                            //initialValue: widget.workplanInboxData.kodepos,
                            readOnly: false,
                            //validator: requiredValidator,
                            onSaved: (em) {
                              //if (em != null) {}
                            },
                            decoration: Reuseable.inputDecoration),
                        SizedBox(height: Reuseable.jarak2),
                        Text(labelUdfDateA1, style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        DateTimeField(
                            enabled: false,
                            initialValue: widget.workplan.udfDate1 == null
                                ? null
                                : widget.workplan.udfDate1,
                            autovalidateMode: AutovalidateMode.always,
                            onSaved: (valueDate) {
                              _udfDateValue = SystemParam.formatDateValue
                                  .format(valueDate!);
                            },
                            onChanged: (valueDate) {
                              _udfDateValue = SystemParam.formatDateValue
                                  .format(valueDate!);
                            },
                            format: SystemParam.formatDateDisplay,
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2010),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));
                            },
                            decoration: Reuseable.inputDecorationDate),
                        SizedBox(height: Reuseable.jarak2),
                        Text(labelUdfDdlA1, style: Reuseable.titleStyle),
                        SizedBox(height: Reuseable.jarak1),
                        DropdownButtonFormField<int>(
                          decoration: Reuseable.inputDecoration,
                          value: parameterUdfOption1Value,
                          items: itemsParameterUdfOption1,
                          onChanged: null,
                        ),
                        SizedBox(height: Reuseable.jarak3),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                primary: colorCustom),
                            child: Text("VISIT ACTIVITY"),
                            onPressed: () {
                              // timer!.cancel();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkplanVisitList(
                                        role: widget.role,
                                        workplan: widget.workplan,
                                        user: widget.user,
                                        isMaximumUmur: widget.isMaximumUmur),
                                  ));
                            },
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak3),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                primary: colorCustom),
                            child: Text("DATA TASK"),
                            onPressed: () {
                              // timer!.cancel();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkplanData(
                                        role: widget.role,
                                        user: widget.user,
                                        workplan: widget.workplan,
                                        isMaximumUmur: widget.isMaximumUmur),
                                  ));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ))),
    );
  }

  void initParameterUdfOption1(int udfDDLA1) async {
    loading = true;
    ParameterUdfOptionModel parameterModel;
    var data = {"company_id": widget.user.userCompanyId, "udf_id": udfDDLA1};

    var response = await RestService()
        .restRequestService(SystemParam.fParameterUdfOption1, data);

    setState(() {
      parameterModel =
          parameterUdfOptionModelFromJson(response.body.toString());
      parameterUdfOption1List = parameterModel.data;
      itemsParameterUdfOption1.add(DropdownItem.getItemParameter(
          SystemParam.defaultValueOptionId,
          SystemParam.defaultValueOptionDesc));
      for (var i = 0; i < parameterUdfOption1List.length; i++) {
        itemsParameterUdfOption1.add(DropdownItem.getItemParameter(
            parameterUdfOption1List[i].id,
            parameterUdfOption1List[i].optionDescription));
      }
      loading = false;
    });
  }

  void getLableUdf() async {
    Future<ParameterUdf> parameterUdfTextA1 =
        db.getParameterUdfByName(labelUdfTextA1);
    parameterUdfTextA1.then((data) {
      setState(() {
        labelUdfTextA1 = data.udfDescription;
      });
    });

    Future<ParameterUdf> parameterUdfTextA2 =
        db.getParameterUdfByName(labelUdfTextA2);
    parameterUdfTextA2.then((data) {
      setState(() {
        labelUdfTextA2 = data.udfDescription;
      });
    });

    Future<ParameterUdf> parameterUdfNumA2 =
        db.getParameterUdfByName(labelUdfNumA1);
    parameterUdfNumA2.then((data) {
      setState(() {
        labelUdfNumA1 = data.udfDescription;
      });
    });

    Future<ParameterUdf> parameterUdfDateA1 =
        db.getParameterUdfByName(labelUdfDateA1);
    parameterUdfDateA1.then((data) {
      setState(() {
        labelUdfDateA1 = data.udfDescription;
      });
    });

    Future<ParameterUdf> parameterUdfDdlA1 =
        db.getParameterUdfByName(labelUdfDdlA1);
    parameterUdfDdlA1.then((data) {
      setState(() {
        labelUdfDdlA1 = data.udfDescription;
        udfDDLA1 = data.id;
        // initParameterUdfOption1(udfDDLA1);
        initParameterUdfOptionDB(udfDDLA1);
      });
    });
  }

  void notification(context) {
    showOverlayNotification((context) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: SafeArea(
          child: ListTile(
            leading: SizedBox.fromSize(
                size: const Size(40, 40),
                child: ClipOval(
                    child: Container(
                  color: Colors.black,
                ))),
            //title: Text('Batas Waktu Kunjungan'),
            subtitle: Text(
                'Anda telah melampaui batas waktu kunjungan workplan, Simpan segera selesaikan aktifitas Anda dan lakukan check out'),
            trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  OverlaySupportEntry.of(context)!.dismiss();
                }),
          ),
        ),
      );
    }, duration: Duration(milliseconds: 4000));
  }

  void initParameterUdfOptionDB(udfDDLA1s) async {
    db.getParameterUdfOption1ByUdfId(udfDDLA1s).then((value) {
      setState(() {
        loading = true;
        parameterUdfOption1List = <ParameterUdfOption>[];
        itemsParameterUdfOption1.clear();
        parameterUdfOption1List = value;

        itemsParameterUdfOption1.add(DropdownItem.getItemParameter(
            SystemParam.defaultValueOptionId,
            SystemParam.defaultValueOptionDesc));

        for (var i = 0; i < parameterUdfOption1List.length; i++) {
          itemsParameterUdfOption1.add(DropdownItem.getItemParameter(
              parameterUdfOption1List[i].id,
              parameterUdfOption1List[i].optionDescription));
          if (widget.workplan.udfOpt1 != null &&
              parameterUdfOption1List[i].id == widget.workplan.udfOpt1) {
            parameterUdfOption1Value = widget.workplan.udfOpt1;
          }
        }

        if (widget.workplan.udfOpt1 != null &&
            parameterUdfOption1List.contains(widget.workplan.udfOpt1)) {
          parameterUdfOption1Value = widget.workplan.udfOpt1;
        }

        loading = false;
      });
    });
  }

  Future<void> checkInTimeOutNotification() async {
    var now = DateTime.now();
    await db
        .getVisitCheckInLogListByNoWorkplan(widget.workplan.nomorWorkplan)
        .then((vl) {
      setState(() {
        List<VisitChecInLog> vlData = vl;
        for (var i = 0; i < vlData.length; i++) {
          var checkInBatas = DateTime.parse(vlData[i].checkInBatas);
          if (now.isAfter(checkInBatas)) {
            //print("notif timeout");
            notification(context);
          }
        }
      });
    });
  }
}
