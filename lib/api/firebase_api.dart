import 'dart:io';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static Future<XFile> downloadFile(String destination) async {
    try {
      final ref_root = FirebaseStorage.instance.ref();
      final ref = ref_root.child(destination);

      final appDocDir = await getApplicationDocumentsDirectory();
      print(appDocDir);
      print(appDocDir.path);
      //ここのrecommendation.mp4を${destination}にする
      final filePath = "${appDocDir.path}/recommendation.mp4";
      final file = File(filePath);

      await ref.writeToFile(file);

      return XFile("${appDocDir.path}/recommendation.mp4");

    } on FirebaseException catch (e) {
      print(e);
      print("error");
      final appDocDir = await getApplicationDocumentsDirectory();
      return XFile("${appDocDir.path}/recommendation.mp4");
    }
  }
}