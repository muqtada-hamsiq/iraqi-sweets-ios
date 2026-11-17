import 'dart:math';

/// Kind of special piece a tile can become.
enum SpecialKind { none, stripedH, stripedV, wrapped, bomb }

/// One cell of the board. A blocker (chocolate) is a tile with
/// [blockerHp] > 0: it never moves, never matches, and is damaged when a
/// match happens next to it.
class Tile {
  Tile({required this.type, this.special = SpecialKind.none, this.blockerHp = 0});

  Tile.clone(Tile other)
      : type = other.type,
        special = other.special,
        blockerHp = other.blockerHp;

  /// Sweet type index (0..numTypes-1), or -1 for a blocker.
  int type;
  SpecialKind special;
  int blockerHp;

  bool get isBlocker => blockerHp > 0;
  bool get isBomb => special == SpecialKind.bomb;
}

/// Pure match-3 board logic. No Flutter dependency, fully unit-testable.
class Board {
  Board._(this.cells, this.numTypes, this.rng);

  static const int size = 8;
  static const int cellCount = size * size;

  final List<Tile?> cells;
  final int numTypes;
  final Random rng;

  /// Generates a fresh board: no initial matches, at least one move.
  factory Board.generate({required int numTypes, int blockerCount = 0, int? seed}) {
    final rng = seed == null ? Random() : Random(seed);
    late Board board;
    var guard = 0;
    do {
      final cells = List<Tile?>.filled(cellCount, null);
      for (var i = 0; i < cellCount; i++) {
        var type = rng.nextInt(numTypes);
        var tries = 0;
        while (tries < 20 && _wouldMatch(cells, i, type)) {
          type = rng.nextInt(numTypes);
          tries++;
        }
        cells[i] = Tile(type: type);
      }
      board = Board._(cells, numTypes, rng);
      board._placeBlockers(blockerCount);
      guard++;
    } while (guard < 200 && !board.hasPossibleMove());
    return board;
  }

  /// Builds a board from explicit types (for tests). -1 means empty.
  factory Board.fromTypes(List<int> types, {int numTypes = 6, int? seed}) {
    final cells = List<Tile?>.filled(cellCount, null);
    for (var i = 0; i < cellCount && i < types.length; i++) {
      if (types[i] >= 0) cells[i] = Tile(type: types[i]);
    }
    return Board._(cells, numTypes, seed == null ? Random() : Random(seed));
  }

  static int rowOf(int i) => i ~/ size;
  static int colOf(int i) => i % size;
  static int indexOf(int r, int c) => r * size + c;

  static bool _wouldMatch(List<Tile?> cells, int i, int type) {
    final r = rowOf(i);
    final c = colOf(i);
    if (c >= 2) {
      final a = cells[i - 1];
      final b = cells[i - 2];
      if (a != null && b != null && a.type == type && b.type == type) return true;
    }
    if (r >= 2) {
      final a = cells[i - size];
      final b = cells[i - size * 2];
      if (a != null && b != null && a.type == type && b.type == type) return true;
    }
    return false;
  }

  void _placeBlockers(int count) {
    var placed = 0;
    var guard = 0;
    while (placed < count && guard < 500) {
      guard++;
      final i = rng.nextInt(cellCount);
      if (rowOf(i) == 0) continue;
      final t = cells[i];
      if (t == null || t.isBlocker) continue;
      cells[i] = Tile(type: -1, blockerHp: 1);
      placed++;
    }
  }

  void setBlocker(int index, int hp) {
    cells[index] = Tile(type: -1, blockerHp: hp);
  }

  /// All match groups on the board. Each group is a list of cell indices
  /// in one straight line of 3+ equal sweets.
  List<List<int>> findMatchGroups() {
    final groups = <List<int>>[];
    for (var r = 0; r < size; r++) {
      var c = 0;
      while (c < size) {
        final t = cells[indexOf(r, c)];
        if (t == null || t.isBlocker) {
          c++;
          continue;
        }
        var len = 1;
        while (c + len < size) {
          final n = cells[indexOf(r, c + len)];
          if (n != null && !n.isBlocker && n.type == t.type) {
            len++;
          } else {
            break;
          }
        }
        if (len >= 3) {
          groups.add([for (var k = 0; k < len; k++) indexOf(r, c + k)]);
        }
        c += len;
      }
    }
    for (var c = 0; c < size; c++) {
      var r = 0;
      while (r < size) {
        final t = cells[indexOf(r, c)];
        if (t == null || t.isBlocker) {
          r++;
          continue;
        }
        var len = 1;
        while (r + len < size) {
          final n = cells[indexOf(r + len, c)];
          if (n != null && !n.isBlocker && n.type == t.type) {
            len++;
          } else {
            break;
          }
        }
        if (len >= 3) {
          groups.add([for (var k = 0; k < len; k++) indexOf(r + k, c)]);
        }
        r += len;
      }
    }
    return groups;
  }

