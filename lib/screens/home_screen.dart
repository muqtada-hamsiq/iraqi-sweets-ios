import 'package:flutter/material.dart';

import '../services/progress.dart';
import '../theme.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.progress, super.key});

  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1D12), SweetsTheme.deepBrown],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🍯', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 8),
                const Text(
                  'حلويات عراقية',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: SweetsTheme.goldLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Iraqi Sweets',
                  style: TextStyle(fontSize: 20, color: SweetsTheme.softCream),
                ),
                const SizedBox(height: 16),
                const Text(
                  'طابق الحلويات العراقية واعبر 200 مرحلة\nمن بغداد للسليمانية، مرحلة مرحلة',
                  style: TextStyle(fontSize: 17, color: SweetsTheme.cream),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: SweetsTheme.gold, size: 28),
                    const SizedBox(width: 6),
                    Text(
                      '${progress.totalStars} / 600 نجمة',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'واصل للمرحلة ${progress.unlockedLevel} من 200',
                  style: const TextStyle(color: SweetsTheme.softCream),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MapScreen(progress: progress),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('العب'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _showHowToPlay(context),
                  child: const Text(
                    'شلون تلعب؟',
                    style: TextStyle(color: SweetsTheme.goldLight, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'بقلاوة • زلابية • كنافة • كليجة • دهين • من السما',
                  style: TextStyle(color: SweetsTheme.softCream),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SweetsTheme.panelBrown,
        title: const Text('شلون تلعب؟', textAlign: TextAlign.center),
        content: const Text(
          '• دوس على حلوى، وبعدين دوس على اللي يمها حتى تبدلهم.\n'
          '• طابق 3 أو أكثر من نفس النوع حتى يختفون وتاخذ نقاط.\n'
          '• طابق 4 يسوي قطعة مخططة تمسح صف أو عمود.\n'
          '• طابق 5 يسوي قنبلة ملونة تمسح كل قطع من نوع واحد.\n'
          '• الشكل L أو T يسوي قطعة ملفوفة تفجر اللي حواليها.\n'
          '• الشوكولاتة حاجز: طابق يمها حتى تكسرها.\n'
          '• اجمع النقاط المطلوبة قبل ما تخلص الحركات.',
          style: TextStyle(height: 1.7),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تمام', style: TextStyle(color: SweetsTheme.goldLight)),
          ),
        ],
      ),
    );
  }
}
