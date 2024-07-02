import 'dart:convert';
import 'package:ang/voice_controller.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Pumps extends StatefulWidget {
  const Pumps({super.key});

  @override
  State<Pumps> createState() => _PumpsState();
}

class _PumpsState extends State<Pumps> {
  MqttServerClient? client;
  Map<String, dynamic> jsonData = {};
  List<bool> lights = List.filled(7, false);

  @override
  void initState() {
    super.initState();
    connectToMqttBroker();
  }

  void _handleVoiceCommand(String command) {
    for (int i = 0; i < lights.length; i++) {
      if (command.toLowerCase().contains('turn on p${i + 1}')) {
        setState(() {
          lights[i] = true;
        });
        _toggleLight(i, true);
      } else if (command.toLowerCase().contains('turn off p${i + 1}')) {
        setState(() {
          lights[i] = false;
        });
        _toggleLight(i, false);
      }
    }
  }

  void connectToMqttBroker() async {
    client = MqttServerClient('broker.hivemq.com', 'Ang002');
    client!.port = 1883;
    client!.logging(on: true);
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;
    client!.onSubscribed = onSubscribed;
    client!.onSubscribeFail = onSubscribeFail;
    client!.autoReconnect = true;
    client!.onAutoReconnect = onAutoReconnect;
    client!.onAutoReconnected = onAutoReconnected;
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter')
        .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('My will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    try {
      await client!.connect();
    } catch (e) {
      print('Exception: $e');
      client!.disconnect();
    }
  }

  void onConnected() {
    print('Connected to MQTT broker');
    client!.subscribe('plcdata/opcua', MqttQos.atLeastOnce);
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        jsonData = jsonDecode(payload);
      });
      print("$payload");
      for (int i = 0; i < lights.length; i++) {
        if ('true' == '${jsonData['ns=4;i=${i + 22}']}') {
          setState(() {
            lights[i] = true;
          });
        } else if ('false' == '${jsonData['ns=4;i=${i + 22}']}') {
          setState(() {
            lights[i] = false;
          });
        }
      }
    });
  }

  void _toggleLight(int index, bool newValue) {
    String command = newValue ? 'true' : 'false';
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(command);
    client!.publishMessage(
        'test/node_${index + 11}', MqttQos.atMostOnce, builder.payload!);
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void onSubscribeFail(String topic) {
    print('Failed to subscribe to topic: $topic');
  }

  void onAutoReconnect() {
    print('Client auto reconnection sequence will start');
  }

  void onAutoReconnected() {
    print('Client auto reconnection sequence has completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PUMPS',
          style: TextStyle(
              fontFamily: "Google", fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 21, 92, 222),
      ),
      body: ListView.builder(
        itemCount: lights.length,
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            child: ListTile(
              leading: CircleAvatar(
                child: Image.asset('lib/images/pump.png'),
              ),
              title: Text(
                index == 0 ? 'Manual / Auto' : 'P-${1000 + index + 1}',
                style: TextStyle(
                    fontFamily: "Google",
                    fontSize: 25,
                    color: Color.fromARGB(255, 13, 6, 150),
                    fontWeight: FontWeight.w300),
              ),
              trailing: Switch(
                value: lights[index],
                onChanged: (newValue) {
                  setState(() {
                    lights[index] = newValue;
                  });
                  _toggleLight(index, newValue);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: VoiceController(
        onCommandReceived: _handleVoiceCommand,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
