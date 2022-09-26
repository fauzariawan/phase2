import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workplan_beta_test/helper/helper.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/choose_user_to_track_live_location.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:http/http.dart' as http;
import 'package:workplan_beta_test/widget/warning.dart';

class ViewLiveTrackingLocation extends StatefulWidget {
  final User user;
  final dynamic data;

  const ViewLiveTrackingLocation(
      {Key? key, required this.user, required this.data})
      : super(key: key);

  @override
  State<ViewLiveTrackingLocation> createState() =>
      _ViewLiveTrackingLocationState();
}

class _ViewLiveTrackingLocationState extends State<ViewLiveTrackingLocation> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  LatLng? _center;
  BitmapDescriptor? mapMarker;
  Timer? updateLocation;
  Marker? point;

  void initState() {
    super.initState();
    _center = LatLng(double.parse(widget.data['latitude']),
        double.parse(widget.data['longitude']));
    initIconMarker();
    updateLocation = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      bool hasInternetConnection = await Helper.internetCek();
      if (hasInternetConnection) {
        Uri url = Uri.parse(
            "https://workplan-phase2-be.aplikasidev.com/api/live-tracking/${widget.data['user_id']}?company_id=${widget.data['company_id']}");
        print(url);
        try {
          var response = await http.get(url);
          var responseJson = jsonDecode(response.body);
          print(responseJson['code']);
          print(responseJson['status']);
          if (responseJson['code'] == 0 &&
              responseJson['status'] == "Success") {
            var data = responseJson['data'];
            final Uint8List markerIcon = await getBytesFromAsset(
                "images/Menu_Task/List_Task/Frame.png", 70);
            mapMarker = BitmapDescriptor.fromBytes(markerIcon);

            setState(() {
              point = Marker(
                  markerId: MarkerId("point"),
                  infoWindow: InfoWindow(title: data['full_name']),
                  position: LatLng(double.parse(data['latitude']),
                      double.parse(data['longitude'])),
                  icon: mapMarker!);

              _center = LatLng(double.parse(data['latitude']),
                  double.parse(data['longitude']));
            });
            print('berhasil update posisi titik di map');
          } else {
            Warning.showWarning(responseJson['status']);
          }
        } catch (e) {
          print('error konneksi http');
          print(e);
          Warning.showWarning('No Internet Connection');
          // return _list;
        }
      } else {
        print('No Internet Connection');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        TimerCountDown().activityDetected();
      },
      child: WillPopScope(
        onWillPop: () async {
          updateLocation!.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChooseUserToTrackLiveLocation(
                user: widget.user,
              ),
            ),
          );
          return false;
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text("Live Tracking Location"),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Stack(
              children: [
                GoogleMap(
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  // zoomControlsEnabled: false,
                  // zoomGesturesEnabled: false,
                  // scrollGesturesEnabled: false,
                  markers: {if (point != null) point!},
                  // _markers,
                  // rotateGesturesEnabled: false,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center ?? LatLng(3.5917854, 98.7511941),
                    zoom: 16.0,
                  ),
                  // polylines: listPolyline,

                  // onTap: _addMarker,
                ),
                Positioned(
                    bottom: 0,
                    child: Container(
                      // margin: EdgeInsets.symmetric(horizontal: 20),
                      // width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          color: Colors.white),
                      child: Row(
                        children: [
                          Image.asset("images/Menu_Task/List_Task/Frame.png"),
                          SizedBox(
                            width: Reuseable.jarak2,
                          ),
                          Text("Employee Name : ${widget.data['full_name']}"),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void initIconMarker() async {
    final Uint8List markerIcon =
        await getBytesFromAsset("images/Menu_Task/List_Task/Frame.png", 70);
    mapMarker = BitmapDescriptor.fromBytes(markerIcon);

    point = Marker(
        markerId: MarkerId("point"),
        infoWindow: InfoWindow(title: widget.data['full_name']),
        position: LatLng(double.parse(widget.data['latitude']),
            double.parse(widget.data['longitude'])),
        icon: mapMarker!);

    // var index = 0;
    // for (var item in widget.data) {
    //   print(item);
    //   // _markers.add(
    //   //   Marker(
    //   //       markerId: MarkerId("visit-$index"),
    //   //       // infoWindow: InfoWindow(title: item['nama']),
    //   //       position: LatLng(double.parse(item['latitude']),
    //   //           double.parse(item['longtitude'])),
    //   //       icon: await bitmapDescriptorFromSvgAsset(context, item['nama'])),
    //   // );
    //   _markers.add(
    //     Marker(
    //         markerId: MarkerId("visit-${index + 1}"),
    //         infoWindow: InfoWindow(title: item['nama']),
    //         position: LatLng(double.parse(item['latitude']),
    //             double.parse(item['longtitude'])),
    //         icon: mapMarker!),
    //   );
    //   index += 2;
    // }

    setState(() {});
  }

  getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
