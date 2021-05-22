import 'dart:async';

import 'package:flutter/material.dart';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

import 'package:flutter_tts/flutter_tts.dart';
//import 'package:starflut/starflut.dart';
import 'package:translator/translator.dart';
import 'db/discoursBox.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DiscoursBox.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatSays',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

enum TtsState { playing, stopped }

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  bool listen = false;
  String _text = 'Press the button and start speaking';
  String _memory = "";
  double _confidence = 1.0;

  String _platformVersion = 'Unknown';

  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.9;
  double pitch = 0.5;
  double rate = 1.0;

  //String _newVoiceText;
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    initTts();
    //initPython();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme
            .of(context)
            .primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            _text,
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    //await Permission.microphone.isGranted;
    //_speak();


    if (!_isListening) {
      bool available = await _speech.initialize(
          onStatus: (val) =>
                  () {
                print('on5Status: $val');
                if (val == "notListening") {
                  setState(() => _isListening = false);

                  //_listen();
                }
              }(),
          onError: (val) => print('on5Error: $val'),
          //debugLogging: true,
          finalTimeout: Duration(milliseconds: 2000),
          options: [
            SpeechConfigOption('android', 'alwaysUseStop', false),
            SpeechConfigOption('android', 'intentLookup', false)
          ]
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          //TODO: create a function for detect if user stop to speech during 10sec and stop listen
          //listenFor: Duration(minutes: 1),
          localeId: "en-US",
          onResult: (val) =>
              setState(
                    () {
                  _text = _memory != "" ? _memory + " "+ val.recognizedWords.toLowerCase() : val.recognizedWords.toLowerCase();

                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _confidence = val.confidence;

                      var filteredContent = DiscoursBox.box.values
                          .where((data) => data.dialogEn.contains(_text));

                      if (filteredContent
                          .toList()
                          .length > 1) {
                        //passer le text en traduction et faire le speech pour gagner en temps le temps d'affiner les resultats
                        translateToSpeech(_text);

                      }
                      else if (filteredContent
                          .toList()
                          .length == 1) {
                        var data = filteredContent.toList()[0].dialogFr +
                            " Texte tiré d'un discours de " +
                            filteredContent.toList()[0].author;
                        _speak(data);
                        setState(() {
                          _memory = "";
                        });
                      } else {
                        _speak("aucun résultat trouvé");
                        setState(() {
                          _memory = "";
                        });
                      }

                  }
                }(),
              ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      flutterTts.stop();
    }
  }

  //code pour speecher
  initTts() async {
    flutterTts = FlutterTts();


    _getLanguages();

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    languages = "fr-FR";
    if (languages != null) setState(() => languages);
  }

  Future _speak(data) async {
    await flutterTts.setLanguage(languages);
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    print(_text);
    if (_text != null) {
      if (_text.isNotEmpty) {
        var result = await flutterTts.speak(data);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  void translateToSpeech(text) {
    final translator = GoogleTranslator();

    translator.translate(text, from: 'en', to: 'fr').then((res){

      _speak(res.text);
      setState(() {
        _memory = _text;
      });
      _listen();
    });
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPython() async {
  //   print('initPython');
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     StarCoreFactory starcore = await Starflut.getFactory();
  //     StarServiceClass Service = await starcore.initSimple(
  //         "test", "123", 0, 0, []);
  //     await starcore
  //         .regMsgCallBackP((int serviceGroupID, int uMsg, Object wParam,
  //         Object lParam) async {
  //       print("$serviceGroupID  $uMsg   $wParam   $lParam");
  //
  //       return null;
  //     });
  //     StarSrvGroupClass SrvGroup = await Service["_ServiceGroup"];
  //
  //     /*---script python--*/
  //     bool isAndroid = await Starflut.isAndroid();
  //     if (isAndroid == true) {
  //       // await Starflut.copyFileFromAssets(
  //       //     "testcallback.py", "assets/starfiles",
  //       //     "assets/starfiles");
  //       // await Starflut.copyFileFromAssets(
  //       //     "testpy.py", "assets/starfiles",
  //       //     "assets/starfiles");
  //       await Starflut.copyFileFromAssets(
  //           "python3.6.zip", "assets/starfiles",
  //           null); //desRelatePath must be null
  //       var nativepath = await Starflut.getNativeLibraryDir();
  //       var LibraryPath = "";
  //       if( nativepath.contains("x86_64"))
  //         LibraryPath = "x86_64";
  //       else if( nativepath.contains("arm64"))
  //         LibraryPath = "arm64-v8a";
  //       else if( nativepath.contains("arm"))
  //         LibraryPath = "armeabi";
  //       else if( nativepath.contains("x86"))
  //         LibraryPath = "x86";
  //       await Starflut.copyFileFromAssets("zlib.cpython-36m.so", LibraryPath, null);
  //       await Starflut.copyFileFromAssets(
  //           "unicodedata.cpython-36m.so", LibraryPath, null);
  //       await Starflut.loadLibrary("libpython3.6m.so");
  //     }
  //
  //     String docPath = await Starflut.getDocumentPath();
  //     print("docPath = $docPath");
  //     String resPath = await Starflut.getResourcePath();
  //     print("resPath = $resPath");
  //     dynamic rr1 = await SrvGroup.initRaw("python36", Service);
  //
  //     print("initRaw = $rr1");
  //     var Result = await SrvGroup.loadRawModule(
  //         "python", "", resPath + "/assets/starfiles/" + "testpy.py",
  //         false);
  //     print("loadRawModule = $Result");
  //     dynamic python = await Service.importRawContext(
  //         null, "python", "", false, "");
  //     print("python = " + await python.getString());
  //     StarObjectClass retobj = await python.call("tt", ["hello ", "world"]);
  //     print(await retobj[0]);
  //     print(await retobj[1]);
  //     print(await python["g1"]);
  //     StarObjectClass yy = await python.call("yy", ["hello ", "world", 123]);
  //     print(await yy.call("__len__", []));
  //     StarObjectClass multiply = await Service.importRawContext(
  //         null, "python", "Multiply", true, "");
  //     StarObjectClass multiply_inst = await multiply.newObject(
  //         ["", "", 33, 44]);
  //     print(await multiply_inst.getString());
  //     print(await multiply_inst.call("multiply", [11, 22]));
  //     await SrvGroup.clearService();
  //     await starcore.moduleExit();
  //     platformVersion = 'Python 3.6';
  //   } on PlatformException catch (e) {
  //     print("{$e.message}");
  //     platformVersion = 'Failed to get platform version.';
  //   }
  //
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //
  //   if (!mounted) return;
  //
  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }
}
