import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/utility_image.dart';
import 'package:workplan_beta_test/model/parameter_dokumen_workplan_mapping.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_dokumen_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data_dokumen_take_picture.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data_dokumen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:workplan_beta_test/routerName.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:workplan_beta_test/widget/warning.dart';

MaterialColor colorCustom = MaterialColor(0xFF4fa06d, SystemParam.color);

class WorkplanDataDokumenDetail extends StatefulWidget {
  final WorkplanInboxData workplan;
  final User user;
  final String title;
  // final ParameterDokumenWorkplanMappingData dt;
  final int maxPhoto;
  final int dokumenId;
  final bool isMaximumUmur;
  final String description;
  final dynamic role;

  const WorkplanDataDokumenDetail(
      {Key? key,
      required this.workplan,
      required this.user,
      required this.title,
      // required this.dt,
      required this.isMaximumUmur,
      required this.maxPhoto,
      required this.dokumenId,
      required this.description, required this.role})
      : super(key: key);

  @override
  _WorkplanDataDokumentate createState() => _WorkplanDataDokumentate();
}

class _WorkplanDataDokumentate extends State<WorkplanDataDokumenDetail> {
  bool loading = false;
  bool enabled = false;
  // late List<ParameterDokumen> parameterDokumenList;
  List<ParameterDokumenWorkplanMappingData> parameterDokumenWorkplanList =
      <ParameterDokumenWorkplanMappingData>[];
  late Image imageFromPreferences;
  List<Image> imageFromPreferencesList = <Image>[];
  int imgCount = 0;
  var db = new DatabaseHelper();
  bool isOnline = false;
  String _s3Url = "";
  int count = 0;
  Timer? timer;
  List<WorkplanDokumen> workplanDokumenList = <WorkplanDokumen>[];