  Set<int> findMatches() => findMatchGroups().expand((g) => g).toSet();

  bool areAdjacent(int a, int b) {
    final dr = (rowOf(a) - rowOf(b)).abs();
    final dc = (colOf(a) - colOf(b)).abs();
    return dr + dc == 1;
  }

  /// Swaps two adjacent tiles. Returns true only if the swap makes a
  /// match; otherwise the swap is reverted and false is returned.
  bool trySwap(int a, int b) {
    if (!areAdjacent(a, b)) return false;
    final ta = cells[a];
    final tb = cells[b];
    if (ta == null || tb == null || ta.isBlocker || tb.isBlocker) return false;
    // A colour bomb clears every tile of the type it is swapped with.
    if (ta.isBomb || tb.isBomb) {
      final bomb = ta.isBomb ? a : b;
      final other = ta.isBomb ? b : a;
      final targetType = cells[other]!.type;
      cells[bomb] = null;
      for (var i = 0; i < cellCount; i++) {
        final t = cells[i];
        if (t != null && !t.isBlocker && t.type == targetType) cells[i] = null;
      }
      _damageBlockersAround({bomb, other});
      return true;
    }
    cells[a] = tb;
    cells[b] = ta;
    if (findMatches().isEmpty) {
      cells[a] = ta;
      cells[b] = tb;
      return false;
    }
    return true;
  }

  void _damageBlockersAround(Set<int> cleared) {
    final hit = <int>{};
    for (final i in cleared) {
      for (final d in [-size, size, -1, 1]) {
        final j = i + d;
        if (j < 0 || j >= cellCount) continue;
        if (d == -1 && colOf(i) == 0) continue;
        if (d == 1 && colOf(i) == size - 1) continue;
        final t = cells[j];
        if (t != null && t.isBlocker) hit.add(j);
      }
    }
    for (final j in hit) {
      final t = cells[j]!;
      t.blockerHp--;
      if (t.blockerHp <= 0) cells[j] = null;
    }
  }

  /// Resolves one cascade step: clears current matches (spawning a
  /// special piece when a group is 4+ or an L/T shape), damages blockers,
  /// applies gravity and refills. Returns the score earned this step.
  /// Returns 0 when there is nothing to clear.
  int resolveStep() {
    final groups = findMatchGroups();
    if (groups.isEmpty) return 0;
    final matched = groups.expand((g) => g).toSet();

    // Decide special spawns before clearing.
    final spawns = <int, Tile>{};
    final inHorizontal = <int>{};
    final inVertical = <int>{};
    for (final g in groups) {
      final horizontal = g.length > 1 && rowOf(g.first) == rowOf(g.last);
      for (final i in g) {
        (horizontal ? inHorizontal : inVertical).add(i);
      }
    }
    final intersections = inHorizontal.intersection(inVertical);
    for (final i in intersections) {
      spawns[i] = Tile(type: cells[i]!.type, special: SpecialKind.wrapped);
    }
    for (final g in groups) {
      if (g.length >= 5) {
        final at = g.firstWhere((i) => !spawns.containsKey(i), orElse: () => g.first);
        spawns[at] = Tile(type: cells[at]!.type, special: SpecialKind.bomb);
      } else if (g.length == 4) {
        final at = g.firstWhere((i) => !spawns.containsKey(i), orElse: () => g.first);
        final horizontal = rowOf(g.first) == rowOf(g.last);
        spawns[at] = Tile(
          type: cells[at]!.type,
          special: horizontal ? SpecialKind.stripedH : SpecialKind.stripedV,
        );
      }
    }

    // A bomb caught in a match clears every tile of its type.
    final extraCleared = <int>{};
    for (final i in matched) {
      final t = cells[i];
      if (t != null && t.isBomb) {
        for (var j = 0; j < cellCount; j++) {
          final o = cells[j];
          if (o != null && !o.isBlocker && o.type == t.type) extraCleared.add(j);
        }
      }
      if (t != null && t.special == SpecialKind.stripedH) {
        final r = rowOf(i);
        for (var c = 0; c < size; c++) {
          extraCleared.add(indexOf(r, c));
        }
      }
      if (t != null && t.special == SpecialKind.stripedV) {
        final c = colOf(i);
        for (var r = 0; r < size; r++) {
          extraCleared.add(indexOf(r, c));
        }
      }
      if (t != null && t.special == SpecialKind.wrapped) {
        for (var dr = -1; dr <= 1; dr++) {
          for (var dc = -1; dc <= 1; dc++) {
            final r = rowOf(i) + dr;
            final c = colOf(i) + dc;
            if (r >= 0 && r < size && c >= 0 && c < size) {
              extraCleared.add(indexOf(r, c));
            }
          }
        }
      }
    }

    final allCleared = {...matched, ...extraCleared};
    var score = allCleared.length * 60 + spawns.length * 120;
    for (final i in allCleared) {
      if (spawns.containsKey(i)) {
        cells[i] = spawns[i];
      } else {
        cells[i] = null;
      }
    }
    _damageBlockersAround(allCleared);
    _applyGravityAndRefill();
    return score;
  }

