import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/dropdown_item.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/model/personal_address_model.dart';
import 'package:workplan_beta_test/model/personal_info_model.dart';
import 'package:workplan_beta_test/model/region_by_type.dart';
import 'package:workplan_beta_test/model/region_kabkota_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/profile/contact/profile_contact.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

class ProfileContactAddressEdit extends StatefulWidget {
  final User user;
  final PersonalInfoProfilData profileInfo;
  final int addressId;

  const ProfileContactAddressEdit(
      {Key? key,
      required this.user,
      required this.profileInfo,
      required this.addressId})
      : super(key: key);

  @override
  _ProfileContactAddressEditState createState() =>
      _ProfileContactAddressEditState();
}

class _ProfileContactAddressEditState extends State<ProfileContactAddressEdit> {
  bool loading = false;

  late List<RegionByType> regionProvinsiTypeList;
  List<DropdownMenuItem<int>> itemsRegionProvinsiType =
      <DropdownMenuItem<int>>[];
  int regionProvinsiTypeValue = SystemParam.defaultValueOptionId;

  late List<RegionKabKota> regionKabKotaTypeList;
  List<DropdownMenuItem<int>> itemsRegionKabKotaType =
      <DropdownMenuItem<int>>[];
  int regionKabKotaTypeValue = SystemParam.defaultValueOptionId;

  final requiredValidator =
      RequiredValidator(errorText: 'this field is required');

  TextEditingController _namaJalan = new TextEditingController();
  TextEditingController _kelurahan = new TextEditingController();
  TextEditingController _kecamatan = new TextEditingController();
  TextEditingController _kabupatenKota = new TextEditingController();
  TextEditingController _kodePos = new TextEditingController();
  TextEditingController _rtrw = new TextEditingController();

  final _keyForm = GlobalKey<FormState>();
  Timer? timer;
  int count = 0;