  @override
  void initState() {
    super.initState();
    // timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    //   int? limit = widget.user.timeoutLogin * 60;
    //   print('ini limit time logout nya');
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
    initParameterDokumen();
    if (widget.workplan.isCheckIn == "1" &&
        (widget.workplan.progresStatusIdAlter == 2 ||
            widget.workplan.progresStatusIdAlter == 4)) {
      enabled = true;
    } else {
      enabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final photos = <File>[];
    // final size = MediaQuery.of(context).size;
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        count = 0;
      },
      child: WillPopScope(
          onWillPop: () async {
            // timer!.cancel();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkplanDataDokumen(
                      role: widget.role,
                      workplan: widget.workplan,
                      user: widget.user,
                      title: "Dokumen",
                      isMaximumUmur: widget.isMaximumUmur),
                ));
            return false;
          },
          child: Scaffold(
            //drawer: NavigationDrawerWidget(),
            appBar: AppBar(
              title: Text(widget.title),
              centerTitle: true,
              backgroundColor: colorCustom,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                //onPressed: () => Navigator.of(context).pop(),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkplanDataDokumen(
                            role: widget.role,
                            workplan: widget.workplan,
                            user: widget.user,
                            title: "Dokumen",
                            isMaximumUmur: widget.isMaximumUmur),
                      ));
                },
              ),
            ),
            body: loading == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: !enabled
                              ? null
                              : () {
                                  // doCapture(widget.dt, 0);
                                  doCapture(0, widget.dokumenId,
                                      widget.maxPhoto, widget.description);
                                },
                          child: ClipOval(
                            child: Image.asset(
                                "images/Menu_Task/List_Task/Camera.png"),
                          ),
                        ),
                        SizedBox(height: Reuseable.jarak3),
                        Container(
                          child: Text("Silakan ambil photo dokumen"),
                        ),
                        SizedBox(height: Reuseable.jarak3),
                        isOnline
                            ? Container(
                                child: createListViewImageS3(),
                              )
                            : Center(
                                child: Text('No Internet Connection'),
                              )
                        // Container(
                        //     child: createListViewImageOffline(),
                        //   )
                      ],
                    ),
                  )),
          )),
    );
  }

  void initParameterDokumen() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isOnline = true;
        loading = true;
        ParameterDokumenWorkplanMapping parameterModel;
        var data = {
          "company_id": widget.user.userCompanyId,
          "workplan_activity_id": widget.workplan.id,
          "product_id": widget.workplan.jenisProdukId,
          //"document_id": widget.dt.documentId
          "document_id": widget.dokumenId
        };

        // print(data);
        var response = await RestService().restRequestService(
            SystemParam.fParameterDokumenWorkplanMappingByDocumentId, data);
        print('ini gambar yang mau di load <<<<<<======= ');
        print(response.body);

        setState(() {
          parameterModel =
              parameterDokumenWorkplanMappingFromJson(response.body.toString());
          parameterDokumenWorkplanList = parameterModel.data;
          imgCount = parameterDokumenWorkplanList.length;

          for (var i = 0; i < parameterDokumenWorkplanList.length; i++) {
            print('masuk ke loadImageFromPreferences <<<<<<=========');
            loadImageFromPreferences(parameterDokumenWorkplanList[i].dokumen)
                .then((value) {
              setState(() {
                imageFromPreferencesList.add(value);
              });
            });
          }

          loading = false;
        });
      }
    } on SocketException catch (_) {
      Warning.showWarning("No Internet Connection");
      // isOnline = false;
      // db
      //     .getListWorkplanDokumenByDokumenId(widget.dokumenId.toString())
      //     .then((value) {
      //   //
      // });
    }
  }

  ListView createListViewImageS3() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parameterDokumenWorkplanList.length,
      itemBuilder: (BuildContext context, int index) {
        return customListItemImageS3(parameterDokumenWorkplanList[index]);
      },
    );
  }

  // ListView createListViewImage2() {
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: parameterDokumenWorkplanList.length,
  //     itemBuilder: (BuildContext context, int index) {
  //       if (imageFromPreferencesList.isNotEmpty) {
  //         return customListItemImage2(
  //             imageFromPreferencesList[index],
  //             parameterDokumenWorkplanList[index].workplanDokumenId,
  //             widget.dokumenId,
  //             widget.maxPhoto,
  //             widget.description);
  //       } else {
  //         return customListItemImage2Null();
  //       }
  //     },
  //   );
  // }

  customListItemImageS3(ParameterDokumenWorkplanMappingData pdwm) {
    return GestureDetector(
        onTap: !enabled
            ? null
            : () {
                doCapture(pdwm.workplanDokumenId, widget.dokumenId,
                    widget.maxPhoto, widget.description);
              },
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
                child: Image.network(
              _s3Url + "/" + pdwm.dokumen,
              loadingBuilder: (context, child, progress) {
                return progress == null ? child : LinearProgressIndicator();
              },
            )
                // CachedNetworkImage(
                //   imageUrl: _s3Url + "/" + pdwm.dokumen,
                //   placeholder: (context, url) => CircularProgressIndicator(),
                //   errorWidget: (context, url, error) => Container(),
                // ),
                //child: Image.network("https://dnrxhhzm9tsok.cloudfront.net/"+pdwm.dokumen),
                ),
          ),
        ));
  }

  customListItemImage2Null() {
    return new Container();
  }

  customListItemImage2(Image imgDock, int workplanDokumenId, int dokumenId,
      int maxPhoto, String description) {
    //print("workplanDokumenId:" + workplanDokumenId.toString());
    return GestureDetector(
        onTap: () {
          // doCapture(widget.dt, workplanDokumenId);
          doCapture(workplanDokumenId, dokumenId, maxPhoto, description);
        },
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              child: imgDock,
            ),
          ),
        ));
  }

  ListView createListViewImage() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageFromPreferencesList.length,
      itemBuilder: (BuildContext context, int index) {
        return customListItemImage(imageFromPreferencesList[index]);
      },
    );
  }

  customListItemImage(Image imgDock) {
    // print(imgDock);
    return GestureDetector(
        onTap: () {},
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              child: imgDock,
            ),
          ),
        ));
  }

  Future<Image> loadImageFromPreferences(String doc) async {
    print('sudah di dalam loadImageFromPreferences');
    print(doc);
    return Utility.getImageFromPreferences(doc.split('/').last).then((img) {
      print(img);
      Image imgRes = Utility.imageFromBase64String(img!);
      print('ini data image <<<<<<========');
      print(imgRes.image);
      return imgRes;
    });
  }

//  void doCapture(ParameterDokumenWorkplanMappingData dt, int workplanDokumenId)async {
  void doCapture(int workplanDokumenId, int dokumenId, int maxPhoto,
      String description) async {
    // print("dt.maxphoto=" + dt.maxphoto.toString());
    // print("imgCount=" + imgCount.toString());
    if (workplanDokumenId == 0 && imgCount >= maxPhoto) {
      Fluttertoast.showToast(
          msg: "Photo dokumen sudah melebihi batas ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

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
            workplanDokumenId: workplanDokumenId,
            dokumenId: dokumenId,
            maxPhoto: maxPhoto, description: description,
          ),
        ));

    initParameterDokumen();
  }

  ListView createListViewImageOffline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workplanDokumenList.length,
      itemBuilder: (BuildContext context, int index) {
        return customListItemImageOffline(workplanDokumenList[index]);
      },
    );
  }

  customListItemImageOffline(WorkplanDokumen workplanDokumenList) {
    //TODO
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
      },
    );
  }
}
