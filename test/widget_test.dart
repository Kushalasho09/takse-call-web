import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:takse_call_web/main.dart';

void main() {
  testWidgets('Web App Smoke, Help, and Settings tab navigation test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const TakseCallWebApp());
    await tester.pumpAndSettle();

    // 1. Verify Main Dashboard Elements
    expect(find.text('Kushal Asodia'), findsWidgets);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Last Week'), findsOneWidget);

    // 2. Navigate to Help Screen
    final helpTab = find.text('Help').first;
    await tester.tap(helpTab);
    await tester.pumpAndSettle();

    expect(find.text('Your Relationship Manager'), findsOneWidget);
    expect(find.text('Nimmy Saxena'), findsOneWidget);
    expect(find.text('9081444096'), findsOneWidget);
    expect(find.text('How to setup callyzer Biz mobile app?'), findsOneWidget);

    // 3. Navigate to Settings Screen
    final settingsTab = find.text('Settings').first;
    await tester.tap(settingsTab);
    await tester.pumpAndSettle();

    // Verify Settings UI Elements
    expect(find.text('Company Profile'), findsWidgets);
    expect(find.text('Update Profile'), findsOneWidget);
    expect(find.text('Billing Address'), findsOneWidget);
    expect(find.text('Add New Address'), findsOneWidget);
    expect(find.text('No billing addresses have been added.'), findsOneWidget);
    expect(find.text('Subscriptions'), findsOneWidget);
    expect(find.text('Tax Invoice'), findsOneWidget);
  });
}
