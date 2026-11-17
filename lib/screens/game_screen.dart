import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/levels.dart';
import '../game/board.dart';
import '../game/sweets.dart';
import '../services/progress.dart';
import '../theme.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.level, required this.progress, super.key});

  final LevelDef level;
  final ProgressService progress;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Board _board;
  late int _movesLeft;
  int _score = 0;
  int? _selected;
  bool _busy = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _movesLeft = widget.level.moves;
    _board = Board.generate(
      numTypes: widget.level.numTypes,
      blockerCount: widget.level.blockerCount,
    );
  }

  LevelDef get _level => widget.level;

  Future<void> _onTileTap(int index) async {
    if (_busy || _finished || _movesLeft <= 0) return;
    final tile = _board.cells[index];
    if (tile == null || tile.isBlocker) return;
    if (_selected == null) {
      setState(() => _selected = index);
      return;
    }
    if (_selected == index) {
      setState(() => _selected = null);
      return;
    }
    final from = _selected!;
    setState(() => _selected = null);
    if (!_board.areAdjacent(from, index)) {
      setState(() => _selected = index);
      return;
    }
    _busy = true;
    final swapped = _board.trySwap(from, index);
    setState(() {});
    if (!swapped) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _busy = false;
      if (!mounted) return;
      setState(() {});
      return;
    }
    setState(() => _movesLeft--);
    await _resolveCascades();
    _busy = false;
    if (!mounted) return;
    if (_score >= _level.targetScore) {
      _finish(true);
      return;
    }
    if (_movesLeft <= 0) {
      _finish(false);
      return;
    }
    if (!_board.hasPossibleMove()) {
      _board.reshuffle();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ماكو حركة، خلطنا اللوحة')),
      );
    }
  }

  Future<void> _resolveCascades() async {
    while (true) {
      final gained = _board.resolveStep();
      if (gained == 0) break;
      _score += gained;
      HapticFeedback.lightImpact();
      setState(() {});
      await Future<void>.delayed(const Duration(milliseconds: 320));
    }
    if (!_board.hasPossibleMove()) {
      _board.reshuffle();
      setState(() {});
    }
  }

  Future<void> _finish(bool won) async {
    if (_finished) return;
    _finished = true;
    final stars = won ? _level.starsForScore(_score) : 0;
    if (won) await widget.progress.saveResult(_level.number, stars);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: SweetsTheme.panelBrown,
        title: Text(won ? 'مبروك! 🎉' : 'خلصت الحركات', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (won)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      size: 36,
                      color: SweetsTheme.gold,
                    ),
                ],
              ),
            const SizedBox(height: 12),
            Text('المرحلة ${_level.number} - ${_level.area}'),
            Text('نقاطك: $_score من ${_level.targetScore}'),
            if (!won) const Text('جرب مرة ثانية، أنت گدها!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('الخريطة', style: TextStyle(color: SweetsTheme.goldLight)),
          ),
          if (won && _level.number < 200)
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      level: allLevels[_level.number],
                      progress: widget.progress,
                    ),
                  ),
                );
              },
              child: const Text('المرحلة اللي بعدها'),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _board = Board.generate(
                    numTypes: _level.numTypes,
                    blockerCount: _level.blockerCount,
                  );
                  _movesLeft = _level.moves;
                  _score = 0;
                  _finished = false;
                });
              },
              child: const Text('العب مرة ثانية'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_score / _level.targetScore).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: Text('المرحلة ${_level.number} - ${_level.area}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statBox('النقاط', '$_score'),
                _statBox('الهدف', '${_level.targetScore}'),
                _statBox('الحركات', '$_movesLeft'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.brown.shade800,
              color: SweetsTheme.gold,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 4),
            Text(
              '${_level.governorate} • ${_level.area}',
              style: const TextStyle(color: SweetsTheme.softCream),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: SweetsTheme.panelBrown,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SweetsTheme.gold, width: 1.5),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Board.size,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                    ),
                    itemCount: Board.cellCount,
                    itemBuilder: (ctx, i) => _tileWidget(i),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'دوس على حلوى، وبعدين دوس على اللي يمها حتى تبدلهم',
              style: TextStyle(color: SweetsTheme.softCream),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: SweetsTheme.panelBrown,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SweetsTheme.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: SweetsTheme.softCream)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _tileWidget(int index) {
    final tile = _board.cells[index];
    if (tile == null) return const SizedBox.shrink();
    final selected = _selected == index;
    if (tile.isBlocker) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4E342E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown.shade300),
        ),
        child: Center(
          child: Text(
            '🍫${tile.blockerHp > 1 ? tile.blockerHp : ''}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
    }
    final sweet = SweetType.values[tile.type];
    final border = selected
        ? Border.all(color: Colors.white, width: 3)
        : Border.all(color: sweet.darkColor, width: 1);
    Widget content = Text(sweet.emoji, style: const TextStyle(fontSize: 24));
    if (tile.special == SpecialKind.stripedH || tile.special == SpecialKind.stripedV) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          content,
          Icon(
            tile.special == SpecialKind.stripedH ? Icons.remove : Icons.more_vert,
            color: Colors.white,
            size: 30,
          ),
        ],
      );
    } else if (tile.special == SpecialKind.wrapped) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: content,
          ),
        ],
      );
    } else if (tile.special == SpecialKind.bomb) {
      content = const Text('🌈', style: TextStyle(fontSize: 26));
    }
    return GestureDetector(
      onTap: () => _onTileTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: sweet.color,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Center(child: content),
      ),
    );
  }
}
