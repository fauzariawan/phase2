import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ServiceLocation {
  final String key = "AIzaSyBYBnKGETVI1PxxkasSkQc6dBqIOpCErss";

  Future<String> getPlacesId(String input) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key";

    var response = await http.get(Uri.parse(url));

    var json = convert.jsonDecode(response.body);
    print('ini dari fungsi get place id <<<<<<<<==================');
    print(json);

    var placeId = json['candidates'][0]['place_id'];

    print(placeId);

    return placeId;
  }

  // Future<Map<String, dynamic>>getPlaces(String input) async {

  // }
}
