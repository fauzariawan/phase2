import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/utility_image.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/model/workplan_inbox_model.dart';
import 'package:workplan_beta_test/pages/workplan/workplan_data_dokumen.dart';

class WorkplanDokTakePicture extends StatefulWidget {
  final CameraDescription camera;
  // final ParameterDokumenWorkplanMappingData parameterDokumenWorkplan;
  final WorkplanInboxData workplan;
  final User user;
  final bool isMaximumUmur;
  final int workplanDokumenId;
  final int dokumenId;
  final int maxPhoto;
  final String description;
  final dynamic role;
  
  const WorkplanDokTakePicture(
      {Key? key,
      required this.camera,
      // required this.parameterDokumenWorkplan,
      required this.workplan,
      required this.user,
      required this.isMaximumUmur,
      required this.workplanDokumenId,
      required this.maxPhoto,
      required this.dokumenId,
      required this.description, required this.role})
      : super(key: key);

  @override
  _WorkplanDokTakePictureState createState() => _WorkplanDokTakePictureState();
}

class _WorkplanDokTakePictureState extends State<WorkplanDokTakePicture> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            //final imageReadAsBytes = image.readAsBytes();
            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  role: widget.role,
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  // imageReadAsBytes:imageReadAsBytes,
                  imageSource: image,
                  imagePath: image.path,
                  // parameterDokumenWorkplan: widget.parameterDokumenWorkplan,

                  workplan: widget.workplan,
                  user: widget.user,
                  isMaximumUmur: widget.isMaximumUmur,
                  workplanDokumenId: widget.workplanDokumenId,
                  description: widget.description,
                  dokumenId: widget.dokumenId,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  // final ParameterDokumenWorkplanMappingData parameterDokumenWorkplan;
  final WorkplanInboxData workplan;
  final User user;
  final XFile imageSource;
  final bool isMaximumUmur;
  final int workplanDokumenId;
  final int dokumenId;
  final String description;
  final dynamic role;

  const DisplayPictureScreen(
      {Key? key,
      required this.imagePath,
      // required this.parameterDokumenWorkplan,
      required this.workplan,
      required this.user,
      required this.imageSource,
      required this.isMaximumUmur,
      required this.workplanDokumenId,
      required this.dokumenId,
      required this.description, required this.role})
      : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.description)),
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
                child: ElevatedButton(
                  child: Text("UPLOAD"),
                  onPressed: () {
                    uploadImage(context);
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void uploadImage(BuildContext context) async {
    var path = widget.imageSource.path;
    File file = File(path);
    String baseimage = base64Encode(file.readAsBytesSync());
    String fileName = widget.user.id.toString() +
        "_" +
        widget.dokumenId.toString() +
        "_" +
        path.split('/').last;

    //save to local
    Utility.saveImageToPreferences(
        Utility.base64String(file.readAsBytesSync()), fileName);

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        uploadOnline(file, fileName, context);
      }
    } on SocketException catch (_) {
      //dokumen_base_img
      uploadOffline(file, fileName, context);
    }
  }

  uploadOnline(File imageFile, String filename, BuildContext context) async {
    // open a bytestream
    //var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));

    String baseimage = base64Encode(imageFile.readAsBytesSync());

    var stream = new http.ByteStream(Stream.castFrom(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse(SystemParam.baseUrl + SystemParam.fUploadImage);

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    // request.fields.addEntries(data);
    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path));

    // "created_by": widget.user.id,
    //   "workplan_activity_id": widget.workplan.id,
    //   "dokumen_id": widget.parameterDokumenWorkplan.documentId,
    //   "company_id": widget.user.companyId,
    //   "file_name": fileName,
    //   "workplan_dokumen_id":workplanDokumenId,
    //   "image": baseimage,
    // add file to multipart
    request.files.add(multipartFile);

    request.fields['created_by'] = widget.user.id.toString();
    request.fields['company_id'] = widget.user.userCompanyId.toString();
    request.fields['file_name'] = filename;
    request.fields['workplan_activity_id'] = widget.workplan.id.toString();
    request.fields['dokumen_id'] = widget.dokumenId.toString();
    request.fields['workplan_dokumen_id'] = widget.workplanDokumenId.toString();
    //request.fields['dokumen_base_img'] = baseimage;
    request.fields['dokumen_base_img'] = '';

    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });

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
  }

  void uploadOffline(
      File imageFile, String filename, BuildContext context) async {
    //TODO
    Fluttertoast.showToast(
        msg: "Data tersimpan secara offline",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
