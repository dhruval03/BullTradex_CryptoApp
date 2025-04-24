import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? coinData;
  bool isLoading = true;
  int _selectedTabIndex = 1; // Default to Orders tab
  TabController? _tabController; // Make it nullable
  final random = Random();

  // Sample chart data
  final List<FlSpot> pricePoints = [];
  double highPrice = 17334.77;
  double lowPrice = 16768.94;
  double openPrice = 16946.33;
  double currentPrice = 17185.06;
  bool priceUp = true;
  double percentChange = 2.0;

  // Sample order book data
  final List<OrderBookEntry> bids = [];
  final List<OrderBookEntry> asks = [];

  @override
  void initState() {
    super.initState();
    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Generate sample data
    _generateSampleData();

    // Fetch real data
    fetchCoin();
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Safely dispose
    super.dispose();
  }

  void _generateSampleData() {
    // Clear any existing data
    pricePoints.clear();
    bids.clear();
    asks.clear();

    // Generate 24 price points (simulating 24h data)
    double basePrice = lowPrice;
    for (int i = 0; i < 24; i++) {
      double price = basePrice + random.nextDouble() * (highPrice - lowPrice);
      pricePoints.add(FlSpot(i.toDouble(), price));
      basePrice = price;
    }

    // Generate order book data
    double bidPrice = currentPrice - 10;
    double askPrice = currentPrice + 10;

    for (int i = 0; i < 10; i++) {
      double bidQuantity = 1 + random.nextInt(7).toDouble();
      double askQuantity = 1 + random.nextInt(7).toDouble();

      bids.add(OrderBookEntry(
        price: bidPrice,
        quantity: bidQuantity,
        total: bidPrice * bidQuantity,
      ));

      asks.add(OrderBookEntry(
        price: askPrice,
        quantity: askQuantity,
        total: askPrice * askQuantity,
      ));

      bidPrice -= random.nextInt(5) + 1;
      askPrice += random.nextInt(5) + 1;
    }
  }

  Future<void> fetchCoin() async {
    const apiKey = '16e23ce1-37c8-4251-8a9b-2e5a22e91b73';
    final url = Uri.parse(
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest');

    try {
      final response = await http.get(
        url,
        headers: {'X-CMC_PRO_API_KEY': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coinList = data['data'] as List;

        if (coinList.isNotEmpty && mounted) {
          setState(() {
            coinData = coinList[0]; // Display the first coin dynamically

            // Update real price data
            if (coinData != null) {
              final quote = coinData!['quote']['USD'];
              currentPrice = quote['price'].toDouble();
              percentChange = quote['percent_change_24h'].toDouble();
              priceUp = percentChange > 0;
            }

            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      // For demo purposes, continue with sample data
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the tab controller is initialized
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show loading indicator when data is loading
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceHeader(),
            _buildPriceChart(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBidTab(),
                  _buildOrdersTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                coinData != null ? '${coinData!['symbol']}/USD' : 'BTC/USD',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'High Price',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '\$${currentPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: priceUp ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${priceUp ? '+' : ''}${percentChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: priceUp ? Colors.green : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '\$${highPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '24h Volume: ${coinData != null ? '\$${(coinData!['quote']['USD']['volume_24h'] / 1000000).toStringAsFixed(2)}M' : '\$1,234.56M'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Low Price',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '\$${lowPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChart() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: pricePoints,
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(enabled: false),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    if (_tabController == null) {
      return const SizedBox
          .shrink(); // Safe fallback if tab controller isn't ready
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.green,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.green,
        tabs: const [
          Tab(text: 'Bid'),
          Tab(text: 'Orders'),
          Tab(text: 'History'),
        ],
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildBidTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Amount',
                      style: TextStyle(color: Colors.grey[600]))),
              Expanded(
                  child:
                      Text('Price', style: TextStyle(color: Colors.grey[600]))),
              Expanded(
                  child:
                      Text('Total', style: TextStyle(color: Colors.grey[600]))),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Bid section
                  ...bids.map((bid) => _buildOrderRow(
                        amount: bid.quantity.toStringAsFixed(4),
                        price: bid.price.toStringAsFixed(2),
                        total: bid.total.toStringAsFixed(2),
                        isPriceUp: true,
                      )),

                  const Divider(),

                  // Ask section
                  ...asks.map((ask) => _buildOrderRow(
                        amount: ask.quantity.toStringAsFixed(4),
                        price: ask.price.toStringAsFixed(2),
                        total: ask.total.toStringAsFixed(2),
                        isPriceUp: false,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      Text('Price', style: TextStyle(color: Colors.grey[600]))),
              Expanded(
                  child: Text('Amount',
                      style: TextStyle(color: Colors.grey[600]))),
              Expanded(
                  child:
                      Text('Total', style: TextStyle(color: Colors.grey[600]))),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                // Alternate between buy and sell orders
                final bool isBuy = index % 2 == 0;
                final double price = currentPrice +
                    (isBuy
                        ? -random.nextDouble() * 50
                        : random.nextDouble() * 50);
                final double amount = 0.1 + random.nextDouble() * 2;

                return _buildOrderRow(
                  amount: amount.toStringAsFixed(4),
                  price: price.toStringAsFixed(2),
                  total: (price * amount).toStringAsFixed(2),
                  isPriceUp: isBuy,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      Text('Time', style: TextStyle(color: Colors.grey[600]))),
              Expanded(
                  child:
                      Text('Price', style: TextStyle(color: Colors.grey[600]))),
              Expanded(
                  child: Text('Amount',
                      style: TextStyle(color: Colors.grey[600]))),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                // Generate random transaction data
                final bool isBuy = index % 2 == 0;
                final double price = currentPrice +
                    (isBuy
                        ? -random.nextDouble() * 20
                        : random.nextDouble() * 20);
                final double amount = 0.1 + random.nextDouble() * 1;
                final String time =
                    "${random.nextInt(24)}:${random.nextInt(60).toString().padLeft(2, '0')}";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(time)),
                      Expanded(
                        child: Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isBuy ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Text(amount.toStringAsFixed(4))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow({
    required String amount,
    required String price,
    required String total,
    required bool isPriceUp,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(amount)),
          Expanded(
            child: Text(
              '\$$price',
              style: TextStyle(
                color: isPriceUp ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(total)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Buy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sell',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model class for order book entries
class OrderBookEntry {
  final double price;
  final double quantity;
  final double total;

  OrderBookEntry({
    required this.price,
    required this.quantity,
    required this.total,
  });
}
