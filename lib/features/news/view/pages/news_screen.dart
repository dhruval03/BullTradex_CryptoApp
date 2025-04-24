import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bulltradex/core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<NewsArticle> _newsArticles = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _nextPageUrl;
  final ScrollController _scrollController = ScrollController();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _nextPageUrl != null) {
        _fetchMoreNews();
      }
    }
  }

  Future<void> _fetchNews() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://cryptopanic.com/api/v1/posts/?auth_token=1a21273d2cd4c61feccd31215dd17a59cb957879&kind=news'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        setState(() {
          _newsArticles.clear();
          _newsArticles.addAll(results.map((item) => NewsArticle.fromJson(item)));
          _nextPageUrl = data['next'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load news. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreNews() async {
    if (_isLoading || _nextPageUrl == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(_nextPageUrl!));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        setState(() {
          _newsArticles.addAll(results.map((item) => NewsArticle.fromJson(item)));
          _nextPageUrl = data['next'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load more news. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'An error occurred while loading more news: $e';
        _isLoading = false;
      });
    }
  }

  // Method to launch URLs
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the article: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: _isDarkMode ? AppColors.darkAccent : AppColors.lightAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isDarkMode ? AppColors.darkText.withOpacity(0.7) : AppColors.lightText.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_newsArticles.isEmpty && _isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: _isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading latest news...',
              style: TextStyle(
                color: _isDarkMode ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
      );
    }

    if (_newsArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.newspaper,
              size: 60,
              color: _isDarkMode ? AppColors.darkAccent : AppColors.lightAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'No news articles found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNews,
      color: _isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _newsArticles.length + (_isLoading && _nextPageUrl != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _newsArticles.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: _isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            );
          }
          return NewsCard(
            article: _newsArticles[index],
            isDarkMode: _isDarkMode,
            onArticleTap: () => _launchURL(_newsArticles[index].url),
            onReadMoreTap: () => _launchURL(_newsArticles[index].url),
          );
        },
      ),
    );
  }
}

class NewsArticle {
  final String title;
  final String? description;
  final List<String> currencies;
  final DateTime publishedAt;
  final String sourceName;
  final String url;
  final String? imageUrl;
  final String domain;

  NewsArticle({
    required this.title,
    this.description,
    required this.currencies,
    required this.publishedAt,
    required this.sourceName,
    required this.url,
    this.imageUrl,
    required this.domain,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    List<String> extractCurrencies(dynamic currencies) {
      if (currencies == null) return [];
      return (currencies as List)
          .map((currency) => currency['code'] as String)
          .toList();
    }

    String getDomain(String url) {
      Uri uri = Uri.parse(url);
      String domain = uri.host;
      if (domain.startsWith('www.')) {
        domain = domain.substring(4);
      }
      return domain;
    }

    String extractDescription(Map<String, dynamic> json) {
      if (json['metadata']?['description'] != null) {
        return json['metadata']['description'] as String;
      }
      return json['title'] as String;
    }

    return NewsArticle(
      title: json['title'] as String,
      description: extractDescription(json),
      currencies: extractCurrencies(json['currencies']),
      publishedAt: DateTime.parse(json['published_at'] as String),
      sourceName: json['source']['title'] as String,
      url: json['url'] as String,
      imageUrl: json['metadata']?['image'] as String?,
      domain: getDomain(json['url'] as String),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final bool isDarkMode;
  final VoidCallback onArticleTap;
  final VoidCallback onReadMoreTap;

  const NewsCard({
    Key? key,
    required this.article,
    required this.isDarkMode,
    required this.onArticleTap,
    required this.onReadMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDarkMode ? AppColors.darkText : AppColors.lightText;
    final accentColor = isDarkMode ? AppColors.darkAccent : AppColors.lightAccent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onArticleTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null) ...[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 160,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 160,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkPrimary.withOpacity(0.1) : AppColors.lightPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.sourceName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: textColor.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(article.publishedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  if (article.currencies.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: article.currencies.map((currency) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            currency,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: accentColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 14,
                        color: textColor.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.domain,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: onReadMoreTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? const Color.fromARGB(255, 100, 122, 246) : AppColors.lightPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: const Size(0, 32),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Read More'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}