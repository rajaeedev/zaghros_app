import 'package:flutter_test/flutter_test.dart';
import 'package:zaghros_app/main.dart';

void main() {
  testWidgets('persian shell renders correctly', (tester) async {
    await tester.pumpWidget(const ZaghrosSparePartsApp());

    expect(find.text('هاب قطعات زاگرس'), findsOneWidget);
    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('انبار'), findsOneWidget);
    expect(find.text('درخواست'), findsOneWidget);
    expect(find.text('مدیریت'), findsOneWidget);
  });
}
