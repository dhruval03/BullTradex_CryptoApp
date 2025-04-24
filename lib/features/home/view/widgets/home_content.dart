import 'package:flutter/material.dart';
import 'package:bulltradex/core/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _cryptoData = [];
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCryptoData();
  }

  Future<void> _fetchCryptoData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'),
        headers: {
          'X-CMC_PRO_API_KEY': '16e23ce1-37c8-4251-8a9b-2e5a22e91b73',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cryptoData = data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getChangeColor(double change) {
    return change >= 0 ? Colors.green : Colors.red;
  }

  Widget _buildSimpleTrendIndicator(bool positive) {
    return SizedBox(
      width: 60,
      height: 30,
      child: CustomPaint(
        painter: TrendPainter(isPositive: positive),
      ),
    );
  }

  Widget _buildTopPairs() {
    if (_isLoading || _cryptoData.isEmpty) {
      return Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Sort data by market cap to get top coins
    final sortedByMarketCap = List.from(_cryptoData)
      ..sort((a, b) => (b['quote']['USD']['market_cap'] ?? 0.0)
          .compareTo(a['quote']['USD']['market_cap'] ?? 0.0));

    // Take top 3 cryptocurrencies for trending pairs
    final top3Cryptos = sortedByMarketCap.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the optimal card width based on screen size
        double cardWidth = constraints.maxWidth;
        if (constraints.maxWidth > 600) {
          cardWidth = constraints.maxWidth / 3 - 16;
        } else if (constraints.maxWidth > 400) {
          cardWidth = constraints.maxWidth / 2 - 16;
        } else {
          cardWidth = constraints.maxWidth - 32;
        }

        cardWidth = cardWidth.clamp(120.0, 180.0);

        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: top3Cryptos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final crypto = top3Cryptos[index];
              final symbol = crypto['symbol'];
              final change24h =
                  crypto['quote']['USD']['percent_change_24h'] as double;
              final pair = '$symbol/USDT';

              return _buildPairCard(
                  pair, change24h, change24h >= 0, cardWidth, crypto);
            },
          ),
        );
      },
    );
  }

  Widget _buildPairCard(String pair, double change, bool positive, double width,
      dynamic cryptoData) {
    final parts = pair.split('/');
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightCard
            : AppColors.darkCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getCryptoIcon(parts[0], cryptoData),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pair,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildSimpleTrendIndicator(positive),
              const Spacer(),
              Text(
                "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
                style: TextStyle(
                  color: _getChangeColor(change),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getCryptoIcon(String symbol, dynamic cryptoData) {
    // Generate color based on the symbol's hash code for consistent colors
    final colorValue = symbol.hashCode & 0xFFFFFF;
    final color = Color(0xFF000000 | colorValue).withOpacity(1.0);

    // Use first letter of symbol if specific icon not available
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol[0] : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRankingList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_cryptoData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No data available'),
        ),
      );
    }

    final currentTab = _tabController.index;
    List<dynamic> filteredData = List.from(_cryptoData);

    if (currentTab == 0) {
      // Gainers
      filteredData = filteredData
          .where((crypto) => crypto['quote']['USD']['percent_change_24h'] > 0)
          .toList()
        ..sort((a, b) => (b['quote']['USD']['percent_change_24h'] as double)
            .compareTo(a['quote']['USD']['percent_change_24h'] as double));
    } else if (currentTab == 1) {
      // Losers
      filteredData = filteredData
          .where((crypto) => crypto['quote']['USD']['percent_change_24h'] < 0)
          .toList()
        ..sort((a, b) => (a['quote']['USD']['percent_change_24h'] as double)
            .compareTo(b['quote']['USD']['percent_change_24h'] as double));
    } else {
      // 24h Vol
      filteredData = filteredData
        ..sort((a, b) => (b['quote']['USD']['volume_24h'] as double)
            .compareTo(a['quote']['USD']['volume_24h'] as double));
    }

    // Take only top 10 items for better performance
    final displayData = filteredData.take(10).toList();

    // Use a Column instead of ListView to avoid nesting scrollable views
    return Column(
      children: displayData.map((crypto) {
        final price = crypto['quote']['USD']['price'] as double;
        final change24h =
            crypto['quote']['USD']['percent_change_24h'] as double;
        final symbol = crypto['symbol'];
        final volume = crypto['quote']['USD']['volume_24h'] as double;
        final volumeFormatted = _formatVolume(volume);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.lightCard
                : AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: _getCryptoIcon(symbol, crypto),
              title: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '$symbol / USDT',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      currencyFormat.format(price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Vol $volumeFormatted',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${change24h >= 0 ? '+' : ''}${change24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: _getChangeColor(change24h),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              trailing: SizedBox(
                width: 60,
                child: _buildSimpleTrendIndicator(change24h >= 0),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000) {
      return '\$${(volume / 1000000000).toStringAsFixed(2)}B';
    } else if (volume >= 1000000) {
      return '\$${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '\$${(volume / 1000).toStringAsFixed(2)}K';
    }
    return '\$${volume.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to adapt to screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth > 600 ? 24.0 : 16.0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchCryptoData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 8),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: const Text(
                        'Trending Pairs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildTopPairs(),
                    const SizedBox(height: 16),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Row(
                        children: [
                          const Text(
                            'Ranking List',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),

                    // Responsive tab bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.black,
                          unselectedLabelColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.white70,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Theme.of(context).primaryColor,
                          ),
                          onTap: (index) {
                            setState(() {}); // Refresh to show new tab content
                          },
                          tabs: [
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        16.0), // Adjust padding as needed
                                child: Text('Gainers'),
                              ),
                            ),
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        16.0), // Adjust padding as needed
                                child: Text('Losers'),
                              ),
                            ),
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        16.0), // Adjust padding as needed
                                child: Text('24h Vol'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildRankingList(),

                    // Add bottom padding to ensure content isn't cut off
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom painter for simple trend indicator
class TrendPainter extends CustomPainter {
  final bool isPositive;

  TrendPainter({required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPositive ? Colors.green : Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isPositive) {
      // Draw upward trend
      path.moveTo(0, size.height * 0.8);
      path.lineTo(size.width * 0.3, size.height * 0.6);
      path.lineTo(size.width * 0.7, size.height * 0.4);
      path.lineTo(size.width, size.height * 0.2);
    } else {
      // Draw downward trend
      path.moveTo(0, size.height * 0.2);
      path.lineTo(size.width * 0.3, size.height * 0.4);
      path.lineTo(size.width * 0.7, size.height * 0.6);
      path.lineTo(size.width, size.height * 0.8);
    }

    canvas.drawPath(path, paint);

    // Area under the curve
    final fillPaint = Paint()
      ..color = (isPositive ? Colors.green : Colors.red).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(TrendPainter oldDelegate) =>
      oldDelegate.isPositive != isPositive;
}
