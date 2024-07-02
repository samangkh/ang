import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceController extends StatefulWidget {
  final Function(String) onCommandReceived;

  VoiceController({required this.onCommandReceived});

  @override
  _VoiceControllerState createState() => _VoiceControllerState();
}

class _VoiceControllerState extends State<VoiceController> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _command = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.microphone.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        return; // Permission denied, exit the method.
      }
    }
  }

  void _listen() async {
    await _requestMicrophonePermission();

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _command = val.recognizedWords;
            if (val.finalResult) {
              widget.onCommandReceived(_command);
              _isListening = false;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _listen,
      child: Icon(_isListening ? Icons.mic : Icons.mic_none),
    );
  }
}
