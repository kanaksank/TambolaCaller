import 'package:flutter/material.dart';

import 'board_screen.dart';
import 'caller_screen.dart';

/// Two-tab shell: the caller and the full number board.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool isLandscape = size.width > size.height;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const <Widget>[
          CallerScreen(),
          BoardScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: isLandscape ? 60 : 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int index) => setState(() => _index = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'CALLER',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'NUMBER BOARD',
          ),
        ],
      ),
    );
  }
}
