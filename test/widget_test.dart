import 'package:flutter_test/flutter_test.dart';
import 'package:tkt_pos/main.dart';
import 'package:tkt_pos/resources/strings.dart';

void main() {
  testWidgets('App renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify that the app shows the expected title somewhere in the tree
    expect(find.text(AppString.title), findsWidgets);
  });
}

