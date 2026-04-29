import 'package:flutter_test/flutter_test.dart';
import 'package:ozon_bank/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const OzonBankApp());
    await tester.pump();
    expect(find.text('ozon банк'), findsOneWidget);
    expect(find.text('Основной счёт'), findsOneWidget);
  });
}
