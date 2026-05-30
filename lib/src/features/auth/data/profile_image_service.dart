import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProfileImageService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndStoreProfileImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) {
      return null;
    }
    return _copyToProfileImages(File(picked.path), prefix: 'profile');
  }

  Future<String?> pickAndStoreProfileBanner(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 900,
      imageQuality: 86,
    );
    if (picked == null) {
      return null;
    }
    return _copyToProfileImages(File(picked.path), prefix: 'banner');
  }

  Future<String> _copyToProfileImages(
    File source, {
    required String prefix,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(docs.path, 'profile_images'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final ext = p.extension(source.path);
    final extension = ext.isEmpty ? '.jpg' : ext;
    final destinationPath = p.join(
      folder.path,
      '${prefix}_$timestamp$extension',
    );
    final copied = await source.copy(destinationPath);
    return copied.path;
  }
}
