import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/main_pages/landingpage_view.dart';
import 'package:workplan_beta_test/model/personal_info_address_model.dart';
import 'package:workplan_beta_test/model/personal_info_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/pages/profile/contact/profile_contact_address_edit.dart';
import 'package:workplan_beta_test/pages/profile/profile_page.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

class ProfileContact extends StatefulWidget {
  // final
  final User user;
  final PersonalInfoProfilData profile;
  // final Timer timer;

  const ProfileContact(
      {Key? key,
      required this.user,
      required this.profile,
      // required this.timer
      })
      : super(key: key);

  @override
  _ProfileContactState createState() => _ProfileContactState();
}

class _ProfileContactState extends State<ProfileContact> {
  // late String _valGender;
  // List _listGender = ["Male","Female"];  //Array gender
  final _keyForm = GlobalKey<FormState>();
  // final format = DateFormat("yyyy-MM-dd HH:mm:ss");
  // var userId = 1;
  bool enabled = true;
  bool loading = false;

  TextEditingController _facebook = TextEditingController();
  TextEditingController _linkedin = TextEditingController();
  TextEditingController _twitter = TextEditingController();
  TextEditingController _instagram = TextEditingController();

  TextEditingController _contactNoTelponRumah = TextEditingController();
  TextEditingController _contactNoTelponKantor = TextEditingController();
  TextEditingController _contactNoHP = TextEditingController();

  TextEditingController _emergencyNama = TextEditingController();
  TextEditingController _emergencyNoHP = TextEditingController();
  TextEditingController _emergencyHubKeluarga = TextEditingController();
  TextEditingController _emergencyAlamatKeluarga = TextEditingController();

  int addressCount = 0;
  List<PersonalInfoAddress> addressList = <PersonalInfoAddress>[];
  Timer? timer;
  int count = 0;

