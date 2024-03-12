import 'package:flutter/material.dart';
import 'media_item.dart'; // Ensure you have an Actor model

class ActorDetailsPage extends StatelessWidget {
  final Actor actor;

  ActorDetailsPage({required this.actor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(actor.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            actor.imageUrl != null
                ? Image.network(actor.imageUrl!)
                : Placeholder(fallbackHeight: 200.0, fallbackWidth: double.infinity),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Biography",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                actor.biography ?? 'No biography available.',
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
