import 'package:flutter/material.dart';
import 'api_service.dart'; // Adjust the import path as necessary
import 'media_item.dart'; // Adjust the import path as necessary
import 'search_screen.dart'; // Adjust the import path as necessary
import 'details.dart'; // Import the DetailsPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  int? _selectedGenre;
  Map<String, int> genres = {
    'Action': 28,
    'Comedy': 35,
    'Romance': 10749,
    'Kids': 10751,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showGenreSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Genre"),
          content: SingleChildScrollView(
            child: ListBody(
              children: genres.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  onTap: () {
                    setState(() {
                      _selectedGenre = entry.value;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Reset'),
              onPressed: () {
                setState(() {
                  _selectedGenre = null;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaList(String mediaType) {
    final Future<List<MediaItem>> futureMedia = _selectedGenre != null
        ? _apiService.fetchMediaByGenre(mediaType, _selectedGenre!, sortBy: 'popularity.desc')
        : _apiService.fetchTrending(mediaType);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHorizontalMediaList(futureMedia, _selectedGenre != null ? "Genre Specific" : "Trending"),
        ],
      ),
    );
  }

  Widget _buildHorizontalMediaList(Future<List<MediaItem>> futureMedia, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<MediaItem>>(
            future: futureMedia,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.hasData) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    MediaItem item = snapshot.data![index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DetailsPage(mediaItem: item),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Expanded(child: Image.network(item.posterPath, fit: BoxFit.cover)),
                            Text(item.title, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Text("No data available");
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies & TV Shows'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Movies'),
            Tab(text: 'TV Shows'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchScreen())),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showGenreSelector,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaList('movie'), // Movies tab content
          _buildMediaList('tv'), // TV Shows tab content
        ],
      ),
    );
  }
}
