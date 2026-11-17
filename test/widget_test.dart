import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';
import 'package:game/services/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots to the Iraqi sweets home screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressService.load();
    await tester.pumpWidget(IraqiSweetsApp(progress: progress));
    await tester.pumpAndSettle();
    expect(find.text('حلويات عراقية'), findsOneWidget);
    expect(find.text('العب'), findsOneWidget);
    await tester.tap(find.text('العب'));
    await tester.pumpAndSettle();
    expect(find.text('خريطة العراق'), findsOneWidget);
    expect(find.text('بغداد'), findsOneWidget);
    expect(find.text('الكرادة'), findsOneWidget);
  });
}
