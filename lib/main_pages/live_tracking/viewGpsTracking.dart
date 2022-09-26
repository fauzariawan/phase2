import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/helper/timer.dart';
import 'package:workplan_beta_test/main_pages/attendance/service_location.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/direction_repository.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/directions_model.dart';
import 'package:workplan_beta_test/model/user_model.dart';
import 'package:geocoder/geocoder.dart';
import 'package:workplan_beta_test/widget/reuseable_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ViewGpsTracking extends StatefulWidget {
  final User user;
  final List<dynamic> data;
  final String employeeName;
  final String taskDate;

  const ViewGpsTracking(
      {Key? key,
      required this.user,
      required this.data,
      required this.employeeName,
      required this.taskDate})
      : super(key: key);

  @override
  State<ViewGpsTracking> createState() => _ViewGpsTrackingState();
}

class _ViewGpsTrackingState extends State<ViewGpsTracking> {
  BitmapDescriptor? mapMarker;
  Marker? _origin;
  Marker? _destination;
  Set<Marker> _markers = {};
  Directions? _info;
  List<Directions> polyline = [];
  Set<Polyline> listPolyline = {};
  List<String> placeIdList = [];
  late GoogleMapController mapController;
  LatLng? _center;
  List<LatLng> coordinatess = [
    LatLng(3.5917854, 98.7511941),
    LatLng(4.5917854, 97.7511941),
    LatLng(5.5917210, 96.7511901),
  ];
  List coordinates = [
    // [3.5917854, 98.7511941],
    // [4.5917854, 97.7511941],
    // [5.5917210, 96.7511901],
  ];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void initState() {
    super.initState();
    initCoordinates();
    // initIconMarker();
    // initPolyLine();
  }

