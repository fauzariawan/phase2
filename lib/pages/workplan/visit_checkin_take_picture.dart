import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
// import 'package:async/async.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/database.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/rest_service.dart';
import 'package:workplan_beta_test/helper/utility_image.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/model/workplan_visit_model.dart';
import 'package:workplan_beta_test/pages/workplan/visit_checkin.dart';
import 'package:workplan_beta_test/pages/workplan/visit_checkout.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data_dokumen.dart';
import 'package:http/http.dart' as http;
import 'package:workplan_beta_test/routerName.dart';

class VisitCheckinTakePicture extends StatefulWidget {
  final CameraDescription camera;
  final WorkplanVisit wv;
  final WorkplanInboxData workplan;
  final User user;
  final String lblCheckInOut;
  final bool isMaximumUmur;
  final int nomor;
                  final dynamic role;


  const VisitCheckinTakePicture(
      {Key? key,
      required this.camera,
      required this.wv,
      required this.workplan,
      required this.user,
      required this.lblCheckInOut,
      required this.isMaximumUmur,
      required this.nomor, required this.role})
      : super(key: key);

  @override
  _VisitCheckinTakePictureState createState() =>
      _VisitCheckinTakePictureState();
}

class _VisitCheckinTakePictureState extends State<VisitCheckinTakePicture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  // WorkplanVisit workplanVisit;
  late WorkplanVisit _wv;

  Timer? timer;
  int count = 0;

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
    //     Navigator.of(this.context).pushNamedAndRemoveUntil(
    //         loginScreen, (Route<dynamic> route) => false);
    //   }
    // });
    _wv = widget.wv;

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(' masuk ke did change app life cycle state <<<<<<<<<<<<<<<<======');
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  void onNewCameraSelected(CameraDescription description) {
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // timer!.cancel();
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitCheckIn(
                role: widget.role,
                workplan: widget.workplan,
                workplanVisit: widget.wv,
                user: widget.user,
                lblCheckInOut: widget.lblCheckInOut,
                isMaximumUmur: widget.isMaximumUmur,
                nomor: widget.nomor,
                isPhotoFromCam: false,
              ),
            ));
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: const Text('Take a picture')),
          // You must wait until the controller is initialized before displaying the
          // camera preview. Use a FutureBuilder to display a loading spinner until the
          // controller has finished initializing.
          body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return Center(child: CameraPreview(_controller));
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                // Provide an onPressed callback.
                onPressed: () async {
                  // Take the Picture in a try / catch block. If anything goes wrong,
                  // catch the error.
                  print('sudah di click');
                  try {
                    // Ensure that the camera is initialized.
                    await _initializeControllerFuture;

                    // Attempt to take a picture and get the file `image`
                    // where it was saved.
                    final image = await _controller.takePicture();
                    image.saveTo(image.path);
                    //final imageReadAsBytes = image.readAsBytes();
                    // If the picture was taken, display it on a new screen.
                    // timer!.cancel();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          role: widget.role,
                            // Pass the automatically generated path to
                            // the DisplayPictureScreen widget.
                            // imageReadAsBytes:imageReadAsBytes,
                            imageSource: image,
                            imagePath: image.path,
                            wv: _wv,
                            workplan: widget.workplan,
                            user: widget.user,
                            lblCheckInOut: widget.lblCheckInOut,
                            isMaximumUmur: widget.isMaximumUmur,
                            nomor: widget.nomor),
                      ),
                    );
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                  }
                },
                child: Image.asset("images/Menu_Task/List_Task/Camera.png"),
              ),
              FloatingActionButton(
                // Provide an onPressed callback.
                backgroundColor: SystemParam.colorCustom,
                onPressed: () async {
                  _toggleCameraLens();
                },
                child: const Icon(Icons.change_circle),
              ),
            ],
          )),
    );
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(description, ResolutionPreset.medium,
        enableAudio: true);

    try {
      await _controller.initialize();
      setState(() {});
      // to notify the widgets that camera has been initialized and now camera preview can be done
    } catch (e) {
      print(e);
    }
  }

  void _toggleCameraLens() {
    final lensDirection = _controller.description.lensDirection;
    CameraDescription newDescription;
    print('ini posisi camera pertama');
    print(lensDirection);
    if (lensDirection == CameraLensDirection.back) {
      newDescription = CameraDescription(
          name: "1",
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0);
      _initCamera(newDescription);
    } else {
      newDescription = CameraDescription(
          name: "0",
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90);
      _initCamera(newDescription);
    }
    // get current lens direction (front / rear)
    // final lensDirection = _controller.description.lensDirection;
    // CameraDescription newDescription;
    // if (lensDirection == CameraLensDirection.front) {
    //   newDescription = _availableCameras.firstWhere((description) =>
    //       description.lensDirection == CameraLensDirection.back);
    // } else {
    //   newDescription = _availableCameras.firstWhere((description) =>
    //       description.lensDirection == CameraLensDirection.front);
    // }

    // if (newDescription != null) {
    //   _initCamera(newDescription);
    // } else {
    //   print('Asked camera not available');
    // }
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final WorkplanVisit wv;
  final WorkplanInboxData workplan;
  final User user;
  final XFile imageSource;
  final String lblCheckInOut;
  final bool isMaximumUmur;
  final int nomor;
                  final dynamic role;


  const DisplayPictureScreen(
      {Key? key,
      required this.imagePath,
      required this.wv,
      required this.workplan,
      required this.user,
      required this.imageSource,
      required this.lblCheckInOut,
      required this.isMaximumUmur,
      required this.nomor, required this.role})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  // WorkplanVisit wv;
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(widget.lblCheckInOut)),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      // body: Image.file(File(imagePath)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Image.file(File(widget.imagePath)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: !isClicked
                      ? ElevatedButton(
                          child: Text("UPLOAD"),
                          onPressed: () {
                            setState(() {
                              isClicked = true;
                            });
                            uploadImage(context, widget.wv);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: colorCustom,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          // color: colorCustom,
                          // textColor: Colors.white,
                          //color: Colors.white20,
                          //color: Colors.white20[500],
                          // textColor: Colors.white,
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        )),
            ),
          ],
        ),
      ),
    );
  }

  uploadOnline(File imageFile, String filename, BuildContext context,
      WorkplanVisit wv) async {
    var stream = new http.ByteStream(Stream.castFrom(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse(SystemParam.baseUrl + SystemParam.fUploadImageCheckIn);

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    // request.fields.addEntries(data);
    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);

    request.fields['created_by'] = widget.user.id.toString();
    request.fields['workplan_activity_id'] = widget.workplan.id.toString();
    request.fields['visit_id'] = widget.wv.id.toString();
    request.fields['company_id'] = widget.user.userCompanyId.toString();
    request.fields['file_name'] = filename;
    request.fields['label'] = widget.lblCheckInOut;

    var response = await request.send();
    // print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      // print(value);
    });

    WorkplanVisit wVs = widget.wv;

    if (widget.lblCheckInOut == "CHECK IN") {
      wVs.photoCheckIn = filename;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VisitCheckIn(
                role: widget.role,
                    workplan: widget.workplan,
                    workplanVisit: wVs,
                    user: widget.user,
                    lblCheckInOut: widget.lblCheckInOut,
                    isMaximumUmur: widget.isMaximumUmur,
                    nomor: widget.nomor,
                    isPhotoFromCam: true,
                  )));
    } else {
      wVs.photoCheckOut = filename;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VisitCheckOut(
                role: widget.role,
                    workplan: widget.workplan,
                    workplanVisit: wVs,
                    user: widget.user,
                    lblCheckInOut: widget.lblCheckInOut,
                    isMaximumUmur: widget.isMaximumUmur,
                    nomor: widget.nomor,
                    isPhotoFromCam: true,
                  )));
    }
  }

  uploadImage(BuildContext context, WorkplanVisit wv) async {
    // imageSource.readAsBytes();

    var path = widget.imageSource.path;
    File file = File(path);
    //String baseimage = base64Encode(file.readAsBytesSync());
    String fileName = widget.user.id.toString() +
        "_" +
        widget.wv.id.toString() +
        "_" +
        path.split('/').last;

    //save to local
    Utility.saveImageToPreferences(
        Utility.base64String(file.readAsBytesSync()), fileName);

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        uploadOnline(file, fileName, context, wv);
      }
    } on SocketException catch (_) {
      print('not connected');
      uploadOffline(file, fileName, context, wv);
    }
  }

  void uploadOffline(File file, String filename, BuildContext context,
      WorkplanVisit wv) async {
    var db = new DatabaseHelper();
    String baseimage = base64Encode(file.readAsBytesSync());
    if (widget.lblCheckInOut == "CHECK IN") {
      wv.baseImageCheckIn = baseimage;
      wv.photoCheckIn = filename;
    } else {
      wv.baseImageCheckOut = baseimage;
      wv.photoCheckOut = filename;
    }
    db.updateWorkplanVisitCheckIn(wv);

    if (widget.lblCheckInOut == "CHECK IN") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VisitCheckIn(
                role: widget.role,
                    workplan: widget.workplan,
                    workplanVisit: wv,
                    user: widget.user,
                    lblCheckInOut: widget.lblCheckInOut,
                    isMaximumUmur: widget.isMaximumUmur,
                    nomor: widget.nomor,
                    isPhotoFromCam: true,
                  )));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisitCheckOut(
            role: widget.role,
            workplan: widget.workplan,
            workplanVisit: wv,
            user: widget.user,
            lblCheckInOut: widget.lblCheckInOut,
            isMaximumUmur: widget.isMaximumUmur,
            nomor: widget.nomor,
            isPhotoFromCam: true,
          ),
        ),
      );
    }
  }

  // uploadImageOld(BuildContext context)async{
  // var data = {
  //   "created_by": widget.user.id,
  //   "workplan_activity_id": widget.workplan.id,
  //   "visit_id": widget.wv.id,
  //   "company_id": widget.user.companyId,
  //   "image": baseimage,
  //   "file_name": fileName,
  //   "label": widget.lblCheckInOut
  // };

  // var response = await RestService()
  //     .restRequestService(SystemParam.fUploadImageCheckIn, data);

  // print(response.body);
  // var convertDataToJson = json.decode(response.body);
  // var code = convertDataToJson['code'];
  // var status = convertDataToJson['status'];

  // //update photocheckin
  // widget.wv.photoCheckIn = fileName;

  // WorkplanVisit wVs = widget.wv;
  // wVs.photoCheckIn = fileName;
  // if (code == "0") {
  // if (widget.lblCheckInOut == "CHECK IN") {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => VisitCheckIn(
  //                 workplan: widget.workplan,
  //                 workplanVisit: wVs,
  //                 user: widget.user,
  //                 lblCheckInOut: widget.lblCheckInOut,
  //                 isMaximumUmur: widget.isMaximumUmur,
  //                 nomor: widget.nomor,
  //                 isPhotoFromCam: true,
  //               )));
  // } else {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => VisitCheckOut(
  //                 workplan: widget.workplan,
  //                 workplanVisit: wVs,
  //                 user: widget.user,
  //                 lblCheckInOut: widget.lblCheckInOut,
  //                 isMaximumUmur: widget.isMaximumUmur,
  //                 nomor: widget.nomor,
  //                 isPhotoFromCam: true,
  //               )));
  // }
  // } else {
  //   Fluttertoast.showToast(
  //       msg: status,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }
  // }
}