  @override
  void initState() {
    super.initState();
    // widget.timer.cancel();
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

    getAdressList();

    loading = true;
    loading = false;

    _facebook.text = widget.profile.facebook;
    _linkedin.text = widget.profile.linkedIn;
    _twitter.text = widget.profile.twitter;
    _instagram.text = widget.profile.instagram;

    _contactNoTelponRumah.text = widget.profile.homePhone;
    _contactNoTelponKantor.text = widget.profile.officePhone;
    _contactNoHP.text = widget.profile.phone;

    _emergencyNama.text = widget.profile.emergencyContactName;
    _emergencyNoHP.text = widget.profile.emergencyContactPhone;
    _emergencyHubKeluarga.text = widget.profile.emergencyContactRelationship;
    _emergencyAlamatKeluarga.text = widget.profile.emergencyContactAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        count = 0;
      },
      child: WillPopScope(
          onWillPop: () async {
            timer!.cancel();
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LandingPage(
                    user: widget.user,
                    currentIndex: 1,
                  ),
                ));
            return false;
          },
          child: Scaffold(
              //drawer: NavigationDrawerWidget(),
              appBar: AppBar(
                title: Text('Contact'),
                centerTitle: true,
                backgroundColor: SystemParam.colorCustom,
                automaticallyImplyLeading: false,
                // leading: IconButton(
                //   icon: Icon(Icons.arrow_back, color: Colors.black),
                //   //onPressed: () => Navigator.of(context).pop(),
                //   onPressed: () {
                //     // Navigator.push(
                //     //     context,
                //     //     MaterialPageRoute(
                //     //       builder: (context) => ProfilePage(
                //     //         user: widget.user,
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
                      // autovalidate: false,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Reuseable.mainTitle("Social Media"),
                              Text("Facebook", style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _facebook,
                                  // initialValue: widget.personalInfoProfilData.facebook,
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak2),
                              Text("LinkedIn", style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _linkedin,
                                  //initialValue: "",
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak2),
                              Text("Twitter", style: Reuseable.titleStyle),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _twitter,
                                  //initialValue: "",
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak2),
                              Text("Instagram", style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _instagram,
                                  //initialValue: "",
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak3),
                              Reuseable.mainTitle("Contact"),
                              SizedBox(height: Reuseable.jarak3),
                              Text("Nomor Telepon Rumah",
                                  style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _contactNoTelponRumah,
                                  //initialValue: widget.datum.writtingScore.toString(),
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak2),
                              Text("Nomor Telepon Kantor",
                                  style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _contactNoTelponKantor,
                                  //initialValue: widget.datum.writtingScore.toString(),
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak2),
                              Text("Nomor HP", style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _contactNoHP,
                                  //initialValue: widget.datum.writtingScore.toString(),
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak3),
                              Reuseable.mainTitle("Emergency Contact"),
                              SizedBox(height: Reuseable.jarak3),
                              Text("Nama", style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _emergencyNama,
                                  //initialValue: widget.datum.writtingScore.toString(),
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak2),
                              Text("Nomor HP", style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _emergencyNoHP,
                                  //initialValue: widget.datum.writtingScore.toString(),
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak2),
                              Text("Hubungan Keluarga",
                                  style: Reuseable.titleStyle),
                              SizedBox(height: Reuseable.jarak1),
                              TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  style: new TextStyle(color: Colors.black),
                                  controller: _emergencyHubKeluarga,
                                  //initialValue: widget.datum.writtingScore.toString(),
                                  readOnly: false,
                                  // validator: validasiUsername,
                                  onSaved: (em) {
                                    if (em != null) {}
                                  },
                                  decoration: Reuseable.inputDecoration),
                              SizedBox(height: Reuseable.jarak3),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Reuseable.mainTitle("Alamat Kerja"),
                                  IconButton(
                                      onPressed: () {
                                        timer!.cancel();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileContactAddressEdit(
                                                        user: widget.user,
                                                        addressId: 0,
                                                        profileInfo:
                                                            widget.profile)));
                                      },
                                      icon: Image.asset(
                                          "images/Profile_Menu/add2.png"))
                                ],
                              ),
                              createListViewAddress(),
                              SizedBox(height: Reuseable.jarak3),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: SystemParam.colorCustom,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: Text("UPDATE"),
                                  onPressed: () {
                                    saveDataContact();
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

  void saveDataContact() async {
    // print("KE SAVE DATA");
    //urlWorkplanInboxUpdate
    //var userId = 1;

    var data = {
      "id": widget.profile.id,
      "facebook": _facebook.text,
      "linkedIn": _linkedin.text,
      "twitter": _twitter.text,
      "instagram": _instagram.text,
      "home_phone": _contactNoTelponRumah.text,
      "office_phone": _contactNoTelponKantor.text,
      "phone": _contactNoHP.text,
      "emergency_contact_name": _emergencyNama.text,
      "emergency_contact_phone": _emergencyNoHP.text,
      "emergency_contact_relationship": _emergencyHubKeluarga.text,
      "emergency_contact_address": _emergencyAlamatKeluarga.text
    };

    var response = await RestService()
        .restRequestService(SystemParam.fPersonaInfoContactUpdate, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];

    if (code == "0") {
      timer!.cancel();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LandingPage(
              user: widget.user,
              currentIndex: 1,
            ),
          ));

      Fluttertoast.showToast(
          msg: "Update Data Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: SystemParam.colorCustom,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      print(status);
      Fluttertoast.showToast(
          msg: "Mohon Maaf, Anda Gagal Update Data :",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void getAdressList() async {
    loading = true;
    var data = {
      "user_id": widget.user.id,
    };
    var response = await RestService()
        .restRequestService(SystemParam.fPersonaAddressByUserId, data);

    setState(() {
      PersonalInfoAddressModel model =
          personalInfoAddressModelFromJson(response.body.toString());

      addressCount = model.data.length;
      addressList = model.data;
      loading = false;
    });
  }

  ListView createListViewAddress() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addressCount,
      itemBuilder: (BuildContext context, int index) {
        return customListItemAddress(
          addressList[index],
        );
      },
    );
  }

  customListItemAddress(PersonalInfoAddress we) {
    return Card(
      color: SystemParam.colorbackgroud,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(
              color: SystemParam.colorDivider,
              thickness: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  we.addressName == null ? "" : we.addressName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          timer!.cancel();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileContactAddressEdit(
                                          user: widget.user,
                                          addressId: we.id,
                                          profileInfo: widget.profile)));
                        },
                        child: Icon(Icons.edit_rounded)),
                    GestureDetector(
                        onTap: () {
                          showDeleteDialog(context, we.id,
                              SystemParam.fPersonaAddresUpdateStatus);
                        },
                        child: Icon(Icons.delete_forever))
                  ],
                )
              ],
            ),
            SizedBox(height: Reuseable.jarak1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // ignore: unnecessary_null_comparison
                  we.rtrw == null ? "" : we.rtrw,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                // Icon(Icons.edit),
              ],
            ),
            SizedBox(height: Reuseable.jarak1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // ignore: unnecessary_null_comparison
                  we.kabKotaDesc == null ? "" : we.kabKotaDesc,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                // Icon(Icons.edit),
              ],
            ),
            SizedBox(height: Reuseable.jarak1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // ignore: unnecessary_null_comparison
                  we.kecamatan == null ? "" : we.kecamatan,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                // Icon(Icons.edit),
              ],
            ),
          ],
        ),
      ),
    );
  }

  showDeleteDialog(BuildContext context, int id, function) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("Cancel"),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        primary: Colors.green,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Continue"),
      // style: Elevate,
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          primary: Colors.red),
      onPressed: () {
        updateStatus(id, function);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Konfirmasi Hapus"),
      content: Text("Anda yakin menghapus data ini ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void updateStatus(id, function) async {
    var data = {
      "id": id,
      "updated_by": widget.user.id,
      "status": 0,
    };

    // print(data);
    //String function = SystemParam.fPersonalEducationUpdateStatus;
    var response = await RestService().restRequestService(function, data);

    var convertDataToJson = json.decode(response.body);
    var code = convertDataToJson['code'];
    var status = convertDataToJson['status'];
    // print(status);

    if (code == "0") {
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => ProfileContact(
      //               user: widget.user,
      //               profile: widget.profile,
      //             )));
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
}
