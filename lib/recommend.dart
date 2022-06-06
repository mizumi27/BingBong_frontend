import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spring_button/spring_button.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_record_upload/api/firebase_api.dart';
import 'package:video_record_upload/api/python_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class Recommend extends StatefulWidget{
  Recommend(this.file, this.id, {Key? key}) : super(key: key);
  XFile? file;
  String id;
  @override
  // ignore: no_logic_in_create_state
  State<Recommend> createState() => _RecommendState(file, id);
}

// ignore: must_be_immutable
class _RecommendState extends State<Recommend> {

  _RecommendState(this.file, this.id);
  XFile? file;
  String id;
  VideoPlayerController? _controller;
  Future? test;
  int error_flag = 0;

  @override
  void initState() {
    print(file);
    test = calculateVideo(file);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  //動画をFirebaseに送信
  Future<void> calculateVideo(XFile? videoFile) async {
    print("Uploading Video");

    if (videoFile == null) return;

    //AndroidかiOSかを確認
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? userID;
    if(Platform.isAndroid) {
      AndroidDeviceInfo infoID = await deviceInfo.androidInfo;
      userID = infoID.androidId;
      print('Runnning on ${infoID.androidId}');
    }
    else if(Platform.isIOS) {
      IosDeviceInfo infoID = await deviceInfo.iosInfo;
      userID = infoID.identifierForVendor;
      print('Runnning on ${infoID.identifierForVendor}');
    }
    else {
      //その他の機器の場合、noNameフォルダへ送信
      userID = "noName";
    }

    //Convert so it can be uploaded
    File filePath = File(videoFile.path);

    final fileName = basename(filePath.path);
    final folderName = fileName.substring(0, fileName.length - 4);  //folderNameは.MOVがついていないやつ
    final firebaseDest = 'userFiles/$userID/$folderName/$fileName';

    print("A");
    print(fileName);
    print(firebaseDest);
    print("B");


    //撮影した動画をFirebaseに送信
    //await FirebaseApi.uploadFile(firebaseDest, filePath);

    //idによって動画のジャンルを決定(時間がないので直感的なコードを書いた)
    String genre;
    if(id == "1") genre = "forehand_shakehold";
    else if(id == "2") genre = "backhand_shakehold_drive";
    else if(id == "3") genre = "forehand_shakehold_slice";
    else genre = "backhand_shakehold_drive";

    print("Flask API");

    //python APIを叩く→firebaseに入ってる場所を取得できる
    //Assertion Error(計算できない)の場合は動画を取り直す画面を表示したい
    String? responseDict;
    try{
      //final response = await http.get(Uri.parse('https://joshuaravishankar-fa39413gbz992ckl.socketxp.com/api/?user_id=${userID}&video_id=${folderName}&technique_id=${genre}'));
      final response = await http.get(Uri.parse('https://joshuaravishankar-fa39413gbz992ckl.socketxp.com/api/?user_id=PengZhiyu&video_id=completely_wrong&technique_id=forehand_shakehold'));
      print(response.statusCode);
      print("nomal response.body:");
      print(response.body);
      print("response owari");

      final responseMap = await jsonDecode(response.body);
      print("responseMap");
      print(responseMap);
      print(responseMap[0]);
      responseDict = responseMap[0]['dest'];
      print("responseDict:");
      print(responseDict);
    } catch(e) {
      //エラーフラグをたてる
      error_flag = 1;
    }

    //エラーがなかった時の処理
    if(error_flag == 0) {


      //firebaseからもってくる処理
      final storageRef = FirebaseStorage.instance.ref();
      print("storegeRef");
      print(storageRef);
      //final ref = storageRef.child("/userFiles/PengZhiyu/completely_wrong/recommendation.mp4");
      final ref = storageRef.child("/" + responseDict!);
      print("ref");
      print(ref);
      final url = await ref.getDownloadURL();
      print("url");
      print(url);

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${ref.name}';
      await Dio().download(url, path);

      if (url.contains('.mp4')) {
        await GallerySaver.saveVideo(path, toDcim: true);
      }

      //このresultFileにFlackAPIからFirebaseからダウンロードしてきた動画のアドレスを入れる
      await _playVideo('${tempDir.path}/${ref.name}');
    }
  }

  Widget menuButton(BuildContext context) {
    return SizedBox(
      height: 100.h,
      width: 175.w,
      child: SpringButton(
          SpringButtonType.WithOpacity,
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 26, 67, 1),
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 50.sp,
                    ),
                    Text(
                      '終了',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 80));
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          }
      ),
    );
  }

  Widget retakeButton(BuildContext context) {
    return SizedBox(
      height: 100.h,
      width: 230.w,
      child: SpringButton(
          SpringButtonType.WithOpacity,
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(125, 2, 10, 1.0),
                border: Border.all(color: Colors.white),
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 50.sp,
                    ),
                    Text(
                      '撮り直す',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 80));
            Navigator.pop(context);
            Navigator.pop(context);
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 215, 130, 1),
      body: FutureBuilder(
        future: test,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            if(error_flag == 1) {
              //エラー画面を表示
              return WillPopScope(
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0, -0.3),
                      child: Image(
                        image: const AssetImage("assets/image/sorry.png"),
                        width: 300.w,
                        height: 300.h,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.4),
                      child: Text(
                        "【エラー】もう一度動画を撮り直してください",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35.sp,
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(-0.87, 1.02),
                      child: menuButton(context),
                    ),
                    Align(
                      alignment: const Alignment(0.87, 1.02),
                      child: retakeButton(context),
                    ),
                  ],
                ),
                onWillPop: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  return Future.value(false);
                },
              );
            } else {
              //レコメンド画面を表示
              return WillPopScope(
                child: Stack(
                  children: [
                    _previewVideo(),
                    Align(
                      alignment: const Alignment(-0.87, 1.02),
                      child: menuButton(context),
                    ),
                    Align(
                      alignment: const Alignment(0.87, 1.02),
                      child: retakeButton(context),
                    ),
                  ],
                ),
                onWillPop: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  return Future.value(false);
                },
              );
            }

          } else {
            return WillPopScope(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '計算中・・・１〜２分お待ちください',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.redAccent,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                    ),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
              onWillPop: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                return Future.value(false);
              },
            );
          }
        },
      ),
    );
  }
  Widget _previewVideo() {

    if (_controller == null) {
      //CircularProgressIndicatorをここでいれるかも
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    //上のやつとここでプレビューを再生するか分岐している
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }


  // もういらないだろうけど、処理したビデオをユーザーに見せる際は使えるかも
  Future<void> _playVideo(String file) async {

    //moutedを消去
    if (file != null) {

      await _disposeVideoController();
      late VideoPlayerController controller;
      /*if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {*/
      controller = VideoPlayerController.file(File(file));
      //}
      _controller = controller;

      //await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
    }
    else
    {
      print("Loading Video error");
    }
  }
  Future<void> _disposeVideoController() async {
    /*  if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;*/
    _controller = null;
  }
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}