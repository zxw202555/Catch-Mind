import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../data/preset_tags.dart';
import '../providers/language_provider.dart';

class TagSelector extends StatefulWidget {
  final void Function(String tag, String emoji, String color) onTagSelected;
  final String? initialTag;

  const TagSelector({
    super.key,
    required this.onTagSelected,
    this.initialTag,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.initialTag ?? kPresetTags.first.name;
  }

  Map<String, String> _loadCustom() {
    try {
      final box = Hive.box<String>('custom_tags');
      final map = <String, String>{};
      for (var key in box.keys) {
        if (key is String) {
          final value = box.get(key);
          if (value is String) {
            map[key] = value;
          }
        }
      }
      return map;
    } catch (e) {
      print('Error loading custom tags: $e');
      return {};
    }
  }

  static const _palette = <String>[
    '#C62828',
    '#AD1457',
    '#6A1B9A',
    '#283593',
    '#1565C0',
    '#00838F',
    '#2E7D32',
    '#F9A825',
    '#EF6C00',
    '#4E342E',
  ];

  Future<void> _addCustom() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController();
    var colorHex = _palette.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(l10n.tagCustomTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.tagNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emojiCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.tagEmojiLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setLocal(() => emojiCtrl.text = ''),
                        child: Text(l10n.tagNoEmoji),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.tagColorLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _palette.map((hex) {
                        final selected = colorHex == hex;
                        final c = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                        return GestureDetector(
                          onTap: () => setLocal(() => colorHex = hex),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: selected ? 3 : 1,
                                color: selected ? Colors.black87 : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.dialogCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.dialogSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true || !mounted) return;

    final name = nameCtrl.text.trim();
    final emoji = emojiCtrl.text.trim();
    if (name.isEmpty) return;

    try {
      final box = Hive.box<String>('custom_tags');
      await box.put(name, '$emoji|$colorHex');
      setState(() {
        _selectedTag = name;
        widget.onTagSelected(name, emoji, colorHex);
      });
    } catch (e) {
      print('Error saving custom tag: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    final custom = _loadCustom();
    
    // 过滤预设标签，排除已被自定义标签覆盖的
    final filteredPresets = kPresetTags.where((tag) => !custom.containsKey(tag.name)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...filteredPresets.map((tag) {
              final isSelected = _selectedTag == tag.name;
              final displayName = l10n.getTagName(tag.name);
              return _tagChip(
                label: displayName,
                emoji: tag.emoji,
                colorHex: tag.colorHex,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedTag = tag.name);
                  widget.onTagSelected(tag.name, tag.emoji, tag.colorHex);
                },
              );
            }),
            ...custom.entries.map((e) {
              final parts = e.value.split('|');
              final emoji = parts.isNotEmpty ? parts[0] : '';
              final hex = parts.length > 1 ? parts[1] : '#607D8B';
              final isSelected = _selectedTag == e.key;
              return _tagChip(
                label: e.key,
                emoji: emoji,
                colorHex: hex,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedTag = e.key);
                  widget.onTagSelected(e.key, emoji, hex);
                },
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addCustom,
          icon: const Icon(Icons.add),
          label: Text(l10n.tagAddCustom),
        ),
      ],
    );
  }

  Future<void> _editTag(String oldName, String oldEmoji, String oldColor) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    
    final nameCtrl = TextEditingController(text: oldName);
    final emojiCtrl = TextEditingController(text: oldEmoji);
    var colorHex = oldColor;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(l10n.tagEditTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.tagNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emojiCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.tagEmojiLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setLocal(() => emojiCtrl.text = ''),
                        child: Text(l10n.tagNoEmoji),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.tagColorLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _palette.map((hex) {
                        final selected = colorHex == hex;
                        final c = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                        return GestureDetector(
                          onTap: () => setLocal(() => colorHex = hex),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: selected ? 3 : 1,
                                color: selected ? Colors.black87 : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.dialogCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.dialogSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true || !mounted) return;

    final newName = nameCtrl.text.trim();
    final newEmoji = emojiCtrl.text.trim();
    if (newName.isEmpty) return;

    try {
      final box = Hive.box<String>('custom_tags');
      
      // 检查旧标签是否是自定义标签
      final isCustomTag = box.containsKey(oldName);
      
      // 如果名称改变，删除旧标签
      if (newName != oldName && isCustomTag) {
        await box.delete(oldName);
      }
      
      // 保存新标签
      await box.put(newName, '$newEmoji|$colorHex');
      
      // 刷新UI
      setState(() {
        _selectedTag = newName;
        widget.onTagSelected(newName, newEmoji, colorHex);
      });
    } catch (e) {
      print('Error editing tag: $e');
    }
  }

  Widget _tagChip({
    required String label,
    required String emoji,
    required String colorHex,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: () {
        // 对于所有标签，都可以通过双击进行编辑
        _editTag(label, emoji, colorHex);
      },
      onSecondaryTap: () {
        // 右键点击删除标签
        _deleteTag(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji.isNotEmpty) ...[
              Text(emoji),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTag(String tagName) async {
    // 预设标签不能删除
    if (kPresetTags.any((t) => t.name == tagName)) {
      return;
    }

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations(languageProvider.currentLanguage);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.tagDeleteTitle),
          content: Text('${l10n.tagDeleteConfirm} "$tagName" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    try {
      final box = Hive.box<String>('custom_tags');
      await box.delete(tagName);
      setState(() {
        // 如果删除的是当前选中的标签，重置选中状态
        if (_selectedTag == tagName) {
          _selectedTag = kPresetTags.first.name;
          widget.onTagSelected(
            kPresetTags.first.name,
            kPresetTags.first.emoji,
            kPresetTags.first.colorHex,
          );
        }
      });
    } catch (e) {
      print('Error deleting tag: $e');
    }
  }
}
