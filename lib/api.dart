import 'dart:convert';
import 'package:http/http.dart' as http;


void transcribeAudio() async {
  var url = 'http://your-flask-api-endpoint';
  var audioFile =
  var request = http.MultipartRequest('POST', Uri.parse(url));
  request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

  var response = await request.send();
  if (response.statusCode == 200) {
    var jsonResponse = await response.stream.bytesToString();
    var data = json.decode(jsonResponse);
    var text = data['text'];
    var filter = data['filter'];
    var entities = data['entities'];
    // do something with the response data
  } else {
    // handle error
  }
}
