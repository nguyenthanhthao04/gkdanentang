import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'uparw5nb';
  static const String apiKey = '986747972162866';
  static const String apiSecret = 'WVgG4_N_hILfm7SRaCUMAYjgcic';
  static const String defaultFolder = 'home/gkdanentang';

  /// Upload image bytes directly to Cloudinary into specified folder and return secure URL
  static Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    String folder = defaultFolder,
  }) async {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    // Cloudinary signature parameters must be sorted alphabetically:
    // 'folder' comes before 'timestamp'
    final toSign = 'folder=$folder&timestamp=$timestamp$apiSecret';
    final signature = sha1.convert(utf8.encode(toSign)).toString();

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp
      ..fields['folder'] = folder
      ..fields['signature'] = signature
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final secureUrl = jsonResponse['secure_url'] as String?;
      if (secureUrl != null && secureUrl.isNotEmpty) {
        return secureUrl;
      }
      throw Exception('Không nhận được secure_url từ Cloudinary');
    } else {
      throw Exception('Lỗi upload Cloudinary (${response.statusCode}): ${response.body}');
    }
  }
}
