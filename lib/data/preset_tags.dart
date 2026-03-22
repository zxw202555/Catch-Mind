import 'package:flutter/material.dart';

/// 系统预设标签：名称、emoji、色块（低饱和柔和色，与暖灰底协调）
class TagPreset {
  final String name;
  final String emoji;
  final String colorHex;

  const TagPreset({
    required this.name,
    required this.emoji,
    required this.colorHex,
  });

  Color get color =>
      Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
}

const List<TagPreset> kPresetTags = [
  TagPreset(name: '工作事业', emoji: '💼', colorHex: '#5A9B91'),
  TagPreset(name: '学业学术', emoji: '📚', colorHex: '#6B8FCC'),
  TagPreset(name: '兴趣娱乐', emoji: '🎮', colorHex: '#D88BA4'),
  TagPreset(name: '志愿工作', emoji: '🙌', colorHex: '#7BA889'),
  TagPreset(name: '事业提升', emoji: '📈', colorHex: '#D4A574'),
  TagPreset(name: '采购', emoji: '🛒', colorHex: '#9A8B7E'),
  TagPreset(name: '清洁护理', emoji: '🧹', colorHex: '#6BB3BC'),
  TagPreset(name: '和别人的约定', emoji: '📅', colorHex: '#9B8FC9'),
  TagPreset(name: '未分类', emoji: '📌', colorHex: '#9CA3A8'),
  TagPreset(name: '感悟复盘', emoji: '📝', colorHex: '#B085C4'),
];
