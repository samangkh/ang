import 'package:ang/dashboard.dart';
import 'package:ang/motorized.dart';
import 'package:ang/pumps.dart';
import 'package:ang/valves.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

 int currentindex=0;
  final screens=[Dashboard(),Pumps(),Motorized(),Valves()];

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        type: BottomNavigationBarType.shifting,
        fixedColor: Colors.white,
        iconSize: 30,
        currentIndex: currentindex,
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
        onTap: (value) {
          currentindex=value;
          setState(() {
          });
        },

        
        items: const[
        BottomNavigationBarItem(backgroundColor: Color.fromARGB(255, 21, 92, 222), icon: Icon(Icons.dashboard),label: 'Dashboard'),
        BottomNavigationBarItem(backgroundColor: Color.fromARGB(255, 21, 92, 222), icon: Icon(Icons.heat_pump),label: 'Pumps'),
        BottomNavigationBarItem(backgroundColor: Color.fromARGB(255, 21, 92, 222), icon: Icon(Icons.close),label: 'Motorized'),
        BottomNavigationBarItem(backgroundColor: Color.fromARGB(255, 21, 92, 222), icon: Icon(Icons.speed),label: 'Valve'),
      ]),
      body: IndexedStack(index: currentindex,children: screens,)
    );
  }
}
