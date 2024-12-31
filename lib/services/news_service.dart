import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'db_helper.dart';
import 'shared_prefs.dart';
import 'news_article.dart';

class NewsService {
  final String apiUrl = 'https://example.com/api/news';
  final DatabaseHelper dbHelper = DatabaseHelper();
  final SharedPrefs sharedPrefs = SharedPrefs();

  Future<List<NewsArticle>> fetchArticles(String category) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // Offline: Fetch from local database
      return dbHelper.fetchArticles(category);
    } else {
      // Online: Fetch from API
      final response = await http.get(Uri.parse('$apiUrl?category=$category'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<NewsArticle> articles = data.map((json) => NewsArticle.fromJson(json)).toList();

        // Cache articles in local database
        await dbHelper.insertArticles(articles);

        // Update last updated timestamp
        await sharedPrefs.saveLastUpdated(DateTime.now().toIso8601String());

        return articles;
      } else {
        throw Exception('Failed to fetch articles');
      }
    }
  }

  Future<bool> isDataStale() async {
    final lastUpdated = await sharedPrefs.getLastUpdated();
    if (lastUpdated == null) return true;

    final lastUpdatedTime = DateTime.parse(lastUpdated);
    final now = DateTime.now();

    return now.difference(lastUpdatedTime).inMinutes > 10; // Consider stale if older than 10 minutes
  }
}
