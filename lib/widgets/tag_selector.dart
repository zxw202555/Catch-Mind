import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/preset_tags.dart';

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
    final box = Hive.box<String>('custom_tags');
    return Map<String, String>.from(box.toMap());
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
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController();
    var colorHex = _palette.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('自定义标签'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: '标签名称',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emojiCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Emoji（一个即可）',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '色块',
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
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('保存'),
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
    if (name.isEmpty || emoji.isEmpty) return;

    final box = Hive.box<String>('custom_tags');
    await box.put(name, '$emoji|$colorHex');
    setState(() {
      _selectedTag = name;
      widget.onTagSelected(name, emoji, colorHex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final custom = _loadCustom();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...kPresetTags.map((tag) {
              final isSelected = _selectedTag == tag.name;
              return _tagChip(
                label: tag.name,
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
              final emoji = parts.isNotEmpty ? parts[0] : '✨';
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
          label: const Text('添加自定义标签'),
        ),
      ],
    );
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
            Text(emoji),
            const SizedBox(width: 4),
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
}
