import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants.dart';
import '../models/news_article.dart';

class NewsDetailScreen extends StatefulWidget {
  final int articleId;

  const NewsDetailScreen({Key? key, required this.articleId}) : super(key: key);

  @override
  NewsDetailScreenState createState() => NewsDetailScreenState();
}

class NewsDetailScreenState extends State<NewsDetailScreen> {
  NewsArticle? article;
  bool isLoading = true;

  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchArticle(widget.articleId);
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  Future<void> fetchArticle(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedArticles');

    if (cachedData != null) {
      final cachedArticles = json.decode(cachedData);
      final cachedArticle = cachedArticles.firstWhere(
            (a) => a['id'] == id,
        orElse: () => null,
      );

      if (cachedArticle != null) {
        setState(() {
          article = NewsArticle.fromJson(cachedArticle);
          isLoading = false;
        });
        return;
      }
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/news/$id'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          article = NewsArticle.fromJson(jsonResponse);
          isLoading = false;
        });

        if (cachedData != null) {
          final cachedArticles = json.decode(cachedData);
          cachedArticles.add(jsonResponse);
          await prefs.setString('cachedArticles', json.encode(cachedArticles));
        }
      } else {
        setState(() => isLoading = false);
        debugPrint("Failed to fetch article with ID: $id");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching article: $e");
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      // adUnitId: 'ca-app-pub-1638187422634927/1211333876', // Valid ad unit ID
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ad unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          article?.title ?? "Loading...",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF4f86f7),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBody(),
            ),
          ),
          if (_isAdLoaded)
            Container(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4f86f7)),
        ),
      );
    }

    if (article == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              "Article not found",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Hero(
            tag: 'article_image_${article!.id}',
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Image.network(
                article!.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/default-image.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              Text(
                article!.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                article!.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}
