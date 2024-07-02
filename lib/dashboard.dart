import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
   MqttServerClient? client;
  Map<String, dynamic> jsonData = {};
  @override
  void initState() {
    super.initState();
    connectToMqttBroker();
  }

  void connectToMqttBroker() async {
    client = MqttServerClient('broker.hivemq.com', 'flutter');
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
        .withClientIdentifier('Ang001')
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
    // Subscribe to the topic where temperature data is published
    client!.subscribe('plcdata/opcua', MqttQos.atLeastOnce);
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      setState(() {
        jsonData =
            jsonDecode(payload); // assuming the payload is a valid JSON object
      });
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $payload -->');
      print('');
    });
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
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          title: Text(
            'DASHBOARD',
            style: TextStyle(
                fontFamily: "Google", fontSize: 25, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 21, 92, 222),
        ),
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 88,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 22, 3, 148),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('FIT-1101',
                              style: TextStyle(
                                  fontFamily: "Google",
                                  fontSize: 25,
                                  color: Colors.white)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=2']} m3/h',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 18,
                                color: Color.fromARGB(255, 187, 226, 10)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'FIT-1102',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=3']} m3/h',
                            style: TextStyle(
                              fontFamily: "Google",
                              fontSize: 18,
                              color: Color.fromARGB(255, 187, 226, 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 88,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 22, 3, 148),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('PIT-01',
                              style: TextStyle(
                                  fontFamily: "Google",
                                  fontSize: 25,
                                  color: Colors.white)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=4']} bar',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 18,
                                color: Color.fromARGB(255, 81, 227, 8)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'PIT-02',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=5']} bar',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 18,
                                color: Color.fromARGB(255, 81, 227, 8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 88,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 22, 3, 148),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('LIT-01',
                              style: TextStyle(
                                  fontFamily: "Google",
                                  fontSize: 25,
                                  color: Colors.white)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=6']} m',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 18,
                                color: Color.fromARGB(255, 187, 226, 10)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'LIT-02',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=7']} m',
                            style: TextStyle(
                              fontFamily: "Google",
                              fontSize: 18,
                              color: Color.fromARGB(255, 187, 226, 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 88,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 22, 3, 148),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('LIT-03',
                              style: TextStyle(
                                  fontFamily: "Google",
                                  fontSize: 25,
                                  color: Colors.white)),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=8']} m',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 18,
                                color: Color.fromARGB(255, 81, 227, 8)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'LIT-04',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=9']} m',
                            style: TextStyle(
                              fontFamily: "Google",
                              fontSize: 18,
                              color: Color.fromARGB(255, 81, 227, 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'LIT-05',
                            style: TextStyle(
                                fontFamily: "Google",
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w300),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${jsonData['ns=4;i=10']} m',
                            style: TextStyle(
                              fontFamily: "Google",
                              fontSize: 18,
                              color: Color.fromARGB(255, 81, 227, 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              ListTile(
                leading: CircleAvatar(
                  child: Image.asset('lib/images/ph.png'),
                ),
                title: Text(
                  'AIT-1201 pH Value',
                  style: TextStyle(
                      fontFamily: "Google", fontSize: 18, color: Colors.white),
                ),
                trailing: Text(
                  '${jsonData['ns=4;i=64']}',
                  style: TextStyle(
                      fontFamily: "Google",
                      fontSize: 18,
                      color: Color.fromARGB(255, 81, 227, 8)),
                ),
                tileColor: Color.fromARGB(255, 22, 3, 148),
              ),
              ListTile(
                leading: CircleAvatar(
                  child: Image.asset('lib/images/Do.png'),
                ),
                title: Text(
                  'AIT-1202 DO',
                  style: TextStyle(
                      fontFamily: "Google", fontSize: 18, color: Colors.white),
                ),
                trailing: Text(
                  '${jsonData['ns=4;i=65']}mg/L',
                  style: TextStyle(
                      fontFamily: "Google",
                      fontSize: 18,
                      color: Color.fromARGB(255, 81, 227, 8)),
                ),
                tileColor: Color.fromARGB(255, 22, 3, 148),
              ),
              ListTile(
                leading: CircleAvatar(
                  child: Image.asset('lib/images/turbidity.png'),
                ),
                title: Text(
                  'AIT-1203 Turbidity',
                  style: TextStyle(
                      fontFamily: "Google", fontSize: 18, color: Colors.white),
                ),
                trailing: Text(
                  '${jsonData['ns=4;i=66']} NTU',
                  style: TextStyle(
                      fontFamily: "Google",
                      fontSize: 18,
                      color: Color.fromARGB(255, 81, 227, 8)),
                ),
                tileColor: Color.fromARGB(255, 22, 3, 148),
              ),
              ListTile(
                leading: CircleAvatar(
                  child: Image.asset('lib/images/conductivity.png'),
                ),
                title: Text(
                  'AIT-1204 Conductivity',
                  style: TextStyle(
                      fontFamily: "Google", fontSize: 18, color: Colors.white),
                ),
                trailing: Text(
                  '${jsonData['ns=4;i=67']} uS/cm',
                  style: TextStyle(
                      fontFamily: "Google",
                      fontSize: 18,
                      color: Color.fromARGB(255, 81, 227, 8)),
                ),
                tileColor: Color.fromARGB(255, 22, 3, 148),
              ),
              ListTile(
                leading: CircleAvatar(
                  child: Image.asset('lib/images/temperature.png'),
                ),
                title: Text(
                  'AIT-1205 Temperature',
                  style: TextStyle(
                      fontFamily: "Google", fontSize: 18, color: Colors.white),
                ),
                trailing: Text(
                  '${jsonData['ns=4;i=68']} °C',
                  style: TextStyle(
                      fontFamily: "Google",
                      fontSize: 18,
                      color: Color.fromARGB(255, 81, 227, 8)),
                ),
                tileColor: Color.fromARGB(255, 22, 3, 148),
              ),
            ],
          ),
        ),
      ),
    );
  }
}