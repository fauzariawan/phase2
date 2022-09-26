import 'dart:convert';

import 'package:dio/dio.dart';
import "package:flutter/material.dart";
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workplan_beta_test/base/system_param.dart';
import 'package:workplan_beta_test/main_pages/live_tracking/directions_model.dart';
import 'package:http/http.dart' as http;

class DirectionsRepository {
  // static const String _baseUrl ="https://maps.googleapis.com";
  // static const String  _path = "/maps/api/direction/json?";
  // final _uri = Uri.http(_baseUrl, _path, null);

  // final _baseUrl = "https://maps.googleapis.com";
  // static const Null _params = null; //{"q": "dart"}; /* untuk query */
  // late final Dio _dio;

  // DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    @required LatLng? origin,
    @required LatLng? destination,
  }) async {
    final _baseUrl = "maps.googleapis.com";
    final _path = "/maps/api/directions/json";
    final _params = {
      'origin': '${origin!.latitude}, ${origin.longitude}',
      'destination': '${destination!.latitude}, ${destination.longitude}',
      'key': SystemParam.googleApiKeys
    };
    final _uri = Uri.https(_baseUrl, _path, _params);
    debugPrint(_uri.toString());
    var response = await http.get(_uri);
    // final response = await _dio.get(_baseUrl, queryParameters: {
    //   'origin': '${origin!.latitude}, ${origin.longitude}',
    //   'destination': '${destination!.latitude}, ${destination.longitude}',
    //   'key': SystemParam.googleApiKeys
    // });
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return Directions.fromMap(data);
    }
    return null;
  }

  Future<Directions?> getDirectionsByAddress({
    @required String? origin,
    @required String? destination,
  }) async {
    final _baseUrl = "maps.googleapis.com";
    final _path = "/maps/api/directions/json";
    final _params = {
      'origin': 'place_id:$origin',
      'destination': 'place_id:$destination',
      'key': SystemParam.googleApiKeys
    };
    final _uri = Uri.https(_baseUrl, _path, _params);
    debugPrint(_uri.toString());
    var response = await http.get(_uri);
    // final response = await _dio.get(_baseUrl, queryParameters: {
    //   'origin': '${origin!.latitude}, ${origin.longitude}',
    //   'destination': '${destination!.latitude}, ${destination.longitude}',
    //   'key': SystemParam.googleApiKeys
    // });
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return Directions.fromMap(data);
    }
    return null;
  }
}
