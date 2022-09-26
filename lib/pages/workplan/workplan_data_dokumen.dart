import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/model/parameter_dokumen_workplan_mapping.dart';
import 'package:workplan_beta_test/model/parameter_mapping_aktifitas_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data_dokumen_take_picture.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data_dokumen_detail.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';

MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);

class WorkplanDataDokumen extends StatefulWidget {
  final WorkplanInboxData workplan;
  final User user;
  final String title;
  final bool isMaximumUmur;
  final dynamic role;

  const WorkplanDataDokumen(
      {Key? key,
      required this.workplan,
      required this.user,
      required this.title,
      required this.isMaximumUmur, required this.role})
      : super(key: key);

  @override
  _WorkplanDataDokumentate createState() => _WorkplanDataDokumentate();
}

class _WorkplanDataDokumentate extends State<WorkplanDataDokumen> {
  bool loading = false;
  bool enabled = false;
  // late List<ParameterDokumen> parameterDokumenList;
  List<ParameterDokumenWorkplanMappingData> parameterDokumenWorkplanList =
      <ParameterDokumenWorkplanMappingData>[];
  List<ParameterMappingAktifitas> parameterMappingActivityList =
      <ParameterMappingAktifitas>[];

  var db = new DatabaseHelper();
  bool isOnline = false;
  int count = 0;
  Timer? timer;
  String _s3Url = "";
  List<ImageProvider> imageToView = [];

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
    initS3Url();
    if (widget.workplan.isCheckIn == "1" &&
        (widget.workplan.progresStatusIdAlter == 2 ||
            widget.workplan.progresStatusIdAlter == 4)) {
      enabled = true;
    } else {
      enabled = false;
    }
  }

  initS3Url() async {
    db.getEnvByName(SystemParam.EnvAWS).then(
      (value) {
        setState(
          () {
            loading = true;
            _s3Url = value.value;
            loading = false;
          },
        );
        initParameterDokumen();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final photos = <File>[];
    // final size = MediaQuery.of(context).size;
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
            //drawer: NavigationDrawerWidget(),
            appBar: AppBar(
              title: Text('Dokumen'),
              centerTitle: true,
              backgroundColor: colorCustom,
              automaticallyImplyLeading: false,
            ),
            body: loading == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : isOnline
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: createListViewOnline(),
                      )
                    : Center(
                        child: Text('No Internet Connection'),
                      ),
          ),
        ) //createListViewOffline())),
        );
  }

  void initParameterDokumen() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        loading = true;
        isOnline = true;
        ParameterDokumenWorkplanMapping parameterModel;
        var data = {
          "company_id": widget.user.userCompanyId,
          "workplan_activity_id": widget.workplan.id,
          "product_id": widget.workplan.jenisProdukId
        };

        var response = await RestService().restRequestService(
            SystemParam.fParameterDokumenWorkplanMapping, data);
        print('ini parameter dokument <<<<<<<<<=========');
        print(response.body);
        setState(() {
          parameterModel =
              parameterDokumenWorkplanMappingFromJson(response.body.toString());
          parameterDokumenWorkplanList = parameterModel.data;
          loading = false;
        });

        for (var i = 0; i < parameterDokumenWorkplanList.length; i++) {
          String dokumen = parameterDokumenWorkplanList[i].dokumen;
          print(parameterDokumenWorkplanList[i].dokumen);
          String dokumenPath = parameterDokumenWorkplanList[i].dokumen == null
              ? ""
              : _s3Url + "/" + dokumen;
          parameterDokumenWorkplanList[i].dokumen = dokumenPath;
          print(parameterDokumenWorkplanList[i].dokumen);
          Image gambar = parameterDokumenWorkplanList[i].dokumen == null
              ? Image.asset('images/Menu_Task/List_Task/Camera.png')
              : Image.network(parameterDokumenWorkplanList[i].dokumen);
          imageToView.add(gambar.image);
        }
        print(
            "ini gambar yang mau di tampilin <<<<<<<<<<<<<<<<<<<==============");
        print(imageToView);
      }
    } on SocketException catch (_) {
      //print('not connected');
      isOnline = false;
      db
          .getListParameterMappingActivityByProdukId(
              widget.workplan.jenisProdukId)
          .then((value) {
        setState(() {
          parameterMappingActivityList = value;
        });
      });
    }
  }

  ListView createListViewOffline() {
    // TextStyle textStyle = Theme.of(context).textTheme.subhead;
    print("parameterMappingActivityList.toString:" +
        parameterMappingActivityList.length.toString());
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parameterMappingActivityList.length,
      itemBuilder: (BuildContext context, int index) {
        return customListItemOffline(parameterMappingActivityList[index]);
      },
    );
  }

  GridView createListViewOnline() {
    // TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20),
        itemCount: parameterDokumenWorkplanList.length,
        itemBuilder: (BuildContext ctx, i) {
          return GestureDetector(
            onTap: () {
              // timer!.cancel();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkplanDataDokumenDetail(
                    role: widget.role,
                    workplan: widget.workplan,
                    user: widget.user,
                    title: parameterDokumenWorkplanList[i].description,
                    // dt: dt,
                    dokumenId: parameterDokumenWorkplanList[i].documentId,
                    maxPhoto: parameterDokumenWorkplanList[i].maxphoto,
                    isMaximumUmur: widget.isMaximumUmur,
                    description: parameterDokumenWorkplanList[i].description,
                  ),
                ),
              );
            },
            child: Card(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    width: double.infinity,
                    height: 150,
                    // color: Colors.yellow,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                      image: DecorationImage(
                        // ignore: unnecessary_null_comparison
                        image: parameterDokumenWorkplanList[i].dokumen == ""
                            ? Image.asset(
                                    'images/Menu_Task/List_Task/Camera.png')
                                .image
                            : imageToView[i],
                        // ignore: unnecessary_null_comparison
                        fit: parameterDokumenWorkplanList[i].dokumen == ""
                            ? null
                            : BoxFit.fill,
                      ),
                    ),
                    // ignore: unnecessary_null_comparison
                    // child: parameterDokumenWorkplanList[i].dokumen == null
                    //     ? Image.asset("images/Menu_Task/List_Task/Camera.png")
                    //     : Image.network(
                    //         parameterDokumenWorkplanList[i].dokumen,
                    //         loadingBuilder: (context, child, progress) {
                    //           return progress == null ? child : LinearProgressIndicator();
                    //         },
                    //         // fit: BoxFit.contain,
                    //         width: 50,
                    //         // height: 50,
                    //       )
                    // Image.asset(
                    //   "images/Menu_Task/List_Task/Camera.png",
                    // ),
                  ),
                  Text(parameterDokumenWorkplanList[i].description,
                      style: Reuseable.titleStyle2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                                color: SystemParam.colorCustom,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                                parameterDokumenWorkplanList[i].mandatory
                                    ? 'Mandatory'
                                    : 'Terserah',
                                style: Reuseable.titleStyle3),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Image.asset(
                              "images/Menu_Task/Data Task/High Priority Message.png")
                        ],
                      ),
                      Text(
                        '${parameterDokumenWorkplanList[i].countDokumen}/${parameterDokumenWorkplanList[i].maxphoto}',
                        style: TextStyle(
                            color: Colors.grey[400], fontFamily: 'Poppins'),
                      )
                    ],
                  )
                ],
              ),
            )),
          );
        });
    // ListView.builder(
    //   shrinkWrap: true,
    //   physics: const NeverScrollableScrollPhysics(),
    //   itemCount: parameterDokumenWorkplanList.length,
    //   itemBuilder: (BuildContext context, int index) {
    //     return customListItemOnline(parameterDokumenWorkplanList[index]);
    //   },
    // );
  }

  // customListItemOnline(ParameterDokumenWorkplanMappingData dt) {
  //   var color = Colors.blue;
  //   var icon = Ionicons.arrow_up_circle;
  //   var iconComplete = Icon(Icons.add_a_photo, color: color);
  //   //Icon( Icons.add_a_photo, color: color),

  //   if (dt.isUploaded == 't') {
  //     icon = Ionicons.checkmark_circle_sharp;
  //     color = colorCustom;
  //   }

  //   if (dt.countDokumen >= dt.maxphoto) {
  //     iconComplete = Icon(
  //       Icons.check_box,
  //       color: color,
  //     );
  //   }

  //   // ignore: unrelated_type_equality_checks

  //   return Card(
  //     color: Colors.white,
  //     elevation: 0.1,
  //     child: ListTile(
  //       leading:
  //           dt.mandatory ? Icon(Ionicons.alert, color: Colors.red) : Text(" "),
  //       title: Text(
  //         dt.description,
  //         style: TextStyle(fontSize: 16),
  //       ),
  //       trailing: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           iconComplete,
  //           Icon(icon, color: color),
  //         ],
  //       ),
  //       onTap: () {
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => WorkplanDataDokumenDetail(
  //                       workplan: widget.workplan,
  //                       user: widget.user,
  //                       title: dt.description,
  //                       // dt: dt,
  //                       dokumenId: dt.documentId,
  //                       maxPhoto: dt.maxphoto,
  //                       isMaximumUmur: widget.isMaximumUmur,
  //                       description: dt.description,
  //                     )));
  //         // if (dt.isUploaded == 'f' && enabled) {
  //         //   doCapture(dt);
  //         // } else if(dt.isUploaded == 't') {
  //         //   Navigator.push(
  //         //       context,
  //         //       MaterialPageRoute(
  //         //         builder: (context) => WorkplanDataDokumenViewImage(
  //         //           parameterDokumenWorkplan: dt,
  //         //         )
  //         //       ));
  //         // }
  //       },
  //     ),
  //   );
  // }

  void doCapture(ParameterDokumenWorkplanMappingData dt) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkplanDokTakePicture(
            role: widget.role,
              camera: firstCamera,
              // parameterDokumenWorkplan: dt,
              workplan: widget.workplan,
              user: widget.user,
              isMaximumUmur: widget.isMaximumUmur,
              workplanDokumenId: 0,
              dokumenId: dt.documentId,
              maxPhoto: dt.maxphoto,
              description: dt.description),
        ));
  }

  customListItemOffline(ParameterMappingAktifitas dt) {
    var color = Colors.blue;
    var icon = Ionicons.arrow_up_circle;
    var iconComplete = Icon(Icons.add_a_photo, color: color);
    //Icon( Icons.add_a_photo, color: color),

    // if (dt.isUploaded == 't') {
    //   icon = Ionicons.checkmark_circle_sharp;
    //   color = colorCustom;
    // }

    // if (dt.countDokumen >= dt.maxphoto) {
    //   iconComplete = Icon(
    //     Icons.check_box,
    //     color: color,
    //   );
    // }

    // ignore: unrelated_type_equality_checks

    return Card(
      color: Colors.white,
      elevation: 0.1,
      child: ListTile(
        leading: dt.mandatoryInt == 1
            ? Icon(Ionicons.alert, color: Colors.red)
            : Text(" "),
        title: Text(
          dt.dokumenDescription,
          style: TextStyle(fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconComplete,
            Icon(icon, color: color),
          ],
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WorkplanDataDokumenDetail(
                    role: widget.role,
                        workplan: widget.workplan,
                        user: widget.user,
                        title: dt.dokumenDescription,
                        // dt: dt,
                        dokumenId: dt.documentId,
                        maxPhoto: dt.maxphoto,
                        isMaximumUmur: widget.isMaximumUmur,
                        description: dt.dokumenDescription,
                      )));
        },
      ),
    );
  }
}
