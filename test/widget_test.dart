import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:catchmind/main.dart';
import 'package:catchmind/models/task.dart';
import 'package:catchmind/providers/task_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>('tasks');
    await Hive.openBox<String>('custom_tags');
  });

  testWidgets('底部导航显示「必须」', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TaskProvider()..loadTasks(),
        child: const CatchMindApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('必须'), findsOneWidget);
  });
}
