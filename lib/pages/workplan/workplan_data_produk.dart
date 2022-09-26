import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/dropdown_item.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/model/parameter_kategori_produk_model.dart';
import 'package:workplan_beta_test/model/parameter_produk_model.dart';
import 'package:workplan_beta_test/model/parameter_udf_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data.dart';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);

class WorkplanDataProduk extends StatefulWidget {
  final WorkplanInboxData workplan;
  final User user;
  final bool isMaximumUmur;
  final dynamic role;

  const WorkplanDataProduk(
      {Key? key,
      required this.workplan,
      required this.user,
      required this.isMaximumUmur,
      required this.role})
      : super(key: key);

  @override
  _ExampleFormState createState() => _ExampleFormState();
}

class _ExampleFormState extends State<WorkplanDataProduk> {
  //GlobalKey myFormKey = new GlobalKey();
  final myFormKey = GlobalKey<FormState>();

  DatabaseHelper db = new DatabaseHelper();
  bool loading = false;
  bool enabled = false;
  late int myNumber;
  String myValue = 'No value saved yet.';
  String labelUdfTextC1 = "UDF Text C1";
  String labelUdfNumC1 = "UDF Num C1";
  String labelUdfDateC1 = "UDF Date C1";
  var _udfDateC1Value = "";

  TextEditingController _udfTextC1Ctr = TextEditingController();
  TextEditingController _udfNumC1Ctr = TextEditingController();

  List<ParameterKategoriProduk> parameterKategoriProdukList =
      <ParameterKategoriProduk>[];
  List<DropdownMenuItem<int>> itemsParameterKategoriProduk =
      <DropdownMenuItem<int>>[];
  int parameterKategoriProdukValue = SystemParam.defaultValueOptionId;

  List<ParameterProduk> parameterProdukList = <ParameterProduk>[];
  List<DropdownMenuItem<int>> itemsParameterProduk = <DropdownMenuItem<int>>[];
  int parameterProdukValue = SystemParam.defaultValueOptionId;

  // CurrencyTextInputFormatter _formatterCurrency = CurrencyTextInputFormatter(locale: 'id',symbol: '');

  TextEditingController _nominalTransaksiCtrl = new TextEditingController();
  final requiredValidator =
      RequiredValidator(errorText: 'this field is required');

  late WorkplanInboxData _workplan;
  int count = 0;
  Timer? timer;

  // DatabaseHelper db = new DatabaseHelper();

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

    _workplan = widget.workplan;
    initParameterKategoriProdukDB();

    setState(() {
      if (widget.workplan.nominalTransaksi != null &&
          widget.workplan.nominalTransaksi != "") {
        // _nominalTransaksiCtrl.text =_formatterCurrency.format(widget.workplan.nominalTransaksi.toString()+'00');
        _nominalTransaksiCtrl.text =
            widget.workplan.nominalTransaksi.toString();
      }

      if (widget.workplan.udfTextC1 != null) {
        _udfTextC1Ctr.text = widget.workplan.udfTextC1;
      }

      if (widget.workplan.udfNumC1 != null) {
        _udfNumC1Ctr.text = widget.workplan.udfNumC1.toString();
      }

      if (widget.workplan.udfDateC1 != null) {
        _udfDateC1Value =
            SystemParam.formatDateValue.format(widget.workplan.udfDateC1);
      }

      print("IS CHECK IN ${widget.workplan.isCheckIn}");
      print("progres Status Id Alter ${widget.workplan.progresStatusIdAlter}");

      if (widget.workplan.isCheckIn == "1" &&
          (widget.workplan.progresStatusIdAlter == 2 ||
              widget.workplan.progresStatusIdAlter == 4)) {
        print('data bisa di click');
        enabled = true;
      } else {
        print('data TIDAK BISA di click');
        enabled = false;
      }
    });

