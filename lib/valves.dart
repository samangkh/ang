import 'dart:convert';
import 'package:ang/voice_controller.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Valves extends StatefulWidget {
  const Valves({super.key});

  @override
  State<Valves> createState() => _ValvesState();
}

class _ValvesState extends State<Valves> {
  MqttServerClient? client;
  Map<String, dynamic> jsonData = {};
  List<bool> valves = List.filled(4, false);

  @override
  void initState() {
    super.initState();
    connectToMqttBroker();
  }

  void _handleVoiceCommand(String command) {
    for (int i = 0; i < valves.length; i++) {
      if (command.toLowerCase().contains('turn on valve${i + 1}')) {
        setState(() {
          valves[i] = true;
        });
        _toggleLight(i, true);
      } else if (command.toLowerCase().contains('turn off valve${i + 1}')) {
        setState(() {
          valves[i] = false;
        });
        _toggleLight(i, false);
      }
    }
  }

  void connectToMqttBroker() async {
    client = MqttServerClient('broker.hivemq.com', 'Ang004');
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
        .withClientIdentifier('Ang003')
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
      for (int i = 0; i < valves.length; i++) {
        if ('true' == '${jsonData['ns=4;i=${i + 60}']}') {
          setState(() {
            valves[i] = true;
          });
        } else if ('false' == '${jsonData['ns=4;i=${i + 60}']}') {
          setState(() {
            valves[i] = false;
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
        'test/node_${index + 17}', MqttQos.atMostOnce, builder.payload!);
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'VALVES',
            style: TextStyle(
                fontFamily: "Google", fontSize: 25, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 21, 92, 222),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Image.asset('lib/images/ph.png'),
              ),
              title: Text(
                'AIT-1201 pH Value',
                style: TextStyle(
                    fontFamily: "Google", fontSize: 18, color: Color.fromARGB(255, 22, 3, 148)),
              ),
              trailing: Text(
                '${jsonData['ns=4;i=64']}',
                style: TextStyle(
                    fontFamily: "Google",
                    fontSize: 18,
                    color: Color.fromARGB(255, 81, 227, 8)),
              ),
              
            ),
            ListTile(
              leading: CircleAvatar(
                child: Image.asset('lib/images/Do.png'),
              ),
              title: Text(
                'AIT-1202 DO',
                style: TextStyle(
                    fontFamily: "Google", fontSize: 18, color: Color.fromARGB(255, 22, 3, 148)),
              ),
              trailing: Text(
                '${jsonData['ns=4;i=65']}mg/L',
                style: TextStyle(
                    fontFamily: "Google",
                    fontSize: 18,
                    color: Color.fromARGB(255, 81, 227, 8)),
              ),
             
            ),
            ListTile(
              leading: CircleAvatar(
                child: Image.asset('lib/images/turbidity.png'),
              ),
              title: Text(
                'AIT-1203 Turbidity',
                style: TextStyle(
                    fontFamily: "Google", fontSize: 18, color: Color.fromARGB(255, 22, 3, 148)),
              ),
              trailing: Text(
                '${jsonData['ns=4;i=66']} NTU',
                style: TextStyle(
                    fontFamily: "Google",
                    fontSize: 18,
                    color: Color.fromARGB(255, 81, 227, 8)),
              ),
              
            ),
            ListTile(
              leading: CircleAvatar(
                child: Image.asset('lib/images/conductivity.png'),
              ),
              title: Text(
                'AIT-1204 Conductivity',
                style: TextStyle(
                    fontFamily: "Google", fontSize: 18, color: Color.fromARGB(255, 22, 3, 148)),
              ),
              trailing: Text(
                '${jsonData['ns=4;i=67']} uS/cm',
                style: TextStyle(
                    fontFamily: "Google",
                    fontSize: 18,
                    color: Color.fromARGB(255, 81, 227, 8)),
              ),
              
            ),
            ListTile(
              leading: CircleAvatar(
                child: Image.asset('lib/images/temperature.png'),
              ),
              title: Text(
                'AIT-1205 Temperature',
                style: TextStyle(
                    fontFamily: "Google", fontSize: 18, color: Color.fromARGB(255, 22, 3, 148)),
              ),
              trailing: Text(
                '${jsonData['ns=4;i=68']} °C',
                style: TextStyle(
                    fontFamily: "Google",
                    fontSize: 18,
                    color: Color.fromARGB(255, 81, 227, 8)),
              ),
              
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: valves.length,
              itemBuilder: (context, index) {
                return Container(
                  height: 100,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Image.asset('lib/images/valve.png'),
                    ),
                    title: Text(
                      'VA-${1000 + index + 1}',
                      style: TextStyle(
                          fontFamily: "Google",
                          fontSize: 25,
                          color: Color.fromARGB(255, 13, 6, 150),
                          fontWeight: FontWeight.w300),
                    ),
                    trailing: Switch(
                      value: valves[index],
                      onChanged: (newValue) {
                        setState(() {
                          valves[index] = newValue;
                        });
                        _toggleLight(index, newValue);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: VoiceController(
          onCommandReceived: _handleVoiceCommand,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