  void _applyGravityAndRefill() {
    for (var c = 0; c < size; c++) {
      // Collect falling tiles bottom-up, blockers stay in place.
      final falling = <Tile>[];
      for (var r = size - 1; r >= 0; r--) {
        final t = cells[indexOf(r, c)];
        if (t != null && !t.isBlocker) falling.add(t);
      }
      var fi = 0;
      for (var r = size - 1; r >= 0; r--) {
        final i = indexOf(r, c);
        final cur = cells[i];
        if (cur != null && cur.isBlocker) continue;
        if (fi < falling.length) {
          cells[i] = falling[fi++];
        } else {
          cells[i] = null;
        }
      }
      // Refill empty cells from the top.
      for (var r = 0; r < size; r++) {
        final i = indexOf(r, c);
        if (cells[i] == null) {
          var type = rng.nextInt(numTypes);
          var tries = 0;
          while (tries < 20 && _wouldMatch(cells, i, type)) {
            type = rng.nextInt(numTypes);
            tries++;
          }
          cells[i] = Tile(type: type);
        }
      }
    }
  }

  /// True when at least one adjacent swap would make a match.
  bool hasPossibleMove() {
    if (cells.any((t) => t != null && t.isBomb)) return true;
    for (var i = 0; i < cellCount; i++) {
      final t = cells[i];
      if (t == null || t.isBlocker) continue;
      for (final d in [1, size]) {
        final j = i + d;
        if (j >= cellCount) continue;
        if (d == 1 && colOf(i) == size - 1) continue;
        final o = cells[j];
        if (o == null || o.isBlocker) continue;
        cells[i] = o;
        cells[j] = t;
        final ok = findMatches().isNotEmpty;
        cells[i] = t;
        cells[j] = o;
        if (ok) return true;
      }
    }
    return false;
  }

  /// Re-shuffles the movable sweets until the board has a possible move
  /// and no immediate match. Returns false only if it gives up.
  bool reshuffle() {
    final movable = <Tile>[];
    final positions = <int>[];
    for (var i = 0; i < cellCount; i++) {
      final t = cells[i];
      if (t != null && !t.isBlocker) {
        movable.add(Tile(type: t.type));
        positions.add(i);
      }
    }
    for (var attempt = 0; attempt < 200; attempt++) {
      movable.shuffle(rng);
      for (var k = 0; k < positions.length; k++) {
        cells[positions[k]] = Tile(type: movable[k].type);
      }
      if (findMatches().isEmpty && hasPossibleMove()) return true;
    }
    return false;
  }

  /// Fully resolves cascades until the board is stable.
  /// Returns the total score, applying a x1/x2/x3... multiplier per step.
  int resolveAll() {
    var total = 0;
    var multiplier = 1;
    while (true) {
      final gained = resolveStep();
      if (gained == 0) break;
      total += gained * multiplier;
      multiplier++;
      if (multiplier > 10) break;
    }
    return total;
  }

  int get filledCount => cells.where((t) => t != null).length;
  int get blockerCount => cells.where((t) => t != null && t.isBlocker).length;
}
