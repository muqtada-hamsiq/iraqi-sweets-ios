import 'package:flutter_test/flutter_test.dart';
import 'package:game/data/levels.dart';

void main() {
  test('exactly 200 levels in 7 governorate sections', () {
    expect(governorates.length, 7);
    expect(allLevels.length, 200);
    expect(allLevels.first.number, 1);
    expect(allLevels.last.number, 200);
    expect(allLevels.last.area, 'دوكان');
    for (var i = 0; i < 200; i++) {
      expect(allLevels[i].number, i + 1);
    }
  });

  test('section ranges match the map: 30,30,30,30,30,30,20', () {
    const expected = [30, 30, 30, 30, 30, 30, 20];
    for (var s = 0; s < 7; s++) {
      expect(governorates[s].areas.length, expected[s]);
    }
    expect(governorates[0].name, 'بغداد');
    expect(governorates[1].name, 'البصرة');
    expect(governorates[2].name, 'كربلاء');
    expect(governorates[3].name, 'النجف');
    expect(governorates[4].name, 'نينوى - الموصل');
    expect(governorates[5].name, 'أربيل');
    expect(governorates[6].name, 'السليمانية');
  });

  test('area names are non-empty and unique within each section', () {
    for (final gov in governorates) {
      for (final area in gov.areas) {
        expect(area.trim().isNotEmpty, isTrue);
      }
      expect(gov.areas.toSet().length, gov.areas.length);
    }
  });

  test('difficulty rises: target up, moves down, blockers up', () {
    for (var i = 1; i < 200; i++) {
      expect(allLevels[i].targetScore, greaterThan(allLevels[i - 1].targetScore));
    }
    for (var s = 1; s < 7; s++) {
      final firstOfSection = allLevels.firstWhere((l) => l.sectionIndex == s);
      final prev = allLevels.firstWhere((l) => l.sectionIndex == s - 1);
      expect(firstOfSection.moves, lessThanOrEqualTo(prev.moves));
      expect(firstOfSection.blockerCount, greaterThanOrEqualTo(prev.blockerCount));
    }
    expect(allLevels.first.blockerCount, 0);
    expect(allLevels.last.blockerCount, 14);
    expect(allLevels.first.numTypes, 5);
    expect(allLevels.last.numTypes, 6);
  });

  test('star thresholds are ordered and reachable', () {
    for (final level in allLevels) {
      expect(level.twoStarScore, greaterThan(level.targetScore));
      expect(level.threeStarScore, greaterThan(level.twoStarScore));
      expect(level.starsForScore(0), 0);
      expect(level.starsForScore(level.targetScore), 1);
      expect(level.starsForScore(level.twoStarScore), 2);
      expect(level.starsForScore(level.threeStarScore), 3);
    }
  });

  test('level 19 is ساحة الفردوس in Baghdad', () {
    final level = allLevels[18];
    expect(level.number, 19);
    expect(level.area, 'ساحة الفردوس');
    expect(level.governorate, 'بغداد');
  });
}
