import 'package:flutter/material.dart';
import 'media_item.dart'; // Ensure you have an Actor model

class ActorDetailsPage extends StatelessWidget {
  final Actor actor; // The actor object that contains the details of the actor.

  ActorDetailsPage({required this.actor}); // Constructor to initialize the actor object.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(actor.name), // Display the actor's name in the app bar.
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            actor.imageUrl != null
                ? Image.network(actor.imageUrl!) // Display the actor's image if available.
                : Placeholder(fallbackHeight: 200.0, fallbackWidth: double.infinity), // Display a placeholder if the actor's image is not available.
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Biography", // Heading for the actor's biography section.
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                actor.biography ?? 'No biography available.', // Display the actor's biography if available, otherwise display a default message.
                style: TextStyle(fontSize: 16),
              ),
            ),
            // You might want to add a section here to display the media the actor has participated in.
            // This would require fetching the actor's credits from your API and displaying them.
          ],
        ),
      ),
    );
  }
}
