import 'package:flutter/material.dart';
import 'dart:convert'; // For decoding JSON
import 'package:http/http.dart' as http;
import '../widgets/category_selector.dart';
import '../widgets/news_card.dart';
import '../models/news_article.dart';
import 'news_detail_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final List<String> categories = ["World", "Tech", "Sports", "Health", "Entertainment"];
  String? selectedCategory; // Initially no category selected

  List<NewsArticle> newsArticles = []; // Initially empty list of articles

  // Fetch the news articles from the API
  Future<void> fetchNewsArticles() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/news/all'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        newsArticles = jsonResponse
            .map((article) => NewsArticle.fromJson(article))
            .toList();
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  // Filter articles based on the selected category
  List<NewsArticle> get filteredArticles {
    return selectedCategory == null
        ? newsArticles
        : newsArticles.where((article) => article.category == selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchNewsArticles(); // Fetch the articles when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily News'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4f86f7),
      ),
      body: Column(
        children: [
          // Categories Row
          CategorySelector(
            categories: categories,
            selectedCategory: selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                selectedCategory = category;
              });
            },
          ),
          const SizedBox(height: 10),
          // News Cards
          Expanded(
            child: filteredArticles.isEmpty
                ? Center(
                    child: Text(
                      selectedCategory == null
                          ? "Loading articles..."
                          : "No articles available for $selectedCategory",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
  final article = filteredArticles[index];
  return NewsCard(
  title: article.title,
  image: article.imageUrl,
  timestamp: article.publishedAt,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(
          title: article.title,
          image: article.imageUrl,
        ),
      ),
    );
  },
);

},


                  ),
          ),
        ],
      ),
    );
  }
}
