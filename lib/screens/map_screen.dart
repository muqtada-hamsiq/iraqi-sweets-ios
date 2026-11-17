import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../services/progress.dart';
import '../theme.dart';
import 'game_screen.dart';

/// Level map: a winding path of 200 nodes in 7 governorate sections,
/// each node named after a real area in its governorate.
class MapScreen extends StatefulWidget {
  const MapScreen({required this.progress, super.key});

  final ProgressService progress;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final levels = allLevels;
    final children = <Widget>[];
    var sectionStart = 0;
    for (var s = 0; s < governorates.length; s++) {
      final gov = governorates[s];
      final count = gov.areas.length;
      final end = sectionStart + count;
      children.add(_sectionHeader(gov.name, sectionStart + 1, end, Color(gov.colorValue)));
      for (var i = sectionStart; i < end; i++) {
        children.add(_levelNode(levels[i]));
      }
      sectionStart = end;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('خريطة العراق')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: children,
      ),
    );
  }

  Widget _sectionHeader(String name, int from, int to, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Text('المراحل $from - $to', style: const TextStyle(color: SweetsTheme.softCream)),
        ],
      ),
    );
  }

  Widget _levelNode(LevelDef level) {
    final unlocked = level.number <= widget.progress.unlockedLevel;
    final stars = widget.progress.starsFor(level.number);
    final color = Color(governorates[level.sectionIndex].colorValue);
    // Winding path: the node drifts left/right along a sine wave.
    final drift = math.sin(level.number * 0.85) * 0.55;
    return Align(
      alignment: Alignment(drift, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            GestureDetector(
              onTap: unlocked
                  ? () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GameScreen(level: level, progress: widget.progress),
                        ),
                      );
                      setState(() {});
                    }
                  : null,
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked ? color : Colors.grey.shade800,
                  border: Border.all(color: SweetsTheme.goldLight, width: 2),
                  boxShadow: unlocked
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: unlocked
                      ? Text(
                          '${level.number}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.lock, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  level.area,
                  style: TextStyle(
                    fontSize: 13,
                    color: unlocked ? SweetsTheme.cream : Colors.grey,
                  ),
                ),
                if (stars > 0) ...[
                  const SizedBox(width: 4),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Icon(
                          i < stars ? Icons.star : Icons.star_border,
                          size: 13,
                          color: SweetsTheme.gold,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
