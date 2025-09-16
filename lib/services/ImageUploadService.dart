import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  final String bucket = "buraco";

  Future<String?> uploadImage(File imageFile) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      await Supabase.instance.client.storage
          .from(bucket)
          .upload(fileName, imageFile);
      final imageUrl = Supabase.instance.client.storage
          .from(bucket)
          .getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }
}
