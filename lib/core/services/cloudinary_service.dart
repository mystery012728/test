import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/cloudinary_config.dart';

class CloudinaryService {
  final Dio _dio;

  CloudinaryService({Dio? dio}) : _dio = dio ?? Dio();

  /// Uploads an image file to Cloudinary and returns the secure HTTPS CDN URL
  Future<String> uploadImage(XFile imageFile) async {
    if (!CloudinaryConfig.isConfigured) {
      throw Exception(
        'Cloudinary credentials are not set yet. Please provide your Cloud Name and Upload Preset.',
      );
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
        'upload_preset': CloudinaryConfig.uploadPreset.trim(),
        'folder': 'laza_profiles',
      });

      final response = await _dio.post(
        CloudinaryConfig.uploadUrl,
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final secureUrl = response.data['secure_url'] as String?;
        if (secureUrl != null && secureUrl.isNotEmpty) {
          return secureUrl;
        }
      }

      throw Exception('Failed to retrieve secure URL from Cloudinary.');
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['error']?['message'] ?? e.message;
      throw Exception('Cloudinary upload error: $serverMsg');
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }
}
