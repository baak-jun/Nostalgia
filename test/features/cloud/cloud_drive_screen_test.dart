import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgia/features/cloud/data/cloud_drive_repository.dart';
import 'package:nostalgia/features/cloud/presentation/cloud_drive_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CloudDriveScreen renders tabs and cloud classification UI', (tester) async {
    final repo = CloudDriveRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: CloudDriveScreen(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('웹드라이브 사진 정리'), findsOneWidget);
    expect(find.text('Google Drive'), findsOneWidget);
    expect(find.text('OneDrive'), findsOneWidget);
    expect(find.text('태그 달기'), findsOneWidget);
    expect(find.byType(Badge), findsOneWidget);
  });

  testWidgets('CloudDriveScreen switches tabs to OneDrive', (tester) async {
    final repo = CloudDriveRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: CloudDriveScreen(repository: repo),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on OneDrive tab
    await tester.tap(find.text('OneDrive'));
    await tester.pumpAndSettle();

    expect(find.text('웹드라이브 사진 정리'), findsOneWidget);
    expect(find.text('태그 달기'), findsOneWidget);
  });
}