    getLableUdf();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
        // count = 0;
      },
      child: WillPopScope(
          onWillPop: () async {
            // timer!.cancel();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkplanData(
                      role: widget.role,
                      workplan: widget.workplan,
                      user: widget.user,
                      isMaximumUmur: widget.isMaximumUmur),
                ));
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Produk'),
              centerTitle: true,
              backgroundColor: colorCustom,
              automaticallyImplyLeading: false,
            ),
            body: loading == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Form(
                      key: myFormKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(
                          // mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Kategori Produk',
                                      style: Reuseable.titleStyle),
                                  TextSpan(
                                      text: ' * ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                          color: Colors.red)),
                                ],
                              ),
                            ),
                            DropdownButtonFormField<int>(
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.black),
                              decoration: Reuseable.inputDecoration,
                              validator: (value) {
                                //print("validaor select:" + value.toString());
                                if (value == 0) {
                                  return "this field is required";
                                }
                                return null;
                              },
                              value: parameterKategoriProdukValue,
                              items: itemsParameterKategoriProduk,
                              onChanged: !enabled
                                  ? null
                                  : (object) {
                                      setState(() {
                                        parameterKategoriProdukValue = object!;
                                        //
                                        initParameterProdukDB(
                                            parameterKategoriProdukValue);
                                      });
                                    },
                            ),
                            SizedBox(height: Reuseable.jarak2),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Jenis Produk',
                                      style: Reuseable.titleStyle),
                                  TextSpan(
                                      text: ' * ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          // backgroundColor: Theme.of(context) .scaffoldBackgroundColor,
                                          color: Colors.red)),
                                ],
                              ),
                            ),
                            DropdownButtonFormField<int>(
                              decoration: Reuseable.inputDecoration,
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Colors.black),
                              validator: (value) {
                                //print("validaor select:" + value.toString());
                                if (value == 0) {
                                  return "this field is required";
                                }
                                return null;
                              },
                              value: parameterProdukValue,
                              items: itemsParameterProduk,
                              onChanged: !enabled
                                  ? null
                                  : (object) {
                                      setState(() {
                                        parameterProdukValue = object!;
                                      });
                                    },
                            ),
                            SizedBox(height: Reuseable.jarak2),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Nominal Transaksi',
                                      style: Reuseable.titleStyle),
                                  TextSpan(
                                      text: ' * ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                          color: Colors.red)),
                                ],
                              ),
                            ),
                            TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: _nominalTransaksiCtrl,
                                validator: requiredValidator,
                                textInputAction: TextInputAction.next,
                                // inputFormatters: [_formatterCurrency],
                                keyboardType: TextInputType.number,
                                style: new TextStyle(color: Colors.black),
                                readOnly: false,
                                enabled: enabled,
                                decoration: Reuseable.inputDecoration),
                            SizedBox(height: Reuseable.jarak2),
                            Text(labelUdfTextC1, style: Reuseable.titleStyle),
                            TextFormField(
                                controller: _udfTextC1Ctr,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                style: new TextStyle(color: Colors.black),
                                //initialValue: widget.workplanInboxData.kodepos,
                                readOnly: false,
                                //validator: requiredValidator,
                                onSaved: (em) {
                                  //if (em != null) {}
                                },
                                enabled: enabled,
                                decoration: Reuseable.inputDecoration),
                            SizedBox(height: Reuseable.jarak2),
                            Text(labelUdfNumC1, style: Reuseable.titleStyle),
                            TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: _udfNumC1Ctr,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                // maxLength: 16,
                                style: new TextStyle(color: Colors.black),
                                //initialValue: widget.workplanInboxData.kodepos,
                                readOnly: false,
                                //validator: requiredValidator,
                                onSaved: (em) {
                                  //if (em != null) {}
                                },
                                enabled: enabled,
                                maxLength: 15,
                                decoration: Reuseable.inputDecoration),
                            SizedBox(height: Reuseable.jarak2),
                            Text(labelUdfDateC1, style: Reuseable.titleStyle),
                            DateTimeField(
                                autovalidateMode: AutovalidateMode.always,
                                onSaved: (valueDate) {
                                  _udfDateC1Value = SystemParam.formatDateValue
                                      .format(valueDate!);
                                },
                                onChanged: (valueDate) {
                                  _udfDateC1Value = SystemParam.formatDateValue
                                      .format(valueDate!);
                                },
                                enabled: enabled,
                                format: SystemParam.formatDateDisplay,
                                initialValue: widget.workplan.udfDateC1 != null
                                    ? widget.workplan.udfDateC1
                                    : null,
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                      context: context,
                                      locale: Locale('id'),
                                      firstDate:
                                          DateTime(SystemParam.firstDate),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime(SystemParam.lastDate),
                                      fieldHintText:
                                          SystemParam.strFormatDateHint);
                                },
                                decoration: Reuseable.inputDecorationDate),
                            SizedBox(height: Reuseable.jarak3),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: colorCustom,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text("SIMPAN"),
                                onPressed: !enabled
                                    ? null
                                    : () {
                                        if (myFormKey.currentState!
                                            .validate()) {
                                          saveData();
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          )),
    );
  }

  void initParameterKategoriProdukDB() async {
    // print("parameterKategoriProdukList:");
    db
        .getParameterKategoriProdukByActivityId(
            widget.workplan.activityId.toString())
        .then((data) {
      setState(() {
        itemsParameterKategoriProduk.clear();
        parameterKategoriProdukList = <ParameterKategoriProduk>[];
        loading = true;
        parameterKategoriProdukList = data;
        print('data kategori produk <<<<<<<<=======');
        print(parameterKategoriProdukList);
        itemsParameterKategoriProduk.add(DropdownItem.getItemParameter(
            SystemParam.defaultValueOptionId,
            SystemParam.defaultValueOptionDesc));
        for (var i = 0; i < parameterKategoriProdukList.length; i++) {
          itemsParameterKategoriProduk.add(DropdownItem.getItemParameter(
              parameterKategoriProdukList[i].id,
              parameterKategoriProdukList[i].description));

          if (widget.workplan.kategoriProdukId != null &&
              parameterKategoriProdukList[i].id ==
                  widget.workplan.kategoriProdukId) {
            parameterKategoriProdukValue = widget.workplan.kategoriProdukId;
            initParameterProdukDB(parameterKategoriProdukValue);
          }
        }

        print(itemsParameterKategoriProduk);

        if (widget.workplan.kategoriProdukId != null &&
            parameterKategoriProdukList
                .contains(widget.workplan.kategoriProdukId)) {
          parameterKategoriProdukValue = widget.workplan.kategoriProdukId;
          initParameterProdukDB(parameterKategoriProdukValue);
        }

        loading = false;
      });
    });
  }

  // void initParameterKategoriProduk() async {
  //   itemsParameterKategoriProduk.clear();
  //   parameterKategoriProdukList = <ParameterKategoriProduk>[];
  //   loading = true;
  //   ParameterKategoriProdukModel parameterModel;
  //   var data = {
  //     "company_id": widget.user.companyId,
  //     "activity_id": widget.workplan.activityId
  //   };

  //   var response = await RestService()
  //       .restRequestService(SystemParam.fParameterKategoriProduk, data);

  //   setState(() {
  //     parameterModel =
  //         parameterKategoriProdukModelFromJson(response.body.toString());
  //     parameterKategoriProdukList = parameterModel.data;
  //     itemsParameterKategoriProduk.add(DropdownItem.getItemParameter(
  //         SystemParam.defaultValueOptionId,
  //         SystemParam.defaultValueOptionDesc));
  //     for (var i = 0; i < parameterKategoriProdukList.length; i++) {
  //       itemsParameterKategoriProduk.add(DropdownItem.getItemParameter(
  //           parameterKategoriProdukList[i].id,
  //           parameterKategoriProdukList[i].description));

  //       if (widget.workplan.kategoriProdukId != null &&
  //           parameterKategoriProdukList[i].id ==
  //               widget.workplan.kategoriProdukId) {
  //         parameterKategoriProdukValue = widget.workplan.kategoriProdukId;
  //       }
  //     }
  //     loading = false;
  //   });
  // }

  initParameterProdukDB(int kategori) {
    setState(() {
      //loading = true;
      itemsParameterProduk.clear();
      parameterProdukList = <ParameterProduk>[];
      parameterProdukValue = SystemParam.defaultValueOptionId;
    });

    db.getParameterProdukByKategoriId(kategori.toString()).then((data) {
      setState(() {
        //parameterProdukValue = SystemParam.defaultValueOptionId;
        // parameterProdukValue = SystemParam.defaultValueOptionId;
        parameterProdukList = data;

        itemsParameterProduk.add(DropdownItem.getItemParameter(
            SystemParam.defaultValueOptionId,
            SystemParam.defaultValueOptionDesc));
        for (var i = 0; i < parameterProdukList.length; i++) {
          //print("parameterProdukList[i].description:"+parameterProdukList[i].description);
          itemsParameterProduk.add(DropdownItem.getItemParameter(
              parameterProdukList[i].id, parameterProdukList[i].description));
          // itemsParameterProduk.sel
          print("widget.workplan.jenisProdukId :" +
              widget.workplan.jenisProdukId.toString() +
              "-" +
              parameterProdukList[i].id.toString());
          if (widget.workplan.jenisProdukId != null &&
              parameterProdukList[i].id.toString() ==
                  widget.workplan.jenisProdukId.toString()) {
            parameterProdukValue =
                int.parse(widget.workplan.jenisProdukId.toString());
          }
        }

        // if (widget.workplan.jenisProdukId != null && parameterProdukList.contains(widget.workplan.jenisProdukId)) {
        //     parameterProdukValue = widget.workplan.jenisProdukId;
        //   }
      });
    });
  }

  // void initParameterProduk(int val) async {
  //   itemsParameterProduk.clear();
  //   parameterProdukList = <ParameterProduk>[];
  //   parameterProdukValue = SystemParam.defaultValueOptionId;

  //   loading = true;
  //   ParameterProdukModel parameterModel;
  //   var data = {"company_id": widget.user.companyId, "kategori_produk_id": val};

  //   print(data);

  //   var response = await RestService()
  //       .restRequestService(SystemParam.fParameterProduk, data);

  //   print(response.toString());
  //   setState(() {
  //     parameterModel = parameterProdukModelFromJson(response.body.toString());
  //     parameterProdukList = parameterModel.data;

  //     itemsParameterProduk.add(DropdownItem.getItemParameter(
  //         SystemParam.defaultValueOptionId,
  //         SystemParam.defaultValueOptionDesc));
  //     for (var i = 0; i < parameterProdukList.length; i++) {
  //       itemsParameterProduk.add(DropdownItem.getItemParameter(
  //           parameterProdukList[i].id, parameterProdukList[i].description));

  //       if (widget.workplan.jenisProdukId != null &&
  //           parameterProdukList[i].id == widget.workplan.jenisProdukId) {
  //         parameterProdukValue = widget.workplan.jenisProdukId;
  //       }
  //     }

  //     loading = false;
  //   });
  // }

  void saveData() async {
    if (widget.role['isAdd'] == 0) {
      Warning.showWarning(SystemParam.addNotAllowed);
      return;
    }
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // print('connected');
        saveDataOnline();
      }
    } on SocketException catch (_) {
      Warning.showWarning(SystemParam.noInternet);
    }
  }

  void getLableUdf() async {
    Future<ParameterUdf> parameterUdfTextC1 =
        db.getParameterUdfByName(labelUdfTextC1);
    parameterUdfTextC1.then((data) {
      setState(() {
        labelUdfTextC1 = data.udfDescription;
      });
    });

    Future<ParameterUdf> parameterUdfNumC1 =
        db.getParameterUdfByName(labelUdfNumC1);
    parameterUdfNumC1.then((data) {
      setState(() {
        labelUdfNumC1 = data.udfDescription;
      });
    });

    Future<ParameterUdf> parameterUdfDateC1 =
        db.getParameterUdfByName(labelUdfDateC1);
    parameterUdfDateC1.then((data) {
      setState(() {
        labelUdfDateC1 = data.udfDescription;
      });
    });
  }

  void saveDataOnline() async {
    // final nominalTransaksi = _nominalTransaksiCtrl(decimalSeparator: '.', thousandSeparator: ',');
    var data = {
      "id": widget.workplan.id,
      "updated_by": widget.user.id,
      "kategori_produk_id": parameterKategoriProdukValue,
      "jenis_produk_id": parameterProdukValue,
      "nominal_transaksi": _nominalTransaksiCtrl.text,
      "udf_text_c1": _udfTextC1Ctr.text,
      "udf_num_c1": _udfNumC1Ctr.text,
      "udf_date_c1": _udfDateC1Value,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fWorkplanProdukUpdate, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    // print(status);

    if (code == "0") {
      // timer!.cancel();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WorkplanData(
                  role: widget.role,
                  workplan: widget.workplan,
                  user: widget.user,
                  isMaximumUmur: widget.isMaximumUmur)));
    } else {
      Fluttertoast.showToast(
          msg: status,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void saveDataOffline() async {
    _workplan.kategoriProdukId = parameterKategoriProdukValue;
    _workplan.jenisProdukId = parameterProdukValue;
    _workplan.nominalTransaksi = _nominalTransaksiCtrl.text;
    _workplan.udfTextC1 = _udfTextC1Ctr.text;
    _workplan.udfNumC1 = _udfNumC1Ctr.text;
    _workplan.udfDateC1 = _udfDateC1Value;
    _workplan.flagUpdateProduk = 1;

    db.updateWorkplanActivity(_workplan);

    Fluttertoast.showToast(
        msg: "Data tersimpan secara offline",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WorkplanData(
                role: widget.role,
                workplan: widget.workplan,
                user: widget.user,
                isMaximumUmur: widget.isMaximumUmur)));
  }
}
