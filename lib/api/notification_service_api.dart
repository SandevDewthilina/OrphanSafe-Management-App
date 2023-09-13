import 'dart:convert';
import '../utils/utils.dart';
import 'package:http/http.dart' as http;

class NotificationServiceApi {
  static Future<void> patchTokenWithServer(userId, token) async{
    
    final deviceId = await Utils.getDeviceId();
    const cookie = 'appPass=ks32okK3jKJ@KJkJ&KEJfaJKJDKO*JDK26f5sa65f6';

    final url = Uri.parse(Utils.getPatchTokenURL());
    final headers = <String, String>{
      'Content-Type': 'application/json', // Set your desired content type
      'Cookie': cookie
      // Add any other headers you may need
    };
    final body = <String, dynamic>{
      'userId': userId,
      'token': token,
      'deviceId': deviceId
      // Add the data you want to send in the PATCH request
    };

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body), // Encode your data as JSON
      );

      if (response.statusCode == 200) {
        // Request was successful, you can handle the response here
        print('PATCH Request Successful');
        print('Response: ${response.body}');
      } else {
        // Handle error responses here
        print('PATCH Request Failed with status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      // Handle network errors or exceptions here
      print('Error: $e');
    }
  }
}