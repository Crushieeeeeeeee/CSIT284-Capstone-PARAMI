import 'package:flutter/material.dart';

import 'admin_screen.dart';
import 'schedule_screen.dart';
import 'standings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _adminPin = '2468'; // change this

  Future<void> _openAdmin() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin PIN'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(hintText: '4-digit PIN'),
          onSubmitted: (v) => Navigator.pop(ctx, v == _adminPin),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text == _adminPin),
            child: const Text('Enter'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminScreen()),
      );
    } else if (ok == false && controller.text.isNotEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Wrong PIN')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Schedule', 'Standings'];
    return Scaffold(
      appBar: AppBar(
        // Long-press the title to open the hidden admin screen.
        title: GestureDetector(
          onLongPress: _openAdmin,
          child: Text('Intrams · ${titles[_index]}'),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: const [ScheduleScreen(), StandingsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: 'Schedule'),
          NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(Icons.leaderboard),
              label: 'Standings'),
        ],
      ),
    );
  }
}