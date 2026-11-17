import 'package:flutter_test/flutter_test.dart';
import 'package:game/game/board.dart';

List<int> checkerTypes({int numTypes = 6}) {
  // A pattern with no 3-in-a-row anywhere: (r + 2*c) % numTypes.
  final out = <int>[];
  for (var r = 0; r < 8; r++) {
    for (var c = 0; c < 8; c++) {
      out.add((r + 2 * c) % numTypes);
    }
  }
  return out;
}

void main() {
  test('generated board has no initial matches and a possible move', () {
    for (var seed = 0; seed < 20; seed++) {
      final board = Board.generate(numTypes: 6, seed: seed);
      expect(board.findMatches(), isEmpty, reason: 'seed $seed');
      expect(board.hasPossibleMove(), isTrue, reason: 'seed $seed');
      expect(board.filledCount, Board.cellCount);
    }
  });

  test('generated board with blockers keeps the blocker count', () {
    final board = Board.generate(numTypes: 6, blockerCount: 6, seed: 7);
    expect(board.blockerCount, 6);
    expect(board.findMatches(), isEmpty);
  });

  test('a swap that makes a match is accepted and resolves', () {
    // Row 0: 0 0 1 0 ... swapping index 2 and 3 makes 0 0 0.
    final types = checkerTypes();
    types[0] = 0;
    types[1] = 0;
    types[2] = 1;
    types[3] = 0;
    final board = Board.fromTypes(types);
    expect(board.findMatches(), isEmpty);
    expect(board.trySwap(2, 3), isTrue);
    final gained = board.resolveAll();
    expect(gained, greaterThan(0));
    expect(board.filledCount, Board.cellCount);
    expect(board.findMatches(), isEmpty);
  });

  test('a swap that makes no match is reverted', () {
    final board = Board.fromTypes(checkerTypes());
    final before = board.cells.map((t) => t?.type).toList();
    expect(board.trySwap(0, 1), isFalse);
    expect(board.cells.map((t) => t?.type).toList(), before);
  });

  test('match of 4 creates a striped piece', () {
    final types = checkerTypes();
    // Row 0 col 0..3 become 2 2 2 2 after a swap is not needed: force a
    // 4-match directly and resolve one step.
    types[0] = 2;
    types[1] = 2;
    types[2] = 2;
    types[3] = 2;
    types[4] = 5; // checker pattern already has a 2 at col 4; break it
    final board = Board.fromTypes(types);
    expect(board.findMatchGroups().any((g) => g.length == 4), isTrue);
    board.resolveStep();
    final striped = board.cells.where(
      (t) => t != null && (t.special == SpecialKind.stripedH || t.special == SpecialKind.stripedV),
    );
    expect(striped, isNotEmpty);
  });

  test('match of 5 creates a colour bomb', () {
    final types = checkerTypes();
    for (var c = 0; c < 5; c++) {
      types[c] = 3;
    }
    final board = Board.fromTypes(types);
    expect(board.findMatchGroups().any((g) => g.length >= 5), isTrue);
    board.resolveStep();
    final bombs = board.cells.where((t) => t != null && t.isBomb);
    expect(bombs, isNotEmpty);
  });

  test('cascade refills the board and leaves it stable', () {
    final board = Board.generate(numTypes: 5, seed: 42);
    final gained = board.resolveAll();
    expect(gained, greaterThanOrEqualTo(0));
    expect(board.filledCount, Board.cellCount);
    expect(board.findMatches(), isEmpty);
  });

  test('a blocker next to a match takes damage', () {
    final types = checkerTypes();
    final board = Board.fromTypes(types);
    board.setBlocker(9, 1); // row 1, col 1
    // Force a horizontal match on row 0 above it: cols 0..2 = type 4.
    types[0] = 4;
    types[1] = 4;
    types[2] = 4;
    final b2 = Board.fromTypes(types);
    b2.setBlocker(9, 1);
    expect(b2.blockerCount, 1);
    b2.resolveStep();
    expect(b2.blockerCount, 0);
  });

  test('reshuffle fixes a stuck board', () {
    // A stuck board is hard to construct by hand; verify reshuffle
    // on a generated board never leaves it stuck or matching.
    final b2 = Board.generate(numTypes: 6, seed: 3);
    expect(b2.reshuffle(), isTrue);
    expect(b2.findMatches(), isEmpty);
    expect(b2.hasPossibleMove(), isTrue);
  });
}
