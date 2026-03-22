import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_providers.dart';
import '../theme/catchmind_theme.dart';
import '../widgets/add_task_dialog.dart';
import 'completed_screen.dart';
import 'diary_screen.dart';
import 'must_do_screen.dart';
import 'not_must_do_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = const [
    MustDoScreen(),
    NonMustDoScreen(),
    DiaryScreen(),
    CompletedScreen(),
  ];

  void _acceptDropToMust(Task task, TaskProvider p) {
    p.updateTask(
      task.copyWith(
        routed: true,
        isMustDo: true,
        quadrant: '重要紧急',
      ),
    );
    setState(() => _currentIndex = 0);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已移到「必须」，默认在「重要紧急」'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _acceptDropToNonMust(Task task, TaskProvider p) {
    if (!task.routed) {
      p.updateTask(
        task.copyWith(
          routed: true,
          isMustDo: false,
          quadrant: 'not_classified',
        ),
      );
    } else if (task.isMustDo) {
      p.updateTask(
        task.copyWith(
          isMustDo: false,
          quadrant: 'not_classified',
        ),
      );
    }
    setState(() => _currentIndex = 1);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已移到「非必须」'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Widget _dragStrip({
    required bool active,
    required String idle,
    required String activeLabel,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: active ? CatchMindColors.dragStripActive : CatchMindColors.dragStripIdle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? CatchMindColors.accent.withAlpha(140)
              : CatchMindColors.hairline,
          width: active ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        active ? activeLabel : idle,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: active ? CatchMindColors.accentDeep : CatchMindColors.textPrimary,
          height: 1.35,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _screens[_currentIndex]),
          if (_currentIndex == 0)
            Consumer<TaskProvider>(
              builder: (context, p, _) {
                return DragTarget<Task>(
                  onWillAcceptWithDetails: (_) => true,
                  onAcceptWithDetails: (d) => _acceptDropToNonMust(d.data, p),
                  builder: (context, candidate, _) {
                    final active = candidate.isNotEmpty;
                    return _dragStrip(
                      active: active,
                      idle: '拖动事项到这里 变为 非必须',
                      activeLabel: '松开 变为 非必须',
                    );
                  },
                );
              },
            ),
          if (_currentIndex == 1)
            Consumer<TaskProvider>(
              builder: (context, p, _) {
                return DragTarget<Task>(
                  onWillAcceptWithDetails: (_) => true,
                  onAcceptWithDetails: (d) => _acceptDropToMust(d.data, p),
                  builder: (context, candidate, _) {
                    final active = candidate.isNotEmpty;
                    return _dragStrip(
                      active: active,
                      idle: '拖动事项到这里 变为 必须（先进入「重要紧急」）',
                      activeLabel: '松开 变为 必须',
                    );
                  },
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: '必须完成',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: '非必须',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: '日记本',
          ),
          NavigationDestination(
            icon: Icon(Icons.done_all_outlined),
            selectedIcon: Icon(Icons.done_all),
            label: '已完成',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
