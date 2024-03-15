import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_5/details.dart'; // Adjust import path to your details page
import 'package:flutter_application_5/media_item.dart'; // Adjust import path to your media item class

void main() {
  testWidgets('Test Add to Watchlist Button', (WidgetTester tester) async {
    // Create a MediaItem instance for testing
    final mediaItem = MediaItem(
      id: '1',
      title: 'Test Media',
      posterPath: 'poster_path_url',
    );

    // Build the details page widget with the created MediaItem
    await tester.pumpWidget(MaterialApp(
      home: DetailsPage(mediaItem: mediaItem),
    ));

    // Find the add to watchlist button by its tooltip
    final addToWatchlistButtonFinder = find.byTooltip('Add to Watchlist');

    // Ensure that the button is initially present
    expect(addToWatchlistButtonFinder, findsOneWidget);

    // Tap on the button
    await tester.tap(addToWatchlistButtonFinder);

    // Rebuild the widget after the button press
    await tester.pump();

    // Expect that the button icon is changed (from add to remove)
    expect(find.byIcon(Icons.remove), findsOneWidget);

    // You can further test the functionality after pressing the button, such as verifying that the item is added to the watchlist.
  });
}
