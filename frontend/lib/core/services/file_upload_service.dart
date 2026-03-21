import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();

  factory FileUploadService() {
    return _instance;
  }

  FileUploadService._internal();

  final supabase = Supabase.instance.client;

  /// Upload a file to Supabase Storage
  /// [bucket] - Storage bucket name (e.g., 'documents', 'products', 'shop-photos')
  /// [file] - The file to upload (XFile from image_picker or File)
  /// [folder] - Optional folder path within the bucket
  /// Returns the public URL of the uploaded file
  Future<String> uploadFile({
    required String bucket,
    required dynamic file,
    String folder = '',
  }) async {
    try {
      final File fileToUpload;
      
      if (file is XFile) {
        fileToUpload = File(file.path);
      } else if (file is File) {
        fileToUpload = file;
      } else {
        throw Exception('Invalid file type');
      }

      if (!await fileToUpload.exists()) {
        throw Exception('File does not exist');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = file is XFile 
          ? '${timestamp}_${file.name}' 
          : '${timestamp}_${fileToUpload.path.split('/').last}';

      // Build path
      final path = folder.isEmpty ? filename : '$folder/$filename';

      print('📤 Uploading to $bucket/$path...');

      // Upload file
      final response = await supabase.storage.from(bucket).upload(
        path,
        fileToUpload,
      );

      // Get public URL
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(path);

      print('✅ File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// Upload multiple files
  Future<List<String>> uploadMultiple({
    required String bucket,
    required List<dynamic> files,
    String folder = '',
  }) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadFile(
        bucket: bucket,
        file: file,
        folder: folder,
      );
      urls.add(url);
    }
    return urls;
  }

  /// Delete a file from Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await supabase.storage.from(bucket).remove([path]);
      print('✅ File deleted: $path');
    } catch (e) {
      print('❌ Delete error: $e');
      throw Exception('Delete failed: $e');
    }
  }
}
