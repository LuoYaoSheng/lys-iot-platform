import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_iot_app/pages/login_page.dart';

void main() {
  testWidgets('Login page renders expected fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('欢迎回来'), findsOneWidget);
    expect(find.text('登录以继续管理您的智能设备'), findsOneWidget);
    expect(find.text('邮箱'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.byIcon(Icons.dns_outlined), findsOneWidget);
  });
}
