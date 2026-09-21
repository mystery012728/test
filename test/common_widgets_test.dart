import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testprojectnew/core/widgets/common_empty_state.dart';
import 'package:testprojectnew/core/widgets/common_error_state.dart';
import 'package:testprojectnew/core/widgets/custom_back_button.dart';
import 'package:testprojectnew/core/widgets/custom_toast_bar.dart';

Widget _buildTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  group('CommonEmptyState Tests', () {
    testWidgets('renders default empty state properly', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CommonEmptyState(
            title: 'Your Cart is Empty',
            subtitle: 'Looks like you haven\'t added anything yet.',
          ),
        ),
      );

      expect(find.text('Your Cart is Empty'), findsOneWidget);
      expect(
        find.text('Looks like you haven\'t added anything yet.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders action button and triggers callback', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        _buildTestApp(
          CommonEmptyState(
            title: 'No Orders Placed Yet',
            actionLabel: 'Start Shopping',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('Start Shopping'), findsOneWidget);
      await tester.tap(find.text('Start Shopping'));
      expect(actionTriggered, isTrue);
    });
  });

  group('CommonErrorState Tests', () {
    testWidgets('renders default Oops title and error message', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const CommonErrorState(
            message: 'Failed to connect to server',
          ),
        ),
      );

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Failed to connect to server'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders retry button and triggers callback', (tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        _buildTestApp(
          CommonErrorState(
            message: 'Network timeout',
            onRetry: () => retryTriggered = true,
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retryTriggered, isTrue);
    });
  });

  group('CustomToastBar Tests', () {
    testWidgets('renders toast message and triggers action', (tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        _buildTestApp(
          CustomToastBar(
            message: 'Item added to Cart',
            type: ToastType.success,
            actionLabel: 'Undo',
            onAction: () => actionPressed = true,
          ),
        ),
      );

      expect(find.text('Item added to Cart'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      expect(actionPressed, isTrue);
    });

    testWidgets('CustomToastBar.show renders through ScaffoldMessenger with 3s duration', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (scaffoldContext) {
                  return ElevatedButton(
                    onPressed: () {
                      CustomToastBar.showSuccess(
                        scaffoldContext,
                        'Test Toast Message',
                      );
                    },
                    child: const Text('Show Toast'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Test Toast Message'), findsOneWidget);

      // Fast forward past 3 seconds (3000ms duration + dismiss animation)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Toast should now be removed after 3 seconds
      expect(find.text('Test Toast Message'), findsNothing);
    });
  });

  group('CustomBackButton Tests', () {
    testWidgets('renders arrow_back_ios_new_rounded icon and triggers callback',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          CustomBackButton(
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      await tester.tap(find.byType(CustomBackButton));
      expect(tapped, isTrue);
    });
  });
}
