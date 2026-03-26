import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 语言类型枚举
enum LanguageType { chinese, english }

/// 语言管理 Provider
class LanguageProvider extends ChangeNotifier {
  static const String _storageKey = 'app_language';
  LanguageType _currentLanguage = LanguageType.english;

  LanguageType get currentLanguage => _currentLanguage;
  bool get isEnglish => _currentLanguage == LanguageType.english;

  LanguageProvider() {
    _loadLanguage();
  }

  /// 从本地存储加载语言设置
  void _loadLanguage() {
    try {
      final box = Hive.box<String>('settings');
      final savedLanguage = box.get(_storageKey);
      if (savedLanguage != null) {
        _currentLanguage = savedLanguage == 'english' 
            ? LanguageType.english 
            : LanguageType.chinese;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading language: $e');
    }
  }

  /// 保存语言设置到本地
  Future<void> _saveLanguage() async {
    try {
      final box = Hive.box<String>('settings');
      await box.put(_storageKey, 
          _currentLanguage == LanguageType.english ? 'english' : 'chinese');
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  /// 切换语言
  void toggleLanguage() {
    _currentLanguage = _currentLanguage == LanguageType.chinese 
        ? LanguageType.english 
        : LanguageType.chinese;
    _saveLanguage();
    notifyListeners();
  }

  /// 设置特定语言
  void setLanguage(LanguageType language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      _saveLanguage();
      notifyListeners();
    }
  }
}

/// 国际化文本管理类
class AppLocalizations {
  final LanguageType language;

  AppLocalizations(this.language);

  bool get isEnglish => language == LanguageType.english;

  // ==================== 底部导航 ====================
  String get navMustDo => isEnglish ? 'Must-Do' : '必须完成';
  String get navNonMustDo => isEnglish ? 'Optional' : '非必须';
  String get navDiary => isEnglish ? 'Journal' : '日记本';
  String get navCompleted => isEnglish ? 'Done' : '已完成';

  // ==================== 页面标题 ====================
  String get titleMustDo => isEnglish ? 'Must-Do' : '必须完成';
  String get titleNonMustDo => isEnglish ? 'Optional' : '非必须';
  String get titleDiary => isEnglish ? 'Journal' : '日记本';
  String get titleCompleted => isEnglish ? 'Completed' : '已完成';

  // ==================== 象限名称 (Must Do) ====================
  String get quadrantImportantUrgent => isEnglish ? 'Critical' : '重要紧急';
  String get quadrantImportantNotUrgent => isEnglish ? 'Strategic' : '重要不紧急';
  String get quadrantUrgentNotImportant => isEnglish ? 'Quick Wins' : '不重要紧急';
  String get quadrantNotImportantNotUrgent => isEnglish ? 'Backburner' : '不重要不紧急';

  // ==================== 非必须分类 ====================
  String get categoryExperience => isEnglish ? 'Try It Out' : '体验一下';
  String get categoryDevelopment => isEnglish ? 'Long-term Growth' : '长期发展';

  // ==================== 已完成页面分类 ====================
  String get completedMustDo => isEnglish ? 'Must-Do' : '必须';
  String get completedNonMustDo => isEnglish ? 'Optional' : '非必须';

  // ==================== 空状态提示 ====================
  String get emptyState => isEnglish ? '✨ All clear here' : '✨ 这里还很清爽';
  String get emptyDiary => isEnglish ? 'No journal entries yet' : '暂无感悟复盘';
  String get emptyInbox => isEnglish 
      ? 'No pending items. Tap + to create new, or drag to "Optional" below.' 
      : '暂无待分拣。点右下角 + 新建；可拖到下方「非必须」条。';

  // ==================== 拖拽提示 ====================
  String get dragToNonMust => isEnglish 
      ? 'Drag here to make Optional' 
      : '拖动事项到这里 变为 非必须';
  String get dragToNonMustActive => isEnglish 
      ? 'Release to make Optional' 
      : '松开 变为 非必须';
  String get dragToMust => isEnglish 
      ? 'Drag here to make Must-Do (starts in Critical)' 
      : '拖动事项到这里 变为 必须（先进入「重要紧急」）';
  String get dragToMustActive => isEnglish 
      ? 'Release to make Must-Do' 
      : '松开 变为 必须';
  String get dragToDelete => isEnglish 
      ? 'Drag here to delete' 
      : '拖拽事项到这里删除';
  String get dragToDeleteActive => isEnglish 
      ? 'Release to delete' 
      : '松开删除事项';

  // ==================== 待分拣提示 ====================
  String get inboxHint => isEnglish 
      ? 'To sort → Drag to a quadrant, or to the "Optional" strip at the bottom' 
      : '待分拣 → 拖到象限，或拖到屏幕最下方「非必须」条';

  // ==================== 已完成页面提示 ====================
  String get completedHint => isEnglish 
      ? 'Tap to edit · Double-tap to restore · Long press to drag to delete' 
      : '单击编辑 · 双击恢复未完成 · 长按拖到下方删除';

  // ==================== 工具提示 ====================
  String get tooltipMerge => isEnglish ? 'Group by tag' : '按标签合并';
  String get tooltipUnmerge => isEnglish ? 'Ungroup' : '取消合并';
  String get tooltipMergeByDate => isEnglish ? 'Group by date' : '按日期合并';

  // ==================== 添加/编辑对话框 ====================
  String get dialogAddTitle => isEnglish ? '✨ Capture your thought' : '✨ 捕捉你的想法';
  String get dialogEditTitle => isEnglish ? '✨ Edit item' : '✨ 编辑事项';
  String get dialogHint => isEnglish ? 'Enter your task...' : '输入你的事项…';
  String get dialogContentRequired => isEnglish ? 'Please enter content' : '请输入内容';
  String get dialogDeadline => isEnglish ? 'Due' : 'ddl';
  String get dialogDeadlineNone => isEnglish ? 'None' : '无';
  String get dialogDeadlineNotSelected => isEnglish ? 'Not selected' : '未选择';
  String get dialogSelect => isEnglish ? 'Select' : '选择';
  String get dialogClear => isEnglish ? 'Clear' : '清除';
  String get dialogExpand => isEnglish ? 'Tag & Due date' : '标签与截止时间';
  String get dialogCollapse => isEnglish ? 'Hide tag & due date' : '收起标签与截止时间';
  String get dialogCancel => isEnglish ? 'Cancel' : '取消';
  String get dialogSave => isEnglish ? 'Save' : '保存';
  String get dialogReview => isEnglish ? 'Reflection' : '复盘';
  String get dialogReviewHint => isEnglish ? 'Enter your reflection...' : '输入复盘内容…';

  // ==================== 标签选择器 ====================
  String get tagCustomTitle => isEnglish ? 'Custom Tag' : '自定义标签';
  String get tagEditTitle => isEnglish ? 'Edit Tag' : '编辑标签';
  String get tagNameLabel => isEnglish ? 'Tag name' : '标签名称';
  String get tagEmojiLabel => isEnglish ? 'Emoji' : 'Emoji';
  String get tagNoEmoji => isEnglish ? 'No emoji' : '不要Emoji';
  String get tagColorLabel => isEnglish ? 'Color' : '色块';
  String get tagAddCustom => isEnglish ? 'Add custom tag' : '添加自定义标签';
  String get tagDeleteTitle => isEnglish ? 'Delete Tag' : '删除标签';
  String get tagDeleteConfirm => isEnglish 
      ? 'Are you sure you want to delete tag' 
      : '确定要删除标签';

  // ==================== 删除确认对话框 ====================
  String get deleteTaskTitle => isEnglish ? 'Delete Item' : '删除事项';
  String get deleteTaskConfirm => isEnglish 
      ? 'Are you sure you want to delete' 
      : '确定要删除事项';
  String get delete => isEnglish ? 'Delete' : '删除';

  // ==================== SnackBar 提示 ====================
  String get snackbarSaved => isEnglish ? 'Saved' : '已保存';
  String get snackbarUpdated => isEnglish ? 'Updated' : '已更新';
  String get snackbarDeleted => isEnglish ? 'Deleted' : '已删除';
  String get snackbarRestored => isEnglish ? 'Restored to incomplete' : '已恢复为未完成';
  String get snackbarMovedToMust => isEnglish 
      ? 'Moved to Must-Do, defaults to Critical' 
      : '已移到「必须」，默认在「重要紧急」';
  String get snackbarMovedToNonMust => isEnglish 
      ? 'Moved to Optional' 
      : '已移到「非必须」';
  String get snackbarMovedToQuadrant => isEnglish 
      ? 'Moved to' 
      : '已归入「';
  String get snackbarMovedToQuadrantSuffix => isEnglish ? '' : '」';

  // ==================== 时间信息 ====================
  String get timeCreated => isEnglish ? 'Created' : '创立时间';
  String get timeCompleted => isEnglish ? 'Completed' : '完成时间';
  String get timeEdited => isEnglish ? 'Edited' : '编辑时间';
  String get timeShow => isEnglish ? 'Show time info' : '显示时间信息';
  String get timeHide => isEnglish ? 'Hide time info' : '收起时间信息';
  String get reviewLabel => isEnglish ? 'Reflection' : '复盘';

  // ==================== 语言切换 ====================
  String get languageSwitch => isEnglish ? 'Language' : '语言';
  String get languageChinese => isEnglish ? '中文' : '中文';
  String get languageEnglish => isEnglish ? 'English' : 'English';

  // ==================== 预设标签 ====================
  String get tagWork => isEnglish ? 'Work' : '工作事业';
  String get tagStudy => isEnglish ? 'Study' : '学业学术';
  String get tagHobby => isEnglish ? 'Fun & Hobbies' : '兴趣娱乐';
  String get tagVolunteer => isEnglish ? 'Volunteering' : '志愿工作';
  String get tagCareer => isEnglish ? 'Career Growth' : '事业提升';
  String get tagShopping => isEnglish ? 'Shopping' : '采购';
  String get tagCleaning => isEnglish ? 'Chores' : '清洁护理';
  String get tagAppointment => isEnglish ? 'Appointments' : '和别人的约定';
  String get tagUncategorized => isEnglish ? 'Uncategorized' : '未分类';
  String get tagReflection => isEnglish ? 'Reflections' : '感悟复盘';

  /// 获取标签的本地化名称
  String getTagName(String tagName) {
    switch (tagName) {
      case '工作事业':
        return tagWork;
      case '学业学术':
        return tagStudy;
      case '兴趣娱乐':
        return tagHobby;
      case '志愿工作':
        return tagVolunteer;
      case '事业提升':
        return tagCareer;
      case '采购':
        return tagShopping;
      case '清洁护理':
        return tagCleaning;
      case '和别人的约定':
        return tagAppointment;
      case '未分类':
        return tagUncategorized;
      case '感悟复盘':
        return tagReflection;
      default:
        return tagName; // 自定义标签保持原样
    }
  }

  /// 获取象限的本地化名称
  String getQuadrantName(String quadrantName) {
    switch (quadrantName) {
      case '重要紧急':
        return quadrantImportantUrgent;
      case '重要不紧急':
        return quadrantImportantNotUrgent;
      case '不重要紧急':
        return quadrantUrgentNotImportant;
      case '不重要不紧急':
        return quadrantNotImportantNotUrgent;
      case 'experience':
        return categoryExperience;
      case 'development':
        return categoryDevelopment;
      default:
        return quadrantName;
    }
  }

  /// 获取反向映射（用于保存数据时）
  String getQuadrantKey(String localizedName) {
    if (localizedName == quadrantImportantUrgent) return '重要紧急';
    if (localizedName == quadrantImportantNotUrgent) return '重要不紧急';
    if (localizedName == quadrantUrgentNotImportant) return '不重要紧急';
    if (localizedName == quadrantNotImportantNotUrgent) return '不重要不紧急';
    if (localizedName == categoryExperience) return 'experience';
    if (localizedName == categoryDevelopment) return 'development';
    return localizedName;
  }
}

/// 全局访问便捷方法
extension LanguageExtension on BuildContext {
  LanguageProvider get languageProvider {
    // 使用 listen: false 避免不必要的重建
    // 实际使用时需要通过 Consumer 或 Selector 监听变化
    throw UnimplementedError('Use context.watch<LanguageProvider>() or context.read<LanguageProvider>() instead');
  }
}
