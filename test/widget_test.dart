import 'package:flutter/material.dart';
import 'package:flutter_application_5/home_page.dart'; // Adjust the import path as necessary
import 'package:flutter_application_5/api_service.dart'; // Adjust the import path as necessary
import 'package:flutter_application_5/media_item.dart'; // Adjust the import path as necessary
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock class for ApiService
class MockApiService extends Mock implements ApiService {}

void main() {
  group('HomePage Tests', () {
    testWidgets('Image is displayed in HomePage', (WidgetTester tester) async {
      // Create a mock ApiService
      final mockApiService = MockApiService();
     var any = "" ;
      // Setup mock response
      when(mockApiService.fetchTrending(any)).thenAnswer((_) async => [
            MediaItem(
              id: "1",
              title: 'Test Movie',
              posterPath: 'https://example.com/test_movie_poster.jpg',
            ),
          ]);

      // Provide the mockApiService to the HomePage wrapped with a Provider
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => mockApiService,
            child: HomePage(),
          ),
        ),
      );

      // Trigger a frame to complete the Future and build the UI
      await tester.pumpAndSettle();

      // Verify that an image is displayed
      expect(find.byType(Image), findsOneWidget);

      // Optionally, verify the image's network URL if needed
      final Image image = tester.firstWidget(find.byType(Image)) as Image;
      final NetworkImage networkImage = image.image as NetworkImage;
      expect(networkImage.url, equals('https://example.com/test_movie_poster.jpg'));
    });
  });
}
