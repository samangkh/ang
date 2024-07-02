import 'dart:convert';

import 'package:ang/voice_controller.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Motorized extends StatefulWidget {
  const Motorized({super.key});

  @override
  State<Motorized> createState() => _MotorizedState();
}

class _MotorizedState extends State<Motorized> {
   MqttServerClient? client;
  Map<String, dynamic> jsonData = {};
  List<bool> motors = List.filled(10, false);

  @override
  void initState() {
    super.initState();
    connectToMqttBroker();
  }

  void _handleVoiceCommand(String command) {
    for (int i = 0; i < motors.length; i++) {
      if (command.toLowerCase().contains('turn on m${i + 1}')) {
        setState(() {
          motors[i] = true;
        });
        _toggleLight(i, true);
      } else if (command.toLowerCase().contains('turn off m${i + 1}')) {
        setState(() {
          motors[i] = false;
        });
        _toggleLight(i, false);
      }
    }
  }

  void connectToMqttBroker() async {
    client = MqttServerClient('broker.hivemq.com','Ang003');
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
        .withClientIdentifier('Ang004')
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
      for (int i =0; i < motors.length; i++) {
        if ('true' == '${jsonData['ns=4;i=${i+46}']}') {
          setState(() {
            motors[i] = true;
          });
        } else if ('false' == '${jsonData['ns=4;i=${i+46}']}') {
          setState(() {
            motors[i] = false;
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
        'test/node_${index+1}', MqttQos.atMostOnce, builder.payload!);
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
          'Motorized Penstock',
          style: TextStyle(
              fontFamily: "Google", fontSize: 25, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 21, 92, 222),
      ),
      body: ListView.builder(
        itemCount: motors.length,
        itemBuilder: (context, index) {
          return Container(
            height: 60,
            child: ListTile(
              leading: CircleAvatar(
                child: Image.asset('lib/images/servo.png'),
              ),
              title: Text(
                'MOP-${1000 + index + 1}',
                style: TextStyle(
                    fontFamily: "Google",
                    fontSize: 25,
                    color: Color.fromARGB(255, 13, 6, 150),
                    fontWeight: FontWeight.w300),
              ),
              trailing: Switch(
                value: motors[index],
                onChanged: (newValue) {
                  setState(() {
                    motors[index] = newValue;
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