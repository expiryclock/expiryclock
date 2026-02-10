// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expiryclock/core/app/app.dart';

void main() {
  testWidgets('ExpiryClockApp smoke test', (WidgetTester tester) async {
    // 테스트용 빈 카메라 목록으로 앱 빌드
    await tester.pumpWidget(const ExpiryClockApp(cameras: []));

    // 앱이 정상적으로 빌드되는지 확인
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('ExpiryClockApp has correct title', (
    WidgetTester tester,
  ) async {
    // 테스트용 빈 카메라 목록으로 앱 빌드
    await tester.pumpWidget(const ExpiryClockApp(cameras: []));

    // MaterialApp의 title이 'Expiry Tracker'인지 확인
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Expiry Tracker');
  });

  testWidgets('ExpiryClockApp starts with splash route', (
    WidgetTester tester,
  ) async {
    // 테스트용 빈 카메라 목록으로 앱 빌드
    await tester.pumpWidget(const ExpiryClockApp(cameras: []));

    // MaterialApp의 초기 라우트가 '/splash'인지 확인
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.initialRoute, '/splash');
  });
}