  void dispose() {
    super.dispose();
    mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Listener(
        onPointerDown: (PointerDownEvent event) {
          TimerCountDown().activityDetected();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("GPS Tracking"),
            centerTitle: true,
            automaticallyImplyLeading: false,
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       mapController.animateCamera(
            //         CameraUpdate.newCameraPosition(
            //           CameraPosition(
            //               target: _origin!.position, zoom: 14.5, tilt: 50.0),
            //         ),
            //       );
            //     },
            //     child: Text(
            //       "Origin",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            //   TextButton(
            //     onPressed: () {
            //       mapController.animateCamera(
            //         CameraUpdate.newCameraPosition(
            //           CameraPosition(
            //               target: _destination!.position, zoom: 14.5, tilt: 50.0),
            //         ),
            //       );
            //     },
            //     child: Text(
            //       "Destination",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   )
            // ],
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                markers: _markers,
                rotateGesturesEnabled: false,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center ?? LatLng(3.5917854, 98.7511941),
                  zoom: 13.0,
                ),
                polylines: listPolyline,

                // onTap: _addMarker,
              ),
              Positioned(
                  bottom: 0,
                  child: Container(
                    // margin: EdgeInsets.symmetric(horizontal: 20),
                    // width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: MediaQuery.of(context).size.height * 0.1,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Employee Name : ${widget.employeeName}"),
                            SizedBox(height: Reuseable.jarak1),
                            Text("Task Date : ${widget.taskDate}")
                          ],
                        ),
                      ],
                    ),
                  ))
              // if (_info != null)
              //   Positioned(
              //       top: 20,
              //       child: Container(
              //         padding:
              //             EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
              //         decoration: BoxDecoration(
              //             color: Colors.yellowAccent,
              //             borderRadius: BorderRadius.circular(20.0),
              //             boxShadow: const [
              //               BoxShadow(
              //                   color: Colors.black26,
              //                   offset: Offset(0, 2),
              //                   blurRadius: 6.0)
              //             ]),
              //         child: Text(
              //             '${_info!.totalDistance}. ${_info!.totalDuration}',
              //             style: TextStyle(
              //                 fontSize: 18, fontWeight: FontWeight.w600)),
              //       ))
            ],
          ),
          // floatingActionButton: FloatingActionButton(
          //     backgroundColor: SystemParam.colorCustom,
          //     foregroundColor: Colors.black,
          //     onPressed: () {
          //       mapController.animateCamera(
          //         _info != null
          //             ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
          //             : CameraUpdate.newCameraPosition(
          //                 CameraPosition(
          //                   target: _center,
          //                   zoom: 11.0,
          //                 ),
          //               ),
          //       );
          //     },
          //     child: Icon(Icons.center_focus_strong_rounded)),
        ),
      ),
    );
  }

  void initIconMarker() async {
    final Uint8List markerIcon =
        await getBytesFromAsset("images/Menu_Task/List_Task/Frame.png", 70);
    mapMarker = BitmapDescriptor.fromBytes(markerIcon);

    var index = 0;
    for (var item in widget.data) {
      print(item);
      // _markers.add(
      //   Marker(
      //       markerId: MarkerId("visit-$index"),
      //       // infoWindow: InfoWindow(title: item['nama']),
      //       position: LatLng(double.parse(item['latitude']),
      //           double.parse(item['longtitude'])),
      //       icon: await bitmapDescriptorFromSvgAsset(context, item['nama'])),
      // );
      _markers.add(
        Marker(
            markerId: MarkerId("visit-${index + 1}"),
            infoWindow: InfoWindow(title: item['nama']),
            position: LatLng(double.parse(item['latitude']),
                double.parse(item['longtitude'])),
            icon: mapMarker!),
      );
      index += 2;
    }

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

  Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(
      BuildContext context, String nama) async {
    // Read SVG file as String
    // String svgString = await DefaultAssetBundle.of(context).loadString(assetName,);
    // Create DrawableRoot from SVG String
    String svgStrings =
        '''<svg width="90" height="60" xmlns="http://www.w3.org/2000/svg">
  
  <rect x="2" y="2" rx="10" ry="10" width="75" height="50"
  style="fill:#ffcc00;stroke:#ffcc00;stroke-width:1" />
  <text  x="10" y="18" fill="#000000" fonFamily="poppins">$nama</text>
  

</svg>''';
// <path stroke="#ffcc00" id="svg_1" d="m74.14781,0.22566l-73.83144,-0.00774l0,31.59256l30.27788,0l5.12395,17.65467c0.04658,0.00774 3.86625,-17.02746 3.86625,-17.02746c0,0 34.48279,0 34.42362,-0.00774c0.00739,0.00097 0.01513,-0.5015 0.02299,-1.38155c0.00393,-0.44003 0.0079,-0.97446 0.01188,-1.58755c0.00398,-0.61309 0.00796,-1.30486 0.01193,-2.05955c0.02677,-7.20252 0.04414,-12.03835 0.05589,-15.41562c0.01175,-3.37727 0.0179,-5.29597 0.02223,-6.66423c0.00433,-1.36826 0.00686,-2.18608 0.00844,-2.71689c0.00158,-0.53081 0.00223,-0.77459 0.00281,-0.99479c0.00058,-0.2202 0.00109,-0.4168 0.00154,-0.58784c0.00044,-0.17104 0.00082,-0.31653 0.00112,-0.4345c0.0003,-0.11796 0.00053,-0.2084 0.00069,-0.26935c0.00015,-0.06095 0.00023,-0.0924 0.00023,-0.0924c-0.0102,3.52301 -0.01745,6.03945 -0.02249,7.80293c-0.00505,1.76348 -0.00789,2.77399 -0.00928,3.28516c-0.00139,0.51116 -0.00132,0.52297 -0.00054,0.28903c0.00077,-0.23394 0.00225,-0.71362 0.0037,-1.18544c0.00144,-0.47182 0.00284,-0.93578 0.00419,-1.38991c0.00135,-0.45413 0.00266,-0.89844 0.00393,-1.33095c0.00126,-0.43251 0.00248,-0.85323 0.00364,-1.26018c0.00116,-0.40696 0.00228,-0.80015 0.00334,-1.17762c-0.02728,9.05903 -0.02086,7.04596 -0.0151,5.15867c0.00576,-1.88729 0.01086,-3.64879 0.0151,-5.15867c0.00848,-3.01976 0.01351,-5.03301 0.01351,-5.03301z" stroke-width="1.5" fill="#ffcc00"/>
// <text  y="16.77155" x="24.02531" fill="#ffffff">$price</text>
//         '''<svg width="70" height="50">
//   <rect x="50" y="20" rx="20" ry="20" width="150" height="150" style="fill:red;stroke:black;stroke-width:5;opacity:0.5" />
//   Sorry, your browser does not support inline SVG.
// </svg>''';
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(
      svgStrings,
      "",
    );

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width =
        75 * devicePixelRatio; // where 32 is your SVG's original width
    double height = 50 * devicePixelRatio; // same thing

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  // void _addMarker(LatLng pos) async {
  //   if (_origin == null || (_origin != null && _destination != null)) {
  //     print('buat tanda origin');
  //     setState(() {
  //       _origin = Marker(
  //         markerId: const MarkerId("origin"),
  //         infoWindow: const InfoWindow(title: "Origin"),
  //         icon:
  //             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //         position: pos,
  //       );
  //       // Reset Destination
  //       _destination = null;
  //       // Reset Info
  //       _info = null;
  //     });
  //   } else {
  //     print('buat tanda destini');
  //     setState(() {
  //       _destination = Marker(
  //         markerId: const MarkerId("destination"),
  //         infoWindow: const InfoWindow(title: "Destination"),
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //         position: pos,
  //       );
  //     });
  //     final directions = await DirectionsRepository()
  //         .getDirections(origin: _origin!.position, destination: pos);
  //     print(directions!.polyLinePoints);
  //     setState(() {
  //       _info = directions;
  //     });
  //   }
  // }

  void initPolyLine() async {
    print('masuk ke initpolyline');
    for (var i = 0; i < coordinates.length; i++) {
      final coordinate = new Coordinates(coordinates[i][0], coordinates[i][1]);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinate);
      print('ini hasil dari findAddressesFromCoordinates <<<<<<<<============');
      print(addresses.first.addressLine);
      // var first = addresses.first;
      // print("${first.featureName} : ${first.addressLine}");
      String placeId =
          await ServiceLocation().getPlacesId(addresses.first.addressLine);
      print('ini place_id nya <<<<<=====');
      print(placeId);
      placeIdList.add(placeId);

      // place id origin = ChIJb5Wm5802MTARtnK-gkDMzd4
      // place id destination = ChIJ4ZrfaSwhODARYi7GpXi1nNE
      // print("masuk ke ini polyline <<<<<<<========");
      // for (var i = 0; i < coordinates.length - 1; i++) {
      //   final directions = await DirectionsRepository().getDirectionsByAddress(
      //       origin: coordinates[i], destination: coordinates[i + 1]);
      //   print(directions!.polyLinePoints);
      //   // setState(() {
      //   //   polyline.add(directions);
      //   //   listPolyline.add(Polyline(
      //   //       points: directions.polyLinePoints
      //   //           .map((e) => LatLng(e.latitude, e.longitude))
      //   //           .toList(),
      //   //       width: 5,
      //   //       color: Colors.red,
      //   //       polylineId: const PolylineId('Overview Polyline')));
      //   // });
      //   print(i);
      //   print(coordinates.length);
      // }
    }
    print('Ini data place id semuanya <<<<<<======');
    print(placeIdList);
    // ChIJy5Z_JdcxMTAR4LBU6jWdfIQ
    for (var i = 0; i < placeIdList.length - 1; i++) {
      final directions = await DirectionsRepository().getDirectionsByAddress(
          origin: placeIdList[i], destination: placeIdList[i + 1]);
      setState(() {
        polyline.add(directions!);
        listPolyline.add(Polyline(
            points: directions.polyLinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
            width: 5,
            color: Colors.red,
            polylineId: const PolylineId('Overview Polyline')));
      });
    }
    //   final directions = await DirectionsRepository().getDirectionsByAddress(
    //       origin: 'ChIJb5Wm5802MTARtnK-gkDMzd4',
    //       destination: 'ChIJ4ZrfaSwhODARYi7GpXi1nNE');
    //   print(directions!.polyLinePoints);
    //   setState(() {
    //     polyline.add(directions);
    //     listPolyline.add(Polyline(
    //         points: directions.polyLinePoints
    //             .map((e) => LatLng(e.latitude, e.longitude))
    //             .toList(),
    //         width: 5,
    //         color: Colors.red,
    //         polylineId: const PolylineId('Overview Polyline')));
    //   });
    // }
  }

  void initCoordinates() {
    print('masuk ke init coordinates <<<<<<<<<===========');
    print(widget.data);
    for (var item in widget.data) {
      coordinates.add(
          [double.parse(item['latitude']), double.parse(item['longtitude'])]);
    }
    setState(() {
      _center = LatLng(coordinates[0][0], coordinates[0][1]);
    });
    print('ini dari init coordinates <<<<<<<<<<=======');
    print(coordinates);
    initIconMarker();
    initPolyLine();
  }
}
