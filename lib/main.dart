import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/task_providers.dart'; // 文件名是 task_providers.dart（多一个 s）
import 'providers/language_provider.dart';
import 'models/task.dart';
import 'screens/home_screen.dart';
import 'theme/catchmind_theme.dart';

void main() async {
  // 初始化Flutter绑定
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化本地化数据
  await initializeDateFormatting('zh_CN', null);
  // 初始化Hive（本地存储）
  await Hive.initFlutter();
  // 注册Task适配器（必须）
  Hive.registerAdapter(TaskAdapter());
  // 打开任务存储盒子
  await Hive.openBox<Task>('tasks');
  // 打开自定义标签存储盒子
  await Hive.openBox<String>('custom_tags');
  // 打开设置存储盒子
  await Hive.openBox<String>('settings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 全局提供Task状态管理
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        // 全局提供语言状态管理
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: MaterialApp(
        title: 'CatchMind',
        debugShowCheckedModeBanner: false,
        theme: buildCatchMindTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}