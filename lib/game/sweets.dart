import 'package:flutter/material.dart';

/// The six Iraqi sweets. Original art: a colour + an emoji, never copied
/// Candy Crush assets.
enum SweetType { baklava, zalabia, kunafa, kleicha, dehin, manna }

extension SweetTypeInfo on SweetType {
  String get arabicName => switch (this) {
        SweetType.baklava => 'بقلاوة',
        SweetType.zalabia => 'زلابية',
        SweetType.kunafa => 'كنافة',
        SweetType.kleicha => 'كليجة',
        SweetType.dehin => 'دهين',
        SweetType.manna => 'من السما',
      };

  Color get color => switch (this) {
        SweetType.baklava => const Color(0xFFD4A017),
        SweetType.zalabia => const Color(0xFFE67E22),
        SweetType.kunafa => const Color(0xFFF1C40F),
        SweetType.kleicha => const Color(0xFF8D5A2B),
        SweetType.dehin => const Color(0xFFD9C39A),
        SweetType.manna => const Color(0xFF7CB342),
      };

  Color get darkColor => switch (this) {
        SweetType.baklava => const Color(0xFF9A7200),
        SweetType.zalabia => const Color(0xFFB45309),
        SweetType.kunafa => const Color(0xFFB7950B),
        SweetType.kleicha => const Color(0xFF5D3A17),
        SweetType.dehin => const Color(0xFFA68B5B),
        SweetType.manna => const Color(0xFF558B2F),
      };

  String get emoji => switch (this) {
        SweetType.baklava => '🥮',
        SweetType.zalabia => '🍩',
        SweetType.kunafa => '🍮',
        SweetType.kleicha => '🍪',
        SweetType.dehin => '🍯',
        SweetType.manna => '🥜',
      };
}
