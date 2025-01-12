import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/category_selector.dart';
import '../widgets/news_card.dart';
import '../models/news_article.dart';
import 'news_detail_screen.dart';
import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  try {
    DateTime dateTime = DateTime.parse(isoDate);
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  } catch (e) {
    return isoDate;
  }
}


class NewsFeedScreen extends StatefulWidget {
  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final List<String> categories = ["World", "Tech", "Sports", "Health", "Entertainment"];
  String? selectedCategory;

  List<NewsArticle> newsArticles = [];




  Future<void> fetchNewsArticles() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/api/news/all'));

      if (response.statusCode == 200) {
        // Explicitly decode the response body as UTF-8
        String decodedBody = utf8.decode(response.bodyBytes);
        List jsonResponse = json.decode(decodedBody);

        print("API Response: $jsonResponse");

        // Retrieve cached articles
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? cachedData = prefs.getString('cachedArticles');

        // Compare cached data with new data
        if (cachedData != null && json.encode(jsonResponse) == cachedData) {
          print("Data is the same as cached. No need to update cache.");
        } else {
          print("New data detected. Updating cache...");
          // Cache the fetched articles
          await prefs.setString('cachedArticles', json.encode(jsonResponse));
        }

        // Parse articles and update the state
        List<NewsArticle> fetchedArticles = jsonResponse
            .map((article) => NewsArticle.fromJson(article))
            .toList();

        setState(() {
          newsArticles = fetchedArticles;
        });

        // Update categories
        List<String> backendCategories = jsonResponse
            .map((article) => article['categoryName'] as String)
            .toSet()
            .toList();

        setState(() {
          if (backendCategories.isNotEmpty) {
            categories
              ..clear()
              ..addAll(backendCategories);

            if (selectedCategory != null && !categories.contains(selectedCategory)) {
              selectedCategory = null;
            }
          }
        });
      } else {
        throw Exception('Failed to fetch articles');
      }
    } catch (e) {
      print("Error fetching articles: $e");

      // Load cached articles if available
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString('cachedArticles');

      if (cachedData != null) {
        List jsonResponse = json.decode(cachedData);
        List<NewsArticle> cachedArticles = jsonResponse
            .map((article) => NewsArticle.fromJson(article))
            .toList();

        setState(() {
          newsArticles = cachedArticles;
        });
      }
    }
  }






  List<NewsArticle> get filteredArticles {
    return selectedCategory == null
        ? newsArticles
        : newsArticles.where((article) => article.category == selectedCategory).toList();
  }

  void checkCachedArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cachedArticles');

    if (cachedData != null) {
      print("Cached Articles: $cachedData");
    } else {
      print("No articles are cached.");
    }
  }


  @override
  void initState() {
    super.initState();
    fetchNewsArticles();
    checkCachedArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Döwür News'),
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
  timestamp: formatDate(article.publishedAt),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetailScreen(articleId: article.id),
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