  @override
  void initState() {
    // loading = true;
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      int? limit = widget.user.timeoutLogin * 60;
      print('ini limit time logout nhya');
      print(limit);
      if (count < limit) {
        print(count);
        setState(() {
          count++;
        });
      } else {
        timer.cancel();
        Helper.updateIsLogin(widget.user, 0);
        Navigator.of(context).pushNamedAndRemoveUntil(
            loginScreen, (Route<dynamic> route) => false);
      }
    });
    //initRegionProvinsi();
    if (widget.addressId != 0) {
      getAddress();
    }

    // print("regionKabKotaTypeValue");
    // print(regionKabKotaTypeValue);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        count = 0;
      },
      child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileContact(
                    user: widget.user,
                    profile: widget.profileInfo,/*timer: timer!*/
                  ),
                ));
            return false;
          },
          child: Scaffold(
              //drawer: NavigationDrawerWidget(),
              appBar: AppBar(
                title: Text('Address Add/ Edit'),
                centerTitle: true,
                backgroundColor: SystemParam.colorCustom,
                automaticallyImplyLeading: false
                // leading: IconButton(
                //   icon: Icon(Icons.arrow_back, color: Colors.black),
                //   //onPressed: () => Navigator.of(context).pop(),
                //   onPressed: () {
                //     // Navigator.push(
                //     //     context,
                //     //     MaterialPageRoute(
                //     //       builder: (context) => ProfileContact(
                //     //         user: widget.user,
                //     //         profile: widget.profileInfo,
                //     //       ),
                //     //     ));
                //   },
                // ),
              ),
              body: loading == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Form(
                      key: _keyForm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:20, vertical:20),
                        child: ListView(
                          shrinkWrap: true,
                          reverse: true,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Alamat (Nama Jalan)',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _namaJalan,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'RT/RW',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _rtrw,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Kelurahan',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _kelurahan,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Kecamatan',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _kecamatan,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 10.0, left: 8.0),
                        //   child: RichText(
                        //     text: TextSpan(
                        //       children: <TextSpan>[
                        //         TextSpan(
                        //             text: 'Provinsi',
                        //             style: TextStyle(
                        //                 backgroundColor: Theme.of(context)
                        //                     .scaffoldBackgroundColor,
                        //                 color: SystemParam.colorCustom,
                        //                 fontWeight: FontWeight.w400,
                        //                 fontSize: 14)),
                        //         TextSpan(
                        //             text: '*',
                        //             style: TextStyle(
                        //                 fontWeight: FontWeight.w500,
                        //                 fontSize: 14,
                        //                 backgroundColor: Theme.of(context)
                        //                     .scaffoldBackgroundColor,
                        //                 color: Colors.red)),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: DropdownButtonFormField<int>(
                        //     decoration: InputDecoration(
                        //       fillColor: SystemParam.colorCustom,
                        //       labelStyle: TextStyle(
                        //           color: SystemParam.colorCustom,
                        //           fontStyle: FontStyle.normal),
                        //       enabledBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //               color: SystemParam.colorCustom),
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(10))),
                        //       focusedBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(
                        //               color: SystemParam.colorCustom),
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(10))),
                        //       contentPadding: EdgeInsets.all(10),
                        //     ),
                        //     validator: (value) {
                        //       // print("validator select:" + value.toString());
                        //       // ignore: unrelated_type_equality_checks
                        //       if (value == 0 || value == null) {
                        //         return "this field is required";
                        //       }
                        //       return null;
                        //     },
                        //     value: regionProvinsiTypeValue,
                        //     items: itemsRegionProvinsiType,
                        //     onChanged: (object) {
                        //       setState(() {
                        //         regionProvinsiTypeValue = object!;
                        //         regionKabKota(regionProvinsiTypeValue);
                        //       });
                        //     },
                        //   ),
                        // ),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Kodya / Kabupaten',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' * ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _kabupatenKota,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak2),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Kode Pos',
                                  style: Reuseable.titleStyle),
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak1),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          style: new TextStyle(color: Colors.black),
                          controller: _kodePos,
                          readOnly: false,
                          validator: requiredValidator,
                          onSaved: (em) {
                            if (em != null) {}
                          },
                          decoration: Reuseable.inputDecoration
                        ),
                        SizedBox(height: Reuseable.jarak3),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                primary: SystemParam.colorCustom),
                            child: Text("SIMPAN"),
                            onPressed: () {
                              if (_keyForm.currentState!.validate()) {
                                saveData();
                              }
                            },
                          ),
                        )
                          ].reversed.toList(),
                        ),
                      ),),),),
    );
  }

  void getAddress() async {
    //fPersonalWorkExperienceById
    var data = {
      "id": widget.addressId,
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonaAddressById, data);

    setState(() {
      // print("RESPONINI");
      // print(response.body.toString());

      PersonalAddressModel model =
          personalAddressModelFromJson(response.body.toString());

      if (model.data.length > 0) {
        PersonalAddress address = model.data[0];
        _namaJalan.text = address.addressName;
        _kelurahan.text = address.kelurahan;
        _kecamatan.text = address.kecamatan;
        // regionProvinsiTypeValue = address.provinceId;
        // regionKabKotaTypeValue = address.kabKotaId;
        _kodePos.text = address.kodepos;
        _kabupatenKota.text = address.kabKotaDesc;
        _rtrw.text=address.rtrw;

        //regionKabKota(regionProvinsiTypeValue);
      }

      // loading = false;
    });
  }

  void initRegionProvinsi() async {
    itemsRegionProvinsiType.clear();
    regionProvinsiTypeList = <RegionByType>[];
    // loading = true;
    RegionByTypeModel regionByTypeModel;
    var data = {
      "region_type": 1,
    };

    var response =
        await RestService().restRequestService(SystemParam.fRegionByType, data);

    setState(() {
      regionByTypeModel = regionByTypeModelFromJson(response.body.toString());
      regionProvinsiTypeList = regionByTypeModel.data;
      itemsRegionProvinsiType.add(DropdownItem.getItemParameter(
          SystemParam.defaultValueOptionId,
          SystemParam.defaultValueOptionDesc));
      for (var i = 0; i < regionProvinsiTypeList.length; i++) {
        itemsRegionProvinsiType.add(DropdownItem.getItemParameter(
            regionProvinsiTypeList[i].regionCode,
            regionProvinsiTypeList[i].regionName));
      }

      loading = false;
    });
  }

  void saveData() async {
    var data = {
      "id": widget.addressId,
      "user_id": widget.user.id,
      "created_by": widget.user.id,
      // "province_id": regionProvinsiTypeValue,
      // "kab_kota_id": regionKabKotaTypeValue,
      "kab_kota_desc" : _kabupatenKota.text,
      "kecamatan": _kecamatan.text,
      "kelurahan": _kelurahan.text,
      "kodepos": _kodePos.text,
      "address_name": _namaJalan.text,
      "address": _namaJalan.text,
      "rtrw":_rtrw.text
    };

    String function = SystemParam.fPersonaAddressCreate;
    if (widget.addressId != 0) {
      function = SystemParam.fPersonaAddresUpdate;
    }

    var response = await RestService().restRequestService(function, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    // print(status);

    if (code == "0") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileContact(
                    user: widget.user,
                    profile: widget.profileInfo, /*timer: timer!*/
                  )));
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

  Future<void> regionKabKota(int regionProvinsiTypeValue) async {
    itemsRegionKabKotaType.clear();
    regionKabKotaTypeList = <RegionKabKota>[];
    // loading = true;
    RegionKabKotaModel regionKabKotaModel;
    var data = {"region_type": 2, "region_parent_id": regionProvinsiTypeValue};
    // print("DATA KABKOTA");
    // print(data);
    var response = await RestService()
        .restRequestService(SystemParam.fRegionKabKota, data);

    setState(() {
      regionKabKotaModel = regionKabKotaModelFromJson(response.body.toString());
      regionKabKotaTypeList = regionKabKotaModel.data;
      itemsRegionKabKotaType.add(DropdownItem.getItemParameter(
          SystemParam.defaultValueOptionId,
          SystemParam.defaultValueOptionDesc));
      for (var i = 0; i < regionKabKotaTypeList.length; i++) {
        itemsRegionKabKotaType.add(DropdownItem.getItemParameter(
            regionKabKotaTypeList[i].regionCode,
            regionKabKotaTypeList[i].regionName));
      }

      loading = false;
    });
  }
}
