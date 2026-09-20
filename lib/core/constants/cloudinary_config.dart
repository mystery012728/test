class CloudinaryConfig {
  /// Your Cloudinary Cloud Name
  static const String cloudName = 'h2symgjf';

  /// Your Cloudinary Unsigned Upload Preset
  static const String uploadPreset = 'laza_preset';

  /// Upload API Endpoint
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Helper to check if credentials are configured
  static bool get isConfigured =>
      cloudName != 'YOUR_CLOUD_NAME' &&
      cloudName.trim().isNotEmpty &&
      uploadPreset != 'YOUR_UPLOAD_PRESET' &&
      uploadPreset.trim().isNotEmpty;
}
